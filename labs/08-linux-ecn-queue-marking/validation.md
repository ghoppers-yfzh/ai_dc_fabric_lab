# Lab 08 Validation - Linux ECN and Queue Marking

## Purpose

This validation records the result of the Linux ECN and queue marking experiment.

The goal of this lab is to observe how congestion can be signaled by ECN marking instead of relying only on packet drops.

This lab is a local Linux learning lab. It does **not** validate real RoCEv2, PFC, DCQCN, RDMA NIC behavior, switch ASIC buffer behavior, or GPU workload performance.

The focus is:

```text
traffic pressure
-> egress queue congestion
-> RED/ECN marking
-> ECN bits visible in packet capture
```

This is useful preparation for understanding RoCEv2 congestion management, where ECN marking is one of the key building blocks.

---

## Topology

```text
+-------------+        +-------------+        +-------------+
| ecn-client  |        | ecn-router  |        | ecn-server  |
| 10.10.1.1   |--------| 10.10.1.254 |        | 10.10.2.2   |
|             |        | 10.10.2.254 |--------|             |
+-------------+        +-------------+        +-------------+
      c-eth0              r-eth0/r-eth1             s-eth0
```

The router namespace forwards traffic between the client and server namespaces.

The congested queue is configured on:

```text
ecn-router r-eth1
```

This is the router egress interface toward the server.

Traffic direction tested:

```text
ecn-client -> ecn-router -> ecn-server
```

---

## Setup Command

```bash
sudo bash scripts/01-setup-netns.sh
```

## Setup Validation

Network namespaces were created successfully:

```text
ecn-server (id: 2)
ecn-router (id: 1)
ecn-client (id: 0)
```

Client routing table:

```text
default via 10.10.1.254 dev c-eth0
10.10.1.0/24 dev c-eth0 proto kernel scope link src 10.10.1.1
```

Router routing table:

```text
10.10.1.0/24 dev r-eth0 proto kernel scope link src 10.10.1.254
10.10.2.0/24 dev r-eth1 proto kernel scope link src 10.10.2.254
```

Server routing table:

```text
default via 10.10.2.254 dev s-eth0
10.10.2.0/24 dev s-eth0 proto kernel scope link src 10.10.2.2
```

The routing confirms:

```text
ecn-client uses ecn-router as default gateway.
ecn-router forwards between 10.10.1.0/24 and 10.10.2.0/24.
ecn-server uses ecn-router as default gateway.
```

---

## Initial qdisc State

Before running traffic:

```text
qdisc htb 1: root refcnt 41 r2q 10 default 0x10 direct_packets_stat 0 direct_qlen 1000
 Sent 1812 bytes 24 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0

qdisc red 10: parent 1:10 limit 100000b min 10000b max 30000b ecn
 Sent 1812 bytes 24 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
  marked 0 early 0 pdrop 0 other 0
```

Interpretation:

```text
The HTB and RED qdiscs were configured successfully.
No congestion had occurred yet.
No ECN marking had occurred yet.
No packets had been dropped.
```

---

## Basic Traffic Test

Command:

```bash
sudo bash scripts/02-run-traffic.sh
```

This script starts an iperf3 server in the `ecn-server` namespace and runs iperf3 traffic from the `ecn-client` namespace.

The traffic crosses the `ecn-router` namespace and exits toward the server through `r-eth1`.

---

## iperf3 Result

The test used four parallel TCP streams.

Final sender summary:

```text
[SUM]   0.00-20.00  sec  11.9 MBytes  4.98 Mbits/sec   46             sender
```

Final receiver summary:

```text
[SUM]   0.00-20.03  sec  11.1 MBytes  4.66 Mbits/sec                  receiver
```

Interpretation:

```text
Traffic successfully passed from ecn-client to ecn-server.
Throughput was limited by the artificial bottleneck on the router egress interface.
The sender reported 46 TCP retransmissions.
This is consistent with the qdisc output showing a small number of packet drops.
```

---

## qdisc State After Basic Traffic

After running iperf3:

```text
qdisc htb 1: root refcnt 41 r2q 10 default 0x10 direct_packets_stat 0 direct_qlen 1000
 Sent 12547617 bytes 8338 pkt (dropped 10, overlimits 6471 requeues 0)
 backlog 0b 0p requeues 0

qdisc red 10: parent 1:10 limit 100000b min 10000b max 30000b ecn
 Sent 12547617 bytes 8338 pkt (dropped 10, overlimits 1243 requeues 0)
 backlog 0b 0p requeues 0
  marked 1235 early 8 pdrop 2 other 0
```

Key observations:

```text
HTB overlimits: 6471
RED overlimits: 1243
RED marked packets: 1235
RED dropped packets: 10
RED early: 8
RED pdrop: 2
```

Interpretation:

```text
The HTB qdisc created an artificial bottleneck.
The RED qdisc detected queue pressure.
ECN marking occurred under congestion.
A small number of packets were still dropped.
```

Important point:

```text
ECN does not guarantee zero packet loss.
ECN provides a congestion signal before relying only on packet drops.
If pressure is high enough, drops can still occur.
```

---

## ECN Capture Test

Command:

```bash
sudo bash scripts/03-capture-ecn.sh
```

This script captured traffic on the router egress interface:

```text
ecn-router r-eth1
```

Output pcap:

```text
outputs/ecn-r-eth1.pcap
```

Summary file:

```text
outputs/ecn-summary.md
```

---

## Packet Capture Summary

Packet counts from the capture:

```text
Total IPv4 packets: 13654
Not-ECT packets: 6575
ECT(0) packets: 3542
ECT(1) packets: 0
ECN-capable packets: 7079
Congestion Experienced packets: 3537
```

Interpretation:

```text
The capture contained both ECN-capable packets and CE-marked packets.
ECT(0) packets show traffic that supports ECN.
CE packets show traffic that was marked as having experienced congestion.
```

---

## Router qdisc Counters During Capture

After the capture test:

```text
qdisc htb 1: root refcnt 41 r2q 10 default 0x10 direct_packets_stat 0 direct_qlen 1000
 Sent 23869454 bytes 15856 pkt (dropped 57, overlimits 13584 requeues 0)
 backlog 0b 0p requeues 0

qdisc red 10: parent 1:10 limit 100000b min 10000b max 30000b ecn
 Sent 23869454 bytes 15856 pkt (dropped 57, overlimits 4827 requeues 0)
 backlog 0b 0p requeues 0
  marked 4784 early 43 pdrop 14 other 0
```

Key observations:

```text
HTB overlimits: 13584
RED overlimits: 4827
RED marked packets: 4784
RED dropped packets: 57
RED early: 43
RED pdrop: 14
```

Interpretation:

```text
The qdisc counters confirm that traffic exceeded the configured shaping rate.
The RED qdisc marked thousands of packets with ECN.
A smaller number of packets were dropped.
```

---

## tcpdump Validation

Command to show all packets with ECN bits set:

```bash
tcpdump -r outputs/ecn-r-eth1.pcap -nn -vvv 'ip[1] & 0x03 != 0' | head -20
```

Example output:

```text
IP (tos 0x2,ECT(0), ttl 63, proto TCP (6), length 89)
    10.10.1.1.39770 > 10.10.2.2.5201
```

Interpretation:

```text
tos 0x2 = ECT(0)
This means the packet is ECN-capable.
The packet has not yet been marked as congested.
```

Command to show CE-marked packets:

```bash
tcpdump -r outputs/ecn-r-eth1.pcap -nn -vvv 'ip[1] & 0x03 == 3' | head -20
```

Example output:

```text
IP (tos 0x3,CE, ttl 63, proto TCP (6), length 7292)
    10.10.1.1.39808 > 10.10.2.2.5201
```

Interpretation:

```text
tos 0x3 = CE
CE means Congestion Experienced.
The packet was marked by the congested queue.
```

The message below may appear when piping tcpdump output into `head`:

```text
tcpdump: Unable to write output: Broken pipe
```

This is expected. It happens because `head` exits after reading the requested number of lines while `tcpdump` is still trying to write more output.

---

## ECN Bit Meaning

IPv4 ECN uses the lowest two bits of the DS field:

```text
00 = Not-ECT
01 = ECT(1)
10 = ECT(0)
11 = CE
```

Meaning:

```text
Not-ECT = packet does not indicate ECN support
ECT(0)  = packet is ECN-capable
ECT(1)  = packet is also ECN-capable
CE      = packet has been marked as Congestion Experienced
```

In this lab:

```text
ECT(0) packets were observed.
CE packets were observed.
ECT(1) packets were not observed.
```

This is normal. Many classic ECN examples use ECT(0).

The important transition is:

```text
ECT(0) -> CE
```

This means:

```text
The packet was ECN-capable when it entered the congested queue.
The queue marked it as Congestion Experienced.
```

---

## Result

```text
Setup: PASS
Basic traffic test: PASS
Packet capture: PASS
ECN-capable packet observation: PASS
CE-marked packet observation: PASS
Overall result: PASS
```

Summary:

```text
Total IPv4 packets captured: 13654
ECN-capable packets: 7079
ECT(0) packets: 3542
ECT(1) packets: 0
Congestion Experienced packets: 3537

RED marked packets from qdisc counter: 4784
RED dropped packets from qdisc counter: 57
iperf3 sender retransmissions: 46
```

---

## Final Interpretation

This lab successfully demonstrated ECN marking behavior in a controlled Linux namespace topology.

The experiment showed:

```text
traffic crossed a routed namespace topology
HTB created an artificial egress bottleneck
RED detected queue pressure
ECN-capable packets were observed
CE-marked packets were observed
qdisc counters showed ECN marking
a small number of drops and TCP retransmissions also occurred
```

The most important observation is:

```text
Packets can carry a congestion signal through ECN marking.
Congestion does not have to be signaled only by packet loss.
```

---

## Relationship to RoCEv2 Learning

This lab does not validate real RoCEv2 behavior.

It does not test:

```text
RDMA traffic
RoCEv2 packet forwarding
PFC pause frame behavior
DCQCN sender-side rate control
RDMA NIC counters
switch ASIC buffer behavior
GPU workload performance
```

However, it demonstrates one important building block used in RoCEv2 congestion management:

```text
queue congestion -> ECN marking
```

A simplified RoCEv2 congestion flow is:

```text
switch egress queue becomes congested
-> switch marks RoCEv2 packets with ECN CE
-> receiver/NIC generates congestion notification
-> sender NIC reduces sending rate through DCQCN
```

This lab only covers the first part:

```text
queue congestion -> ECN CE marking
```

That makes it useful preparation before studying:

```text
RoCEv2
PFC
ECN threshold tuning
DCQCN
RDMA counters
AI fabric congestion troubleshooting
```

---

## Cleanup

Command:

```bash
sudo bash scripts/99-cleanup.sh
```

Expected result:

```text
iperf3 processes stopped
network namespaces deleted
temporary lab state removed
```
