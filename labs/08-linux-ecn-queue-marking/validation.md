# Lab 08 Validation - Linux ECN and Queue Marking

## Purpose

This validation records the result of the Linux ECN and queue marking experiment.

The goal is to observe queue behavior and ECN-related packet fields in a local Linux namespace topology.

This lab does not validate real RoCEv2, PFC, or DCQCN behavior.

## Topology

```text
ecn-client 10.10.1.1
    |
ecn-router 10.10.1.254 / 10.10.2.254
    |
ecn-server 10.10.2.2
```

Congestion marking is configured on:

```text
ecn-router r-eth1
```

## Setup Command

```bash
sudo bash scripts/01-setup-netns.sh
```

Expected result:

```text
network namespaces created
veth links created
IP addresses configured
routes configured
IP forwarding enabled on router namespace
TCP ECN enabled in client and server namespaces
tc qdisc configured on router egress interface
```

## Basic Traffic Test

```bash
sudo bash scripts/02-run-traffic.sh
```

Expected result:

```text
iperf3 server starts in ecn-server namespace
iperf3 client runs from ecn-client namespace
traffic crosses ecn-router namespace
qdisc counters are saved before and after traffic
```

Expected output files:

```text
outputs/qdisc-before.md
outputs/qdisc-after.md
outputs/iperf3-client.txt
```

## ECN Capture Test

```bash
sudo bash scripts/03-capture-ecn.sh
```

Expected output files:

```text
outputs/ecn-r-eth1.pcap
outputs/ecn-summary.md
```

## ECN Summary

After running the capture script, review:

```bash
cat outputs/ecn-summary.md
```

Record observed result:

```text
Total captured IP packets:
ECN-capable packets:
Congestion Experienced packets:
```

## Validation Notes

A successful lab should show:

```text
traffic successfully passed through the namespace topology
tc qdisc counters changed after traffic
pcap was created
ECN packet counting commands completed
```

CE-marked packets may or may not appear depending on kernel behavior, traffic pressure, and qdisc thresholds.

If no CE packets appear, record that result and adjust traffic or queue thresholds in a later test.

## Cleanup

```bash
sudo bash scripts/99-cleanup.sh
```

Expected result:

```text
iperf3 processes stopped
network namespaces deleted
temporary lab state removed
```

## Result

Fill this section after running the lab.

```text
Setup:
Traffic test:
Packet capture:
ECN-capable packet count:
CE packet count:
Overall result:
```
