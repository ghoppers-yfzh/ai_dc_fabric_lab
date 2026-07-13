# Lab 08 ECN Capture Summary

## Packet Counts

```text
Total IPv4 packets: 13654
Not-ECT packets: 6575
ECT(0) packets: 3542
ECT(1) packets: 0
ECN-capable packets: 7079
Congestion Experienced packets: 3537
```

## Router qdisc Counters

```text
qdisc htb 1: root refcnt 41 r2q 10 default 0x10 direct_packets_stat 0 direct_qlen 1000
 Sent 23869454 bytes 15856 pkt (dropped 57, overlimits 13584 requeues 0) 
 backlog 0b 0p requeues 0
qdisc red 10: parent 1:10 limit 100000b min 10000b max 30000b ecn 
 Sent 23869454 bytes 15856 pkt (dropped 57, overlimits 4827 requeues 0) 
 backlog 0b 0p requeues 0
  marked 4784 early 43 pdrop 14 other 0 
```

## Files

```text
/home/yifan/ai_dc_fabric_lab/labs/08-linux-ecn-queue-marking/outputs/ecn-r-eth1.pcap
/home/yifan/ai_dc_fabric_lab/labs/08-linux-ecn-queue-marking/outputs/iperf3-capture-client.txt
```
