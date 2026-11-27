/* Copyright (C) 2024 Hong Kong University of Science and Technology

This repository is used for the Computer Networks (ELEC 3120) 
course taught at Hong Kong University of Science and Technology. 

No part of the project may be copied and/or distributed without 
the express permission of the course staff. Everyone is prohibited 
from releasing their forks in any public places. */

#ifndef FOGGY_FUNCTION_H_
#define FOGGY_FUNCTION_H_

#include "foggy_tcp.h"

/**
 * Updates the socket information to represent the newly received packet.
 *
 * Pure ACK packets drive the congestion-control state machine, data packets
 * are buffered in the receive window and answered with a cumulative ACK.
 *
 * @param sock The socket used for handling packets received.
 * @param pkt The packet data received by the socket.
 */
void on_recv_pkt(foggy_socket_t *sock, uint8_t *pkt);


/**
 * Breaks up the data into packets, queues them in the send window, transmits
 * every packet that fits inside min(RWND, CWND) and drops packets that have
 * been cumulatively ACKed.
 *
 * @param sock The socket to use for sending data.
 * @param data The data to be sent (NULL when only window maintenance is due).
 * @param buf_len The length of the data being sent (0 when data is NULL).
 */
void send_pkts(foggy_socket_t *sock, uint8_t *data, int buf_len);

/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

void add_receive_window(foggy_socket_t *sock, uint8_t *pkt);

void process_receive_window(foggy_socket_t *sock);

void transmit_send_window(foggy_socket_t *sock);

void receive_send_window(foggy_socket_t *sock);

/**
 * Drives the TCP Reno congestion-control state machine (slow start,
 * congestion avoidance, fast recovery) based on a received pure ACK packet.
 * Also performs fast retransmit after three duplicate ACKs and updates the
 * sender's view of the receiver's advertised window (flow control).
 *
 * @param sock The socket whose congestion state should be updated.
 * @param pkt  The pure ACK packet that was received.
 */
void handle_congestion_window(foggy_socket_t *sock, uint8_t *pkt);

/**
 * Retransmits the packet in the send window whose sequence number equals
 * seq (i.e. the oldest unACKed packet). Used for fast retransmit and for
 * retransmissions triggered by partial ACKs in fast recovery.
 *
 * @param sock The socket whose send window should be searched.
 * @param seq  The sequence number of the packet to retransmit.
 */
void retransmit_unacked(foggy_socket_t *sock, uint32_t seq);

#endif  // FOGGY_FUNCTION_H_
