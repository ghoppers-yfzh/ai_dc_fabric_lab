# qdisc before traffic
```text
qdisc htb 1: root refcnt 41 r2q 10 default 0x10 direct_packets_stat 0 direct_qlen 1000
 Sent 1014 bytes 13 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0
qdisc red 10: parent 1:10 limit 100000b min 10000b max 30000b ecn 
 Sent 1014 bytes 13 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0
  marked 0 early 0 pdrop 0 other 0 
```
