# Modulation — QAM256 and BPSK

**What they are.** Ways of encoding bits into a radio signal.

- **BPSK** (*Binary Phase Shift Keying*): one bit per symbol — two phases. Slow
  but very robust.
- **QAM256** (*Quadrature Amplitude Modulation*, 256 symbols): 8 bits per symbol
  — eight times faster, but the symbols sit close together, so noise causes far
  more errors.

**The trade-off.** Rate versus robustness, against a fixed noise floor. The
system adapts by changing modulation as the channel changes — see
[[terms/SNR-BER]].

**Where it appears:** [[16_Wireless]] Section 4.7

**Related:** [[terms/SNR-BER]] · [[terms/IEEE80211]]
