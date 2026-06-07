# Anycast Gateway ARP and Neighbor State

## Host neighbor tables

### host1
192.168.10.14 dev eth1 lladdr aa:c1:ab:b3:02:e7 REACHABLE 
192.168.10.12 dev eth1 lladdr aa:c1:ab:d2:3c:69 REACHABLE 
192.168.10.13 dev eth1 lladdr aa:c1:ab:66:6c:18 REACHABLE 
192.168.10.1 dev eth1 lladdr 00:00:00:00:10:01 REACHABLE 

### host2
192.168.10.1 dev eth1 lladdr 00:00:00:00:10:01 REACHABLE 
192.168.10.11 dev eth1 lladdr aa:c1:ab:a4:79:5f REACHABLE 

### host3
192.168.10.1 dev eth1 lladdr 00:00:00:00:10:01 REACHABLE 
192.168.10.11 dev eth1 lladdr aa:c1:ab:a4:79:5f REACHABLE 

### host4
192.168.10.1 dev eth1 lladdr 00:00:00:00:10:01 REACHABLE 
192.168.10.11 dev eth1 lladdr aa:c1:ab:a4:79:5f REACHABLE 

## Leaf bridge FDB tables

### leaf1 bridge fdb
33:33:00:00:00:01 dev eth0 self permanent
01:00:5e:00:00:01 dev eth0 self permanent
33:33:ff:00:00:04 dev eth0 self permanent
33:33:ff:7f:2d:bd dev eth0 self permanent
33:33:00:00:00:01 dev br10 self permanent
01:00:5e:00:00:6a dev br10 self permanent
33:33:00:00:00:6a dev br10 self permanent
01:00:5e:00:00:01 dev br10 self permanent
33:33:ff:c0:5b:82 dev br10 self permanent
00:00:00:00:10:01 dev br10 vlan 1 master br10 permanent
00:00:00:00:10:01 dev br10 master br10 permanent
7a:19:9b:cd:cb:01 dev vxlan10010 master br10 
aa:c1:ab:d2:3c:69 dev vxlan10010 vlan 1 extern_learn master br10 
22:89:3e:c9:a4:d0 dev vxlan10010 master br10 
92:e8:8f:9f:27:56 dev vxlan10010 master br10 
aa:c1:ab:d2:3c:69 dev vxlan10010 extern_learn master br10 
aa:c1:ab:b3:02:e7 dev vxlan10010 vlan 1 extern_learn master br10 
aa:c1:ab:b3:02:e7 dev vxlan10010 extern_learn master br10 
aa:c1:ab:66:6c:18 dev vxlan10010 vlan 1 extern_learn master br10 
aa:c1:ab:66:6c:18 dev vxlan10010 extern_learn master br10 
f6:4d:71:0a:f7:5e dev vxlan10010 vlan 1 master br10 permanent
f6:4d:71:0a:f7:5e dev vxlan10010 master br10 permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.3 self permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.4 self permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.2 self permanent
aa:c1:ab:b3:02:e7 dev vxlan10010 dst 10.255.1.4 self extern_learn 
aa:c1:ab:66:6c:18 dev vxlan10010 dst 10.255.1.3 self extern_learn 
aa:c1:ab:d2:3c:69 dev vxlan10010 dst 10.255.1.2 self extern_learn 
33:33:00:00:00:01 dev eth1 self permanent
01:00:5e:00:00:01 dev eth1 self permanent
33:33:ff:27:54:ee dev eth1 self permanent
33:33:00:00:00:01 dev eth2 self permanent
01:00:5e:00:00:01 dev eth2 self permanent
33:33:ff:41:e9:f9 dev eth2 self permanent
aa:c1:ab:a4:79:5f dev eth3 master br10 
aa:c1:ab:9b:aa:2d dev eth3 vlan 1 master br10 permanent
aa:c1:ab:9b:aa:2d dev eth3 master br10 permanent
33:33:00:00:00:01 dev eth3 self permanent
01:00:5e:00:00:01 dev eth3 self permanent
33:33:ff:9b:aa:2d dev eth3 self permanent

### leaf2 bridge fdb
33:33:00:00:00:01 dev eth0 self permanent
01:00:5e:00:00:01 dev eth0 self permanent
33:33:ff:00:00:0b dev eth0 self permanent
33:33:ff:d6:0d:0d dev eth0 self permanent
33:33:00:00:00:01 dev br10 self permanent
01:00:5e:00:00:6a dev br10 self permanent
33:33:00:00:00:6a dev br10 self permanent
01:00:5e:00:00:01 dev br10 self permanent
33:33:ff:da:ec:f6 dev br10 self permanent
00:00:00:00:10:01 dev br10 vlan 1 master br10 permanent
00:00:00:00:10:01 dev br10 master br10 permanent
f6:4d:71:0a:f7:5e dev vxlan10010 master br10 
22:89:3e:c9:a4:d0 dev vxlan10010 master br10 
7a:19:9b:cd:cb:01 dev vxlan10010 master br10 
aa:c1:ab:a4:79:5f dev vxlan10010 vlan 1 extern_learn master br10 
aa:c1:ab:a4:79:5f dev vxlan10010 extern_learn master br10 
aa:c1:ab:b3:02:e7 dev vxlan10010 vlan 1 extern_learn master br10 
aa:c1:ab:b3:02:e7 dev vxlan10010 extern_learn master br10 
aa:c1:ab:66:6c:18 dev vxlan10010 vlan 1 extern_learn master br10 
aa:c1:ab:66:6c:18 dev vxlan10010 extern_learn master br10 
92:e8:8f:9f:27:56 dev vxlan10010 vlan 1 master br10 permanent
92:e8:8f:9f:27:56 dev vxlan10010 master br10 permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.3 self permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.4 self permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.1 self permanent
aa:c1:ab:a4:79:5f dev vxlan10010 dst 10.255.1.1 self extern_learn 
aa:c1:ab:b3:02:e7 dev vxlan10010 dst 10.255.1.4 self extern_learn 
aa:c1:ab:66:6c:18 dev vxlan10010 dst 10.255.1.3 self extern_learn 
33:33:00:00:00:01 dev eth2 self permanent
01:00:5e:00:00:01 dev eth2 self permanent
33:33:ff:e7:18:8c dev eth2 self permanent
33:33:00:00:00:01 dev eth1 self permanent
01:00:5e:00:00:01 dev eth1 self permanent
33:33:ff:d6:c3:f2 dev eth1 self permanent
aa:c1:ab:d2:3c:69 dev eth3 master br10 
aa:c1:ab:f0:e2:d0 dev eth3 vlan 1 master br10 permanent
aa:c1:ab:f0:e2:d0 dev eth3 master br10 permanent
33:33:00:00:00:01 dev eth3 self permanent
01:00:5e:00:00:01 dev eth3 self permanent
33:33:ff:f0:e2:d0 dev eth3 self permanent

### leaf3 bridge fdb
33:33:00:00:00:01 dev eth0 self permanent
01:00:5e:00:00:01 dev eth0 self permanent
33:33:ff:00:00:02 dev eth0 self permanent
33:33:ff:c1:dd:80 dev eth0 self permanent
33:33:00:00:00:01 dev br10 self permanent
01:00:5e:00:00:6a dev br10 self permanent
33:33:00:00:00:6a dev br10 self permanent
01:00:5e:00:00:01 dev br10 self permanent
33:33:ff:cd:d3:9e dev br10 self permanent
00:00:00:00:10:01 dev br10 vlan 1 master br10 permanent
00:00:00:00:10:01 dev br10 master br10 permanent
aa:c1:ab:d2:3c:69 dev vxlan10010 vlan 1 extern_learn master br10 
22:89:3e:c9:a4:d0 dev vxlan10010 master br10 
f6:4d:71:0a:f7:5e dev vxlan10010 master br10 
aa:c1:ab:d2:3c:69 dev vxlan10010 extern_learn master br10 
aa:c1:ab:a4:79:5f dev vxlan10010 vlan 1 extern_learn master br10 
aa:c1:ab:a4:79:5f dev vxlan10010 extern_learn master br10 
92:e8:8f:9f:27:56 dev vxlan10010 master br10 
aa:c1:ab:b3:02:e7 dev vxlan10010 vlan 1 extern_learn master br10 
aa:c1:ab:b3:02:e7 dev vxlan10010 extern_learn master br10 
7a:19:9b:cd:cb:01 dev vxlan10010 vlan 1 master br10 permanent
7a:19:9b:cd:cb:01 dev vxlan10010 master br10 permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.4 self permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.1 self permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.2 self permanent
aa:c1:ab:a4:79:5f dev vxlan10010 dst 10.255.1.1 self extern_learn 
aa:c1:ab:b3:02:e7 dev vxlan10010 dst 10.255.1.4 self extern_learn 
aa:c1:ab:d2:3c:69 dev vxlan10010 dst 10.255.1.2 self extern_learn 
33:33:00:00:00:01 dev eth1 self permanent
01:00:5e:00:00:01 dev eth1 self permanent
33:33:ff:1c:f8:07 dev eth1 self permanent
33:33:00:00:00:01 dev eth2 self permanent
01:00:5e:00:00:01 dev eth2 self permanent
33:33:ff:63:fb:52 dev eth2 self permanent
aa:c1:ab:66:6c:18 dev eth3 master br10 
aa:c1:ab:f7:17:64 dev eth3 vlan 1 master br10 permanent
aa:c1:ab:f7:17:64 dev eth3 master br10 permanent
33:33:00:00:00:01 dev eth3 self permanent
01:00:5e:00:00:01 dev eth3 self permanent
33:33:ff:f7:17:64 dev eth3 self permanent

### leaf4 bridge fdb
33:33:00:00:00:01 dev eth0 self permanent
33:33:ff:00:00:03 dev eth0 self permanent
01:00:5e:00:00:01 dev eth0 self permanent
33:33:ff:3f:57:4d dev eth0 self permanent
33:33:00:00:00:01 dev br10 self permanent
01:00:5e:00:00:6a dev br10 self permanent
33:33:00:00:00:6a dev br10 self permanent
01:00:5e:00:00:01 dev br10 self permanent
33:33:ff:81:2b:8b dev br10 self permanent
00:00:00:00:10:01 dev br10 vlan 1 master br10 permanent
00:00:00:00:10:01 dev br10 master br10 permanent
7a:19:9b:cd:cb:01 dev vxlan10010 master br10 
aa:c1:ab:d2:3c:69 dev vxlan10010 vlan 1 extern_learn master br10 
f6:4d:71:0a:f7:5e dev vxlan10010 master br10 
aa:c1:ab:d2:3c:69 dev vxlan10010 extern_learn master br10 
aa:c1:ab:a4:79:5f dev vxlan10010 vlan 1 extern_learn master br10 
aa:c1:ab:a4:79:5f dev vxlan10010 extern_learn master br10 
92:e8:8f:9f:27:56 dev vxlan10010 master br10 
aa:c1:ab:66:6c:18 dev vxlan10010 vlan 1 extern_learn master br10 
aa:c1:ab:66:6c:18 dev vxlan10010 extern_learn master br10 
22:89:3e:c9:a4:d0 dev vxlan10010 vlan 1 master br10 permanent
22:89:3e:c9:a4:d0 dev vxlan10010 master br10 permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.3 self permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.1 self permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.2 self permanent
aa:c1:ab:a4:79:5f dev vxlan10010 dst 10.255.1.1 self extern_learn 
aa:c1:ab:66:6c:18 dev vxlan10010 dst 10.255.1.3 self extern_learn 
aa:c1:ab:d2:3c:69 dev vxlan10010 dst 10.255.1.2 self extern_learn 
33:33:00:00:00:01 dev eth1 self permanent
01:00:5e:00:00:01 dev eth1 self permanent
33:33:ff:d5:98:04 dev eth1 self permanent
33:33:00:00:00:01 dev eth2 self permanent
01:00:5e:00:00:01 dev eth2 self permanent
33:33:ff:ea:c6:28 dev eth2 self permanent
aa:c1:ab:b3:02:e7 dev eth3 master br10 
aa:c1:ab:16:21:75 dev eth3 vlan 1 master br10 permanent
aa:c1:ab:16:21:75 dev eth3 master br10 permanent
33:33:00:00:00:01 dev eth3 self permanent
01:00:5e:00:00:01 dev eth3 self permanent
33:33:ff:16:21:75 dev eth3 self permanent
