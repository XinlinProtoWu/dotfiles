/* COMP4611: Pipeline Hazards
 * Name: Xinlin Wu
 * ITSC email: xwudz@connect.ust.hk
 * Acknowledgements: Course handout (README.md / pa1.pdf), Lecture 5 notes.
 *
 * Complete three read-only ID checks and one IF check. Submit only this file.
 * Infer instruction timing from inst and the hardware rules in the handout.
 * You may add private helpers for classification and latency.
 */
#include "hazards.h"

/* EX-cycle latency for each opcode. FADD/FSUB use 4, FMUL 7, FDIV 24;
 * every other instruction spends a single cycle in EX. */
static int ex_latency(Op op) {
  if (op == FADD || op == FSUB)
    return 4;
  if (op == FMUL)
    return 7;
  if (op == FDIV)
    return 24;
  return 1;
}

/* True when the instruction's result appears only at the end of MEM, so it
 * cannot use the MEM->EX forwarding path. */
static bool is_load(Op op) { return op == LW || op == FLD; }

static bool is_store(Op op) { return op == SW || op == FST; }

/* Earliest ID cycle at which one source register can be consumed.
 *
 * is_store_data selects the store's second operand, which is consumed in MEM
 * (one cycle later than EX) and can additionally be supplied by WB->MEM.
 *
 * With forwarding disabled the value must simply be in the register file,
 * i.e. its scheduled WB cycle must be <= this ID cycle (WB writes before ID
 * reads in the same cycle). write_cycle == 0 means the initial RF value is
 * already available.
 *
 * With all paths enabled an ordinary EX operand can arrive through
 *   MEM->EX (arithmetic producer: ID can complete at W - 2), or
 *   WB->EX  (any producer, including loads: ID can complete at W - 1).
 * A load producer has no result at the end of EX, so MEM->EX is unusable and
 * its earliest EX handoff is W - 1. Store data is consumed in MEM and can use
 * WB->MEM as well, giving W - 2 for both arithmetic and load producers. */
static int source_limit(int cycle, int reg, bool is_store_data, bool forwarding,
                        const Scoreboard *state) {
  if (reg <= 0)
    return cycle; /* -1: absent; 0: R0 constant. */
  const RegisterWriter *w = &state->writers[reg];
  if (w->write_cycle == 0)
    return cycle; /* initial value already ready. */

  int limit = w->write_cycle; /* RF read at ID (no forwarding). */
  if (forwarding) {
    if (is_store_data)
      limit = w->write_cycle - 2;
    else if (is_load(w->writer_op))
      limit = w->write_cycle - 1;
    else
      limit = w->write_cycle - 2;
  }
  return limit > cycle ? limit : cycle;
}

int check_raw_hazard(int cycle, Op inst, int src1, int src2, int dst,
                     bool forwarding, const Scoreboard *state) {
  /* TODO 1: Find the earliest ID cycle where BOTH old source values can
   * arrive through the RF or enabled forwarding paths. Distinguish store
   * base/data and exact path cycles. Return the required stall without
   * changing any register record or WB reservation. */
  (void)dst;

  int earliest = source_limit(cycle, src1, false, forwarding, state);
  int second = source_limit(cycle, src2, is_store(inst), forwarding, state);
  if (second > earliest)
    earliest = second;
  return earliest - cycle;
}

int check_waw_hazard(int cycle, Op inst, int src1, int src2, int dst,
                     bool forwarding, const Scoreboard *state) {
  /* TODO 2: Derive candidate WB and compare with the old destination writer.
   * Return the minimum stall without changing the records. */
  (void)src1;
  (void)src2;
  (void)forwarding;

  if (dst <= 0)
    return 0; /* R0 or no destination: no hazard. */
  const RegisterWriter *w = &state->writers[dst];
  if (w->write_cycle == 0)
    return 0; /* no previous writer. */

  /* WB = ID + latency + 2. The new WB must be strictly later than the
   * previous writer's WB: cycle + L + 2 > W  =>  cycle > W - L - 2. */
  int needed = w->write_cycle - ex_latency(inst) - 1;
  return needed > cycle ? needed - cycle : 0;
}

int check_wb_hazard(int cycle, Op inst, int src1, int src2, int dst,
                    bool forwarding, const Scoreboard *state) {
  /* TODO 3: Derive candidate WB and find its first free shared-path slot.
   * Return the minimum stall; the framework reserves the final slot.
   * Every instruction uses this path, including stores and branches. */
  (void)src1;
  (void)src2;
  (void)dst;
  (void)forwarding;

  int wb = cycle + ex_latency(inst) + 2;
  int slot = wb;
  while (state->wb_reserved[slot])
    ++slot;
  return slot - wb;
}

int check_control_hazard(int cycle, int branch_id_cycle) {
  /* TODO 4: Derive when the pending EX-resolved branch releases IF.
   * Return the IF stall, or zero when fetching is allowed.
   * A branch_id_cycle of -1 means no branch is pending. */
  if (branch_id_cycle < 0)
    return 0;

  /* The branch resolves at the END of EX. Its EX starts at
   * branch_id_cycle + 1, so the next IF may begin at branch_id_cycle + 2. */
  int resume = branch_id_cycle + 2;
  return resume > cycle ? resume - cycle : 0;
}
