/* Copyright (C) 2024 Hong Kong University of Science and Technology

This repository is used for the Computer Networks (ELEC 3120) 
course taught at Hong Kong University of Science and Technology. 

No part of the project may be copied and/or distributed without 
the express permission of the course staff. Everyone is prohibited 
from releasing their forks in any public places. */

#include <deque>
#include <cstdlib>
#include <cstring>
#include <cstdio>

#include "foggy_function.h"
#include "foggy_backend.h"


#define MIN(X, Y) (((X) < (Y)) ? (X) : (Y))
#define MAX(X, Y) (((X) > (Y)) ? (X) : (Y))

#define DEBUG_PRINT 0
#define debug_printf(fmt, ...)                            \
  do {                                                    \
    if (DEBUG_PRINT) fprintf(stdout, fmt, ##__VA_ARGS__); \
  } while (0)


/**
 * Retransmits the packet in the send window whose sequence number equals
 * seq. If no such packet exists (already ACKed or never queued) this is a
 * no-op.
 */
void retransmit_unacked(foggy_socket_t *sock, uint32_t seq) {
  for (auto &slot : sock->send_window) {
    foggy_tcp_header_t *hdr = (foggy_tcp_header_t *)slot.msg;
    if (get_seq(hdr) == seq) {
      debug_printf("Retransmitting packet %d %d\n", get_seq(hdr),
                   get_seq(hdr) + get_payload_len(slot.msg));
      sendto(sock->socket, slot.msg, get_plen(hdr), 0,
             (struct sockaddr *)&(sock->conn), sizeof(sock->conn));
      slot.is_sent = 1;
      return;
    }
  }
}

/**
 * TCP Reno congestion-control state machine, driven by an ACK.
 *
 *  - New ACK, slow start:            CWND += 1 MSS; move to congestion
 *                                    avoidance once CWND >= SSTHRESH.
 *  - New ACK, congestion avoidance:  CWND += (MSS / CWND) * MSS.
 *  - 3 duplicate ACKs:               SSTHRESH = CWND / 2,
 *                                    CWND = SSTHRESH + 3 * MSS, fast
 *                                    retransmit, enter fast recovery.
 *  - Dup ACK in fast recovery:       CWND += 1 MSS (inflate).
 *  - New ACK in fast recovery:       CWND = SSTHRESH, back to congestion
 *                                    avoidance.
 *
 * The advertised window carried by the ACK is also recorded so the sender
 * can limit its sending window to min(RWND, CWND) (flow control).
 */
void handle_congestion_window(foggy_socket_t *sock, uint8_t *pkt) {
  foggy_tcp_header_t *hdr = (foggy_tcp_header_t *)pkt;
  window_t *win = &(sock->window);
  uint32_t ack = get_ack(hdr);

  // Flow control: learn the receiver's current advertised window (RWND).
  win->advertised_window = get_advertised_window(hdr);

  while (pthread_mutex_lock(&(win->ack_lock)) != 0) {
  }

  if (after(ack, win->last_ack_received)) {
    /* ---------------- New ACK ---------------- */
    debug_printf("New ACK %d (cwnd %u, ssthresh %u, state %d)\n", ack,
                 win->congestion_window, win->ssthresh, win->reno_state);

    switch (win->reno_state) {
      case RENO_SLOW_START:
        win->congestion_window += MSS;
        if (win->congestion_window >= win->ssthresh) {
          win->reno_state = RENO_CONGESTION_AVOIDANCE;
        }
        break;

      case RENO_CONGESTION_AVOIDANCE:
        win->congestion_window +=
            MAX((uint32_t)(MSS * MSS) / win->congestion_window, 1u);
        break;

      case RENO_FAST_RECOVERY:
        // Loss recovered: deflate the window and leave fast recovery.
        win->congestion_window = win->ssthresh;
        win->reno_state = RENO_CONGESTION_AVOIDANCE;
        break;
    }

    win->last_ack_received = ack;
    win->dup_ack_count = 0;
  } else if (ack == win->last_ack_received) {
    /* ---------------- Duplicate ACK ---------------- */
    win->dup_ack_count++;
    debug_printf("Duplicate ACK %d (count %d)\n", ack, win->dup_ack_count);

    if (win->reno_state != RENO_FAST_RECOVERY && win->dup_ack_count == 3) {
      // Fast retransmit + fast recovery.
      win->ssthresh = MAX(win->congestion_window / 2, (uint32_t)MSS);
      win->congestion_window = win->ssthresh + 3 * MSS;
      win->reno_state = RENO_FAST_RECOVERY;
      retransmit_unacked(sock, ack);
    } else if (win->reno_state == RENO_FAST_RECOVERY &&
               win->dup_ack_count > 3) {
      // In fast recovery every additional duplicate ACK inflates CWND.
      win->congestion_window += MSS;
    }
  }
  // ACKs older than last_ack_received are ignored.

  pthread_mutex_unlock(&(win->ack_lock));
}

/**
 * Updates the socket information to represent the newly received packet.
 *
 * The ACK field is processed for any packet carrying the ACK flag (including
 * data packets), then any payload is buffered/delivered and a cumulative ACK
 * is sent back.
 *
 * @param sock The socket used for handling packets received.
 * @param pkt The packet data received by the socket.
 */
void on_recv_pkt(foggy_socket_t *sock, uint8_t *pkt) {
  debug_printf("Received packet\n");
  foggy_tcp_header_t *hdr = (foggy_tcp_header_t *)pkt;
  uint16_t payload_len = get_payload_len(pkt);

  // Flow control: every incoming packet carries the peer's advertised window.
  sock->window.advertised_window = get_advertised_window(hdr);

  // Process the ACK carried by this packet (pure ACK or piggybacked ACK).
  if (get_flags(hdr) & ACK_FLAG_MASK) {
    handle_congestion_window(sock, pkt);
  }

  if (payload_len > 0) {
    debug_printf("Received data packet %d %d\n", get_seq(hdr),
                 get_seq(hdr) + payload_len);

    // Add the packet to the receive window and deliver in-order data.
    add_receive_window(sock, pkt);
    process_receive_window(sock);

    // Send a cumulative ACK for the next expected byte. The advertised
    // window reflects the remaining receive buffer space (RWND).
    debug_printf("Sending ACK packet %d\n", sock->window.next_seq_expected);
    uint32_t rwnd =
        (sock->received_len >= MAX_NETWORK_BUFFER)
            ? (uint32_t)MSS
            : MAX(MAX_NETWORK_BUFFER - (uint32_t)sock->received_len,
                  (uint32_t)MSS);

    uint8_t *ack_pkt = create_packet(
        sock->my_port, ntohs(sock->conn.sin_port),
        sock->window.last_byte_sent, sock->window.next_seq_expected,
        sizeof(foggy_tcp_header_t), sizeof(foggy_tcp_header_t), ACK_FLAG_MASK,
        rwnd, 0, NULL, NULL, 0);
    sendto(sock->socket, ack_pkt, sizeof(foggy_tcp_header_t), 0,
           (struct sockaddr *)&(sock->conn), sizeof(sock->conn));
    free(ack_pkt);
  }
}

/**
 * Queues new data into the send window (chopped into MSS-sized packets),
 * transmits every queued packet that fits inside min(RWND, CWND) and
 * releases packets that have been cumulatively ACKed.
 *
 * @param sock The socket to use for sending data.
 * @param data The data to be sent (NULL for pure window maintenance).
 * @param buf_len The length of the data being sent.
 */
void send_pkts(foggy_socket_t *sock, uint8_t *data, int buf_len) {
  if (buf_len > 0) {
    uint8_t *data_offset = data;
    while (buf_len > 0) {
      uint16_t payload_len = MIN(buf_len, (int)MSS);

      send_window_slot_t slot;
      slot.is_sent = 0;
      slot.is_rtt_sample = 0;
      slot.send_time.tv_sec = 0;
      slot.send_time.tv_nsec = 0;
      slot.timeout_interval = WINDOW_INITIAL_RTT;
      slot.msg = create_packet(
          sock->my_port, ntohs(sock->conn.sin_port),
          sock->window.last_byte_sent, sock->window.next_seq_expected,
          sizeof(foggy_tcp_header_t), sizeof(foggy_tcp_header_t) + payload_len,
          ACK_FLAG_MASK,
          MAX(MAX_NETWORK_BUFFER - (uint32_t)sock->received_len, MSS), 0,
          NULL, data_offset, payload_len);
      sock->send_window.push_back(slot);

      buf_len -= payload_len;
      data_offset += payload_len;
      sock->window.last_byte_sent += payload_len;
    }
  }

  transmit_send_window(sock);
  receive_send_window(sock);
}


void add_receive_window(foggy_socket_t *sock, uint8_t *pkt) {
  foggy_tcp_header_t *hdr = (foggy_tcp_header_t *)pkt;
  uint32_t seq = get_seq(hdr);
  uint16_t plen = get_plen(hdr);

  // Old / duplicate data: ignore, the caller still sends an ACK.
  if (before(seq, sock->window.next_seq_expected)) {
    return;
  }
  // Beyond the receive window: drop.
  if (seq - sock->window.next_seq_expected >=
      RECEIVE_WINDOW_SLOT_SIZE * (uint32_t)MSS) {
    return;
  }

  // Already buffered?
  for (int i = 0; i < RECEIVE_WINDOW_SLOT_SIZE; ++i) {
    if (sock->receive_window[i].is_used &&
        get_seq((foggy_tcp_header_t *)sock->receive_window[i].msg) == seq) {
      return;
    }
  }

  // Find a free slot and store a copy of the packet.
  for (int i = 0; i < RECEIVE_WINDOW_SLOT_SIZE; ++i) {
    if (!sock->receive_window[i].is_used) {
      sock->receive_window[i].is_used = 1;
      sock->receive_window[i].msg = (uint8_t *)malloc(plen);
      memcpy(sock->receive_window[i].msg, pkt, plen);
      return;
    }
  }
  // No free slot: drop the packet (it will be retransmitted).
}

void process_receive_window(foggy_socket_t *sock) {
  // Deliver every buffered packet that extends the in-order prefix.
  while (1) {
    receive_window_slot_t *match = NULL;
    for (int i = 0; i < RECEIVE_WINDOW_SLOT_SIZE; ++i) {
      if (sock->receive_window[i].is_used &&
          get_seq((foggy_tcp_header_t *)sock->receive_window[i].msg) ==
              sock->window.next_seq_expected) {
        match = &(sock->receive_window[i]);
        break;
      }
    }
    if (match == NULL) break;

    uint16_t payload_len = get_payload_len(match->msg);

    // Update next expected seq number.
    sock->window.next_seq_expected += payload_len;
    // Copy to received_buf.
    if (payload_len > 0) {
      sock->received_buf = (uint8_t *)realloc(
          sock->received_buf, sock->received_len + payload_len);
      memcpy(sock->received_buf + sock->received_len, get_payload(match->msg),
             payload_len);
      sock->received_len += payload_len;
    }
    // Free the slot.
    match->is_used = 0;
    free(match->msg);
    match->msg = NULL;
  }
}

void transmit_send_window(foggy_socket_t *sock) {
  if (sock->send_window.empty()) return;

  // The sending window is min(RWND, CWND): flow control + congestion control.
  while (pthread_mutex_lock(&(sock->window.ack_lock)) != 0) {
  }
  uint32_t window = MIN(sock->window.advertised_window,
                        sock->window.congestion_window);
  uint32_t acked = sock->window.last_ack_received;
  pthread_mutex_unlock(&(sock->window.ack_lock));

  for (auto &slot : sock->send_window) {
    foggy_tcp_header_t *hdr = (foggy_tcp_header_t *)slot.msg;

    if (slot.is_sent) {
      // Safety net only: resend a packet that has had no ACK for a whole
      // timeout interval (e.g. a tail loss that generates no duplicate
      // ACKs). It does not touch CWND or the Reno state. Proper loss
      // recovery is via three duplicate ACKs (fast retransmit).
      struct timespec now;
      timespec_get(&now, TIME_UTC);
      long elapsed = (now.tv_sec - slot.send_time.tv_sec) * 1000 +
                     (now.tv_nsec - slot.send_time.tv_nsec) / 1000000;
      if (elapsed >= slot.timeout_interval) {
        debug_printf("Timeout retransmit packet %d\n", get_seq(hdr));
        sendto(sock->socket, slot.msg, get_plen(hdr), 0,
               (struct sockaddr *)&(sock->conn), sizeof(sock->conn));
        slot.send_time = now;
      }
      continue;
    }

    // Only send packets that fit entirely inside min(RWND, CWND) bytes of
    // outstanding (unACKed) data.
    uint32_t seq_end = get_seq(hdr) + (uint32_t)get_payload_len(slot.msg);
    if (seq_end - acked > window) break;

    debug_printf("Sending packet %d %d\n", get_seq(hdr),
                 get_seq(hdr) + get_payload_len(slot.msg));
    slot.is_sent = 1;
    timespec_get(&slot.send_time, TIME_UTC);
    sendto(sock->socket, slot.msg, get_plen(hdr), 0,
           (struct sockaddr *)&(sock->conn), sizeof(sock->conn));
  }
}

void receive_send_window(foggy_socket_t *sock) {
  // Pop out the packets that have been ACKed.
  while (1) {
    if (sock->send_window.empty()) break;

    send_window_slot_t slot = sock->send_window.front();
    foggy_tcp_header_t *hdr = (foggy_tcp_header_t *)slot.msg;

    if (slot.is_sent == 0) {
      break;
    }
    if (has_been_acked(sock, get_seq(hdr)) == 0) {
      break;
    }
    sock->send_window.pop_front();
    free(slot.msg);
  }
}
