# Lab 08 ECN Capture Summary

## Packet Counts

```text
Total IPv4 packets: 13936
Not-ECT packets: 6748
ECT(0) packets: 3491
ECT(1) packets: 0
ECN-capable packets: 7188
Congestion Experienced packets: 3697
```

## Router qdisc Counters

```text
qdisc htb 1: root refcnt 41 r2q 10 default 0x10 direct_packets_stat 0 direct_qlen 1000
 Sent 23867090 bytes 15842 pkt (dropped 66, overlimits 13537 requeues 0) 
 backlog 0b 0p requeues 0
qdisc red 10: parent 1:10 limit 100000b min 10000b max 30000b ecn 
 Sent 23867090 bytes 15842 pkt (dropped 66, overlimits 4949 requeues 0) 
 backlog 0b 0p requeues 0
  marked 4897 early 52 pdrop 14 other 0 
```

## Files

```text
/home/yifan/ai_dc_fabric_lab/labs/08-linux-ecn-queue-marking/outputs/ecn-r-eth1.pcap
/home/yifan/ai_dc_fabric_lab/labs/08-linux-ecn-queue-marking/outputs/iperf3-capture-client.txt
```
