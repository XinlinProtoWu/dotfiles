# SNR and BER — signal-to-noise ratio and bit error rate

**What they are.**

- **SNR** (signal-to-noise ratio): how much stronger the wanted signal is than
  the background noise. Falls as you move away from the transmitter.
- **BER** (bit error rate): the fraction of bits received incorrectly. Rises as
  SNR falls.

**Why they matter.** They are the two axes of the wireless link's trade-off: you
can buy a lower BER by using a slower, more robust modulation, at the cost of
rate. This is the whole reason for **rate adaptation** in Wi-Fi.

**Example.** Near the access point, QAM256 at 8 Mbps makes few errors. Far away,
QAM256 makes so many errors that retransmissions make it *slower* than BPSK at
1 Mbps — so the system drops the rate and ends up faster in practice.

**Where it appears:** [[16_Wireless]] Section 4.7

**Related:** [[terms/modulation]] · [[terms/CSMA]]
