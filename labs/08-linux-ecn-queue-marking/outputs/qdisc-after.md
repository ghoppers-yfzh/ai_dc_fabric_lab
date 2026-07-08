# qdisc after traffic
```text
qdisc htb 1: root refcnt 41 r2q 10 default 0x10 direct_packets_stat 0 direct_qlen 1000
 Sent 12542552 bytes 8317 pkt (dropped 14, overlimits 6309 requeues 0) 
 backlog 4205b 8p requeues 0
qdisc red 10: parent 1:10 limit 100000b min 10000b max 30000b ecn 
 Sent 12542552 bytes 8317 pkt (dropped 14, overlimits 1200 requeues 0) 
 backlog 4205b 8p requeues 0
  marked 1188 early 12 pdrop 2 other 0 
```
