# Static VXLAN Data Plane Test

## leaf1 bridge links
530: eth3@if531: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 master br10 state forwarding priority 32 cost 2 
4: vxlan10010: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master br10 state forwarding priority 32 cost 100 

## leaf1 FDB
33:33:00:00:00:01 dev eth0 self permanent
33:33:ff:00:00:04 dev eth0 self permanent
01:00:5e:00:00:01 dev eth0 self permanent
33:33:ff:a8:b4:4a dev eth0 self permanent
33:33:00:00:00:01 dev br10 self permanent
01:00:5e:00:00:6a dev br10 self permanent
33:33:00:00:00:6a dev br10 self permanent
01:00:5e:00:00:01 dev br10 self permanent
33:33:ff:80:76:07 dev br10 self permanent
aa:c1:ab:b8:5b:c7 dev vxlan10010 master br10 
12:43:4f:7c:48:71 dev vxlan10010 master br10 
1a:1d:42:92:58:94 dev vxlan10010 vlan 1 master br10 permanent
1a:1d:42:92:58:94 dev vxlan10010 master br10 permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.2 self permanent
aa:c1:ab:e9:33:82 dev eth3 master br10 
aa:c1:ab:f5:65:7b dev eth3 vlan 1 master br10 permanent
aa:c1:ab:f5:65:7b dev eth3 master br10 permanent
33:33:00:00:00:01 dev eth3 self permanent
01:00:5e:00:00:01 dev eth3 self permanent
33:33:ff:f5:65:7b dev eth3 self permanent
33:33:00:00:00:01 dev eth1 self permanent
01:00:5e:00:00:01 dev eth1 self permanent
33:33:ff:76:ba:93 dev eth1 self permanent
33:33:00:00:00:01 dev eth2 self permanent
01:00:5e:00:00:01 dev eth2 self permanent
33:33:ff:37:b1:8e dev eth2 self permanent

## leaf2 bridge links
537: eth3@if538: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 master br10 state forwarding priority 32 cost 2 
4: vxlan10010: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master br10 state forwarding priority 32 cost 100 

## leaf2 FDB
33:33:00:00:00:01 dev eth0 self permanent
33:33:ff:00:00:06 dev eth0 self permanent
01:00:5e:00:00:01 dev eth0 self permanent
33:33:ff:3e:fb:11 dev eth0 self permanent
33:33:00:00:00:01 dev br10 self permanent
01:00:5e:00:00:6a dev br10 self permanent
33:33:00:00:00:6a dev br10 self permanent
01:00:5e:00:00:01 dev br10 self permanent
33:33:ff:93:2c:c6 dev br10 self permanent
1a:1d:42:92:58:94 dev vxlan10010 master br10 
aa:c1:ab:e9:33:82 dev vxlan10010 master br10 
12:43:4f:7c:48:71 dev vxlan10010 vlan 1 master br10 permanent
12:43:4f:7c:48:71 dev vxlan10010 master br10 permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.1 self permanent
33:33:00:00:00:01 dev eth1 self permanent
01:00:5e:00:00:01 dev eth1 self permanent
33:33:ff:d5:a2:83 dev eth1 self permanent
aa:c1:ab:b8:5b:c7 dev eth3 master br10 
aa:c1:ab:a0:58:70 dev eth3 vlan 1 master br10 permanent
aa:c1:ab:a0:58:70 dev eth3 master br10 permanent
33:33:00:00:00:01 dev eth3 self permanent
01:00:5e:00:00:01 dev eth3 self permanent
33:33:ff:a0:58:70 dev eth3 self permanent
33:33:00:00:00:01 dev eth2 self permanent
01:00:5e:00:00:01 dev eth2 self permanent
33:33:ff:f3:7b:ef dev eth2 self permanent

## host1 to host2 ping
PING 192.168.10.12 (192.168.10.12) 56(84) bytes of data.
64 bytes from 192.168.10.12: icmp_seq=1 ttl=64 time=0.173 ms
64 bytes from 192.168.10.12: icmp_seq=2 ttl=64 time=0.136 ms
64 bytes from 192.168.10.12: icmp_seq=3 ttl=64 time=0.083 ms

--- 192.168.10.12 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2053ms
rtt min/avg/max/mdev = 0.083/0.130/0.173/0.036 ms
