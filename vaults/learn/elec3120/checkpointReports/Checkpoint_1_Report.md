## Introduction

This report explores the effects of _file size_, _bandwidth_, and _delay_ on file transmission time. The experimental results will be compared with theoretical predictions to evaluate how each variable influences transmission time.

---
## Hypothesis

Given the formula for transmit time calculation ${}Packet Delay = (Data Size ÷ Link Bandwidth) + Link Latency{}$, then: 
- *File Size:* Total transmission time will increase proportionally to file size.
- *Bandwidth:* Total transmission time will decrease inversely proportional to bandwidth.
- *Delay:* An increase in link delay will cause a linear, scaled increase in total transmission time due to the effect of multiple TCP Round-Trip Times required.
---
## Experiments

The effects of each variable will be determined by keeping the other two variables constant while making small, incremental changes to the variable being investigated. In this section, three experiments will be conducted, with each experiment focusing on one of the three variables.

<div style="page-break-after: always;"></div>


### Test 1: File size as Independent Variable

- Bandwidth = 10Mbps
- Delay = 10ms

| Size      | 1KB | 5KB | 25KB | 100KB | 1MB | 10MB |
| --------- | --- | --- | ---- | ----- | --- | ---- |
| Time (ms) | 118 | 119 | 139  | 199   | 763 | 8212 |
![[Pasted image 20260916031241.png]]

The plot shows that transmission time increases as file size increases. The x-axis is **file size**, and the y-axis is **transmission time (ms)**. With bandwidth and delay held constant, the measurements show a clear *increasing trend*, with no major outliers. Overall, the results support the expected relationship between file size and transmission time.

<div style="page-break-after: always;"></div>


### Test 2: Bandwidth as Independent Variable

- Delay = 10ms
- File size = 1MB

| Bandwidth (Mbps) | 1    | 5    | 10  | 20  |
| ---------------- | ---- | ---- | --- | --- |
| Time (ms)        | 7967 | 1014 | 729 | 404 |
![[Pasted image 20260916031257.png]]

The plot shows that transmission time decreases as bandwidth increases. The x-axis is **bandwidth (Mbps)**, and the y-axis is **transmission time (ms)**. With file size and delay held constant, the measurements show a clear *decreasing trend* with no major outliers. Overall, the results support the expected inverse relationship between bandwidth and transmission time.

<div style="page-break-after: always;"></div>


### Test 3: Delay Time as Independent Variable

- Bandwidth = 10Mbps
- Filesize = 1MB

| Delay (ms) | 0   | 5   | 10  | 20   | 50   | 100  |
| ---------- | --- | --- | --- | ---- | ---- | ---- |
| Time (ms)  | 269 | 501 | 785 | 1157 | 1492 | 2614 |
![[Pasted image 20260916034455.png]]

The plot shows that transmission time increases as link delay increases. The x-axis is **link delay (ms)**, and the y-axis is **transmission time (ms)**. With file size and bandwidth held constant, the measurements show an approximately *linear increasing trend* with only small deviations. Overall, the results support the expected relationship between delay and transmission time.

<div style="page-break-after: always;"></div>


## Conclusion

The experimental results generally match the theoretical predictions for the effects of file size, bandwidth, and link delay. The only discrepancies occurred in the Transmission Time vs. Link Delay experiment, where there were a few small, localized deviations from the predicted values. However, the overall linear trend remained consistent with the theoretical model. These minor differences were likely caused by system fluctuations and measurement variability. Since the overall experimental trends agree with the predictions, the results support the validity of the underlying theoretical model.