# Lab 08 - Linux ECN and Queue Marking Exploration

## Purpose

This lab studies ECN and queue marking behavior with Linux tools.

It is designed as a local, reproducible experiment before going deeper into RoCEv2, PFC, ECN, and DCQCN.

This lab does **not** validate real RoCEv2 behavior.

It does **not** require RDMA NICs, GPU servers, or physical switches.

The goal is to understand:

```text
how congestion can be signaled by marking instead of dropping
how ECN bits appear in packets
how Linux traffic control can simulate a congested queue
how this concept connects to RoCEv2 congestion management
```

## What This Lab Can Prove

This lab can show:

```text
Linux network namespaces can be used to build a small routed topology
traffic can be rate-limited to create queue pressure
ECN-capable traffic can be observed with tcpdump
tc qdisc counters can show queue behavior
packet ECN bits can be counted from a pcap
```

## What This Lab Cannot Prove

This lab cannot prove:

```text
real RoCEv2 RDMA behavior
PFC pause frame behavior
DCQCN NIC-side congestion control
real switch ASIC buffer behavior
real GPU training workload performance
```

Those require physical RDMA-capable NICs, switch support, and real workloads.

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

A rate-limited queue with ECN marking is applied on the router egress interface toward the server.

## Directory Structure

```text
labs/08-linux-ecn-queue-marking/
├── README.md
├── notes.md
├── validation.md
├── scripts/
│   ├── 01-setup-netns.sh
│   ├── 02-run-traffic.sh
│   ├── 03-capture-ecn.sh
│   └── 99-cleanup.sh
└── outputs/
```

## Requirements

Run on a Linux host with:

```text
iproute2
tc
iperf3
tcpdump
sudo or root access
```

Check tools:

```bash
which ip
which tc
which iperf3
which tcpdump
```

## Workflow

From the repo root:

```bash
cd labs/08-linux-ecn-queue-marking
```

Create the network namespace topology:

```bash
sudo bash scripts/01-setup-netns.sh
```

Run a basic traffic test:

```bash
sudo bash scripts/02-run-traffic.sh
```

Run traffic with packet capture and ECN summary:

```bash
sudo bash scripts/03-capture-ecn.sh
```

Clean up:

```bash
sudo bash scripts/99-cleanup.sh
```

## Expected Outputs

The scripts write output files under:

```text
outputs/
```

Expected files:

```text
outputs/qdisc-before.md
outputs/qdisc-after.md
outputs/iperf3-client.txt
outputs/ecn-r-eth1.pcap
outputs/ecn-summary.md
```

## Main Commands Used

### Network Namespace

```bash
ip netns add ecn-client
ip netns add ecn-router
ip netns add ecn-server
```

### Traffic Control

```bash
tc qdisc show dev r-eth1
tc -s qdisc show dev r-eth1
```

### Packet Capture

```bash
tcpdump -i r-eth1 -nn -vvv -w outputs/ecn-r-eth1.pcap ip
```

### ECN Bit Counting

IPv4 ECN bits are the lowest two bits of the DS field.

Example tcpdump filters:

```bash
tcpdump -r outputs/ecn-r-eth1.pcap -nn 'ip[1] & 0x03 != 0'
tcpdump -r outputs/ecn-r-eth1.pcap -nn 'ip[1] & 0x03 == 3'
```

## Relationship to RoCEv2 Learning

RoCEv2 uses UDP/IP and relies heavily on careful congestion management.

In real AI Ethernet fabrics, ECN marking is used with NIC-side congestion control such as DCQCN.

This lab does not implement DCQCN.

Instead, it gives a practical packet-level view of ECN marking, which is a building block for understanding RoCEv2 congestion behavior.
