#### HTTP versions
- **1.0:** one TCP connection per object; per-object time $2\,\mathrm{RTT}+\text{transmission}$; no multiplexing.
- **1.1:** persistent connections + pipelining; responses in order; application-layer HOL remains.
- **2:** one persistent TCP connection; streams with Stream IDs; out-of-order responses; header compression; fixes L7 HOL, not TCP L4 HOL.
- **3:** QUIC over UDP; independent streams with per-stream reliability; fixes L4 HOL.
- **HOL blocking:** head task cannot be served, so later tasks wait; not work-conserving.
#### Transfer time and BDP
$T=\dfrac{S}{B}+D$, $\mathrm{BDP}=B\times\mathrm{RTT}$.
$T$ total time (s); $S$ file size (bits); $B$ bandwidth (bits/s); $D$ propagation delay (s); $\mathrm{BDP}$ pipe volume (bits); $\mathrm{RTT}$ round-trip time (s). For window sizing use RTT; one-way pipe volume is $B\times d_{\mathrm{prop}}$.
#### Video formulas
$A(t)=Ct+b$, $S(t)=Rt$, $Q(t)=b+(C-R)t$, $t_{\mathrm{stall}}=\dfrac{b}{R-C}$ (for $R>C$), $b\ge(R-C)f$, $k=\dfrac{b}{C}$, MBR: $R\le C$.
$C$ arrival rate (bits/s); $R$ playback bitrate (bits/s); $b$ initial buffer (bits); $t$ time since playback start (s); $f$ video duration (s); $A$ cumulative arrived, $S$ cumulative played, $Q$ buffer occupancy; $t_{\mathrm{stall}}$ time to empty; $k$ pre-download time.
**BBA-0:** if $Q\le L$ return $R_{\min}$; if $Q\ge B_{\max}-U$ return $R_{\max}$; else $R_{\min}+(R_{\max}-R_{\min})\dfrac{Q-L}{B_{\max}-U-L}$. Add hysteresis: keep current bitrate unless $Q$ crosses a neighbouring boundary.
$Q$ buffer occupancy; $B_{\max}$ max buffer; $L$ lower reservoir threshold; $U$ upper reservoir size; $R_{\min},R_{\max}$ lowest/highest bitrate. BBA-0 ignores playback-rate variability $R[t]$.
#### Measuring RTT
$ER\leftarrow(1-\alpha)ER+\alpha S$, $\alpha=0.125$; $DR\leftarrow(1-\beta)DR+\beta|S-ER|$, $\beta=0.25$; $T_{\mathrm{out}}=ER+4DR$.
$S$ SampleRTT (ignore retransmissions); $ER$ EstimatedRTT; $DR$ DevRTT; $T_{\mathrm{out}}$ TimeoutInterval; $4DR$ safety margin.
#### TCP flags
**SYN** synchronize/open; **ACK** acknowledgment valid; **FIN** no more data; **RST** abort; **PSH** deliver immediately; **URG** urgent pointer valid; **CWR** congestion window reduced (ECN); **ECE** ECN-Echo. SYN and FIN each occupy one byte of sequence space.
#### Three-way handshake
$A\to B:\text{SYN},seq=x$; $B\to A:\text{SYN-ACK},seq=y,ack=x+1$; $A\to B:\text{ACK},seq=x+1,ack=y+1$.
$x,y$ are ISNs; $+1$ because SYN consumes one sequence number. After SYN-ACK A may send; after final ACK B may send.
#### Window size and relationships
$W_{\mathrm{send}}=\min(\mathrm{cwnd},\mathrm{rwnd})$, $\mathrm{FlightSize}\le W_{\mathrm{send}}$, $\mathrm{BDP}=B\times\mathrm{RTT}$, throughput $\approx W_{\mathrm{send}}/\mathrm{RTT}$.
$W_{\mathrm{send}}$ sending window (bytes); $\mathrm{cwnd}$ congestion window (network limit); $\mathrm{rwnd}$ advertised receive window (receiver limit); $\mathrm{FlightSize}$ bytes sent but not ACKed.
**Ideal window:** $W^*_{\mathrm{bits}}=B\times\mathrm{RTT}$, $W^*_{\mathrm{bytes}}=\dfrac{B\times\mathrm{RTT}}{8}$, $W^*_{\mathrm{pkts}}=\dfrac{B\times\mathrm{RTT}}{8\times\mathrm{MSS}_{\mathrm{bytes}}}$. With queue: $W^*_{\mathrm{bits}}=B\times\mathrm{RTT}+B_{\mathrm{queue}}$.
$B$ bottleneck bandwidth (bits/s); $\mathrm{MSS}_{\mathrm{bytes}}$ max segment size (bytes); $B_{\mathrm{queue}}$ queue capacity (bits). If $B$ is in bytes/s, omit the $/8$.
#### Four network delays
$d_{\mathrm{prop}}=\dfrac{d}{v}$, $d_{\mathrm{trans}}=\dfrac{L}{C}$, $d_{\mathrm{queue}}=\dfrac{Q}{C}=\dfrac{N_qL}{C}$, $d_{\mathrm{total}}=d_{\mathrm{prop}}+d_{\mathrm{trans}}+d_{\mathrm{queue}}$, $\mathrm{RTT}\approx2(d_{\mathrm{prop}}+d_{\mathrm{trans}}+d_{\mathrm{queue}})$ (symmetric path, negligible reverse queueing).
$d$ link length (m); $v$ propagation speed (m/s); $L$ packet size (bits); $C$ link bandwidth (bits/s); $Q$ bits ahead in queue; $N_q$ packets ahead. Processing delay is ignored in this course.
#### AIAD, MIAD, AIMD, MIMD
AIAD: $\mathrm{cwnd}\leftarrow\mathrm{cwnd}+a$, loss $\mathrm{cwnd}\leftarrow\mathrm{cwnd}-d$.
MIAD: $\mathrm{cwnd}\leftarrow\mathrm{cwnd}\cdot m$, loss $\mathrm{cwnd}\leftarrow\mathrm{cwnd}-d$.
AIMD: $\mathrm{cwnd}\leftarrow\mathrm{cwnd}+a$, loss $\mathrm{cwnd}\leftarrow\mathrm{cwnd}\cdot\beta$.
MIMD: $\mathrm{cwnd}\leftarrow\mathrm{cwnd}\cdot m$, loss $\mathrm{cwnd}\leftarrow\mathrm{cwnd}\cdot\beta$.
$a$ additive increase (usually $1$ MSS); $d$ additive decrease; $m>1$ multiplicative increase; $0<\beta<1$ multiplicative decrease. TCP uses AIMD; slow start → congestion avoidance → loss → repeat gives the **TCP sawtooth**.
#### TCP Reno mechanics
Initial $\mathrm{cwnd}_0=4\,\mathrm{MSS}$, $\mathrm{ssthresh}$ large.
**Slow start:** per ACK $\mathrm{cwnd}\leftarrow\mathrm{cwnd}+\mathrm{MSS}$ → doubles per RTT; stop at $\mathrm{cwnd}\ge\mathrm{ssthresh}$.
**Congestion avoidance:** per RTT $\mathrm{cwnd}\leftarrow\mathrm{cwnd}+\mathrm{MSS}$; per ACK $\mathrm{cwnd}\leftarrow\mathrm{cwnd}+\mathrm{MSS}^2/\mathrm{cwnd}$.
**3 duplicate ACKs:** $\mathrm{ssthresh}\leftarrow\max(\mathrm{cwnd}/2,2\mathrm{MSS})$; retransmit; $\mathrm{cwnd}\leftarrow\mathrm{ssthresh}+3\mathrm{MSS}$; each extra dup ACK $\mathrm{cwnd}\leftarrow\mathrm{cwnd}+\mathrm{MSS}$; new ACK $\mathrm{cwnd}\leftarrow\mathrm{ssthresh}$ → congestion avoidance.
**Timeout:** $\mathrm{ssthresh}\leftarrow\mathrm{cwnd}/2$, $\mathrm{cwnd}\leftarrow1\mathrm{MSS}$ → slow start.
State flow: slow start →( $\mathrm{cwnd}>\mathrm{ssthresh}$ )→ congestion avoidance; slow start or CA →(3 dup ACKs)→ fast recovery; fast recovery →(new ACK)→ CA; any state →(timeout)→ slow start.
#### Four properties of a good CCA
**Efficiency:** uses available bandwidth; **Fairness:** fair share among flows; **Convergence:** settles to fair/efficient allocation without oscillating; **Distributedness:** works end-to-end without network cooperation.
#### Fairness and throughput formulas
**Jain:** $F(\mathbf{x})=\dfrac{(\sum_{i=1}^n x_i)^2}{n\sum_{i=1}^n x_i^2}$; $F=1$ perfectly fair, smaller = less fair; $x_i$ flow $i$ allocation; $n$ number of flows.
**Mathis:** $BW<\dfrac{\mathrm{MSS}}{\mathrm{RTT}}\cdot\dfrac{1}{\sqrt{p}}$; $BW$ throughput; $\mathrm{MSS}$ max segment size (bytes); $\mathrm{RTT}$ round-trip time; $p$ packet loss probability.
**Average TCP:** $\overline{BW}\approx\dfrac{3W}{4\,\mathrm{RTT}}$; $W$ window at loss (bytes); average in-flight window is $3W/4$.
**CUBIC:** $W_{\mathrm{cubic}}(t)=C(t-K)^3+W_{\max}$, $K=\sqrt[3]{\dfrac{W_{\max}\beta}{C}}$; $W_{\max}$ cwnd before last loss; $t$ time since last reduction; $C$ scaling constant; $\beta$ decrease factor ($\approx0.8$); $K$ time to return to $W_{\max}$.
#### Max-min fairness
$a_i=\min(f,r_i)$, $\sum_{i=1}^n a_i=C$, where $f$ is the unique value satisfying the sum.
$a_i$ allocation to flow $i$; $r_i$ demand; $C$ total capacity; $f$ fair-share level. Flows with $r_i<f$ get full demand; the rest get $f$. Max-min is work-conserving (never idle while work waits).
#### Fairness / scheduling algorithms
**FCFS:** service in arrival order; in overload with equal packet sizes, $\text{share}_i\approx\lambda_i/\sum_j\lambda_j$; $\lambda_i$ arrival rate; aggressive senders get more.
**Water-filling:** $a_i=\min(f,r_i)$, $\sum_i a_i=C$; pour capacity equally into unsatisfied buckets, remove full buckets, continue.
**Round robin:** equal turns, $\text{turn}_i=1/n$; with one packet of size $L_i$ per round, $\text{byte share}_i=L_i/\sum_jL_j$; $L_i$ packet size; large packets get more bytes per turn.
**WFQ:** $F_{q,i}=S_{q,i}+p_{q,i}\dfrac{\sum_jw_j}{w_q}$; long-run $\text{share}_q\approx w_q/\sum_jw_j$; $F$ virtual finish, $S$ virtual start, $p$ packet bits, $w_q$ queue weight; higher weight → served more.
**Token bucket:** $A(t)=b+rt$, $T(t+\Delta t)=\min(b,T(t)+r\Delta t)$; $T$ tokens, $r$ token rate, $b$ burst capacity; average $\le r$, burst $\le b$.
#### Multiple flows: network calculus
$A_i(t)=b_i+r_it$; $A(t)=\sum_iA_i(t)=\sum_ib_i+(\sum_ir_i)t$; $S(t)=C_st$; backlog$(t)=\max(0,A(t)-S(t))$.
$b_i$ burst of flow $i$ (bits); $r_i$ average rate (bits/s); $C_s$ router service rate (bits/s). Vertical gap $A-S$ = worst-case backlog; horizontal gap = queueing delay; drain time $t_q$ solves $A(t_q)=S(t_q)$.
**Example:** two flows $r_1=10$ bps, $b_1=2$ bits; $r_2=10$ bps, $b_2=10$ bits → $A(t)=20t+12$, $S(t)=30t$; $30t=20t+12$ → $t=1.2$ s.