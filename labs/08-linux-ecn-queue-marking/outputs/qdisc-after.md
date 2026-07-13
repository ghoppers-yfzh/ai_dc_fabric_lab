# qdisc after traffic
```text
qdisc htb 1: root refcnt 41 r2q 10 default 0x10 direct_packets_stat 0 direct_qlen 1000
 Sent 12547617 bytes 8338 pkt (dropped 10, overlimits 6471 requeues 0) 
 backlog 0b 0p requeues 0
qdisc red 10: parent 1:10 limit 100000b min 10000b max 30000b ecn 
 Sent 12547617 bytes 8338 pkt (dropped 10, overlimits 1243 requeues 0) 
 backlog 0b 0p requeues 0
  marked 1235 early 8 pdrop 2 other 0 
```
