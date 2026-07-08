# Lab 08 Notes - Linux ECN and Queue Marking

## Why This Lab Exists

RoCEv2, PFC, ECN, and DCQCN are important AI data center networking topics.

However, a real RoCEv2 lab requires:

```text
RDMA-capable NICs
switches with PFC and ECN support
real queue and buffer behavior
RDMA test tools
```

This lab focuses on the part that can be studied locally:

```text
ECN marking and queue behavior
```

It uses Linux tools to create a controlled learning environment.

## ECN Basics

ECN means Explicit Congestion Notification.

Instead of dropping packets immediately when congestion begins, a network device can mark packets.

The IP header contains two ECN bits.

Common meanings:

```text
00 = Not ECN-Capable Transport
01 = ECT(1)
10 = ECT(0)
11 = Congestion Experienced
```

The important idea:

```text
drop = packet loss signal
mark = congestion signal before loss
```

For congestion-controlled transport, marking can be used as a signal to slow down before packet loss becomes severe.

## Why ECN Matters for RoCEv2

RoCEv2 carries RDMA over UDP/IP.

RDMA is sensitive to packet loss because it is designed for low-latency, high-throughput memory-to-memory communication.

In AI training or GPU cluster workloads, packet loss and congestion hot spots can have a large impact.

That is why RoCEv2 Ethernet fabrics often use:

```text
PFC to reduce loss for selected traffic classes
ECN to signal congestion
DCQCN on the NIC side to react to ECN marks
careful buffer and threshold tuning
```

## PFC vs ECN

PFC and ECN solve different problems.

PFC:

```text
pauses traffic per priority
tries to prevent packet loss
can create head-of-line blocking
can create pause storm risk
must be carefully scoped
```

ECN:

```text
marks packets during congestion
does not pause the link by itself
requires sender-side congestion response
helps avoid drops before queues overflow
```

For RoCEv2 designs, PFC and ECN are often used together.

## DCQCN

DCQCN stands for Data Center Quantized Congestion Notification.

At a high level:

```text
switch marks packets with ECN during congestion
receiver returns congestion notification
sender NIC reduces sending rate
rate later increases again if congestion clears
```

This lab does not implement DCQCN.

The lab only studies the ECN marking side.

## Lab Topology

The lab uses three Linux network namespaces:

```text
ecn-client
ecn-router
ecn-server
```

The router has two interfaces:

```text
r-eth0 toward client
r-eth1 toward server
```

Traffic from client to server crosses the router.

The congested queue is configured on:

```text
ecn-router r-eth1
```

This means the bottleneck is the router egress toward the server.

## Queue Configuration

The first version uses a simple Linux `tc` model:

```text
HTB for rate limiting
RED with ECN for marking
```

The idea is:

```text
limit egress bandwidth
create queue pressure
mark ECN-capable packets when queue threshold is crossed
```

This is a learning model, not a production switch configuration.

## Why tcpdump Is Used

`tcpdump` is used to capture packets on the router egress interface.

The pcap can be analyzed for ECN bits.

Useful filters:

```bash
ip[1] & 0x03 != 0
ip[1] & 0x03 == 3
```

Meaning:

```text
ip[1] & 0x03 != 0  -> packet has some ECN value
ip[1] & 0x03 == 3  -> packet is Congestion Experienced
```

## Expected Observations

Possible observations:

```text
iperf3 traffic crosses the routed namespace topology
tc qdisc counters increase
pcap contains ECN-capable packets
some packets may show CE marking depending on kernel/qdisc behavior and traffic pressure
```

If CE packets are not observed, that does not mean the lab failed completely.

It may mean the queue did not cross the RED marking threshold, TCP ECN negotiation did not happen, or the host kernel/qdisc behavior differs.

The validation should record the actual result honestly.

## Troubleshooting

### No iperf3

Install it:

```bash
sudo apt-get update
sudo apt-get install -y iperf3
```

### No tcpdump

Install it:

```bash
sudo apt-get install -y tcpdump
```

### No CE Packets Observed

Try:

```text
increase iperf3 parallel streams
increase test duration
reduce HTB rate
lower RED min/max thresholds
confirm tcp_ecn is enabled in client and server namespaces
```

### Namespace Already Exists

Run cleanup:

```bash
sudo bash scripts/99-cleanup.sh
```

Then run setup again.

## Key Learning

The key learning is not the exact number of ECN-marked packets.

The key learning is the workflow:

```text
build a controlled topology
create congestion pressure
capture packets
inspect ECN bits
compare counters before and after traffic
document what was observed
```

That workflow is directly relevant to AI fabric troubleshooting, even when the real environment uses hardware counters rather than Linux qdisc counters.
