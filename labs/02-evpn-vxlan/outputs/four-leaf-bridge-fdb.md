]633;E;echo "# Four-Leaf Bridge and FDB State";fbf5a41f-2d56-4ae0-adfc-bae181e9a759]633;C# Four-Leaf Bridge and FDB State

## leaf1 bridge links
666: eth3@if665: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 master br10 state forwarding priority 32 cost 2 
4: vxlan10010: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9450 master br10 state forwarding priority 32 cost 2 

## leaf1 FDB
33:33:00:00:00:01 dev eth0 self permanent
33:33:ff:00:00:05 dev eth0 self permanent
01:00:5e:00:00:01 dev eth0 self permanent
33:33:ff:bf:f7:68 dev eth0 self permanent
33:33:00:00:00:01 dev br10 self permanent
01:00:5e:00:00:6a dev br10 self permanent
33:33:00:00:00:6a dev br10 self permanent
01:00:5e:00:00:01 dev br10 self permanent
33:33:ff:82:cb:74 dev br10 self permanent
aa:c1:ab:f6:40:5f dev vxlan10010 master br10 
e6:6b:5a:6e:6f:5d dev vxlan10010 master br10 
aa:c1:ab:05:4b:42 dev vxlan10010 master br10 
f6:d2:f4:03:32:3e dev vxlan10010 master br10 
ce:1b:c2:64:fc:f8 dev vxlan10010 master br10 
aa:c1:ab:57:31:a8 dev vxlan10010 master br10 
aa:c1:ab:59:5a:40 dev vxlan10010 vlan 1 extern_learn master br10 
aa:c1:ab:8f:be:bb dev vxlan10010 vlan 1 extern_learn master br10 
aa:c1:ab:8f:be:bb dev vxlan10010 extern_learn master br10 
aa:c1:ab:59:5a:40 dev vxlan10010 extern_learn master br10 
aa:c1:ab:b1:5f:e1 dev vxlan10010 vlan 1 extern_learn master br10 
aa:c1:ab:b1:5f:e1 dev vxlan10010 extern_learn master br10 
32:99:53:00:76:5a dev vxlan10010 vlan 1 master br10 permanent
32:99:53:00:76:5a dev vxlan10010 master br10 permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.3 self permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.2 self permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.4 self permanent
aa:c1:ab:8f:be:bb dev vxlan10010 dst 10.255.1.2 self extern_learn 
aa:c1:ab:b1:5f:e1 dev vxlan10010 dst 10.255.1.3 self extern_learn 
aa:c1:ab:59:5a:40 dev vxlan10010 dst 10.255.1.4 self extern_learn 
33:33:00:00:00:01 dev eth1 self permanent
01:00:5e:00:00:01 dev eth1 self permanent
33:33:ff:97:41:a4 dev eth1 self permanent
33:33:00:00:00:01 dev eth2 self permanent
01:00:5e:00:00:01 dev eth2 self permanent
33:33:ff:71:bf:32 dev eth2 self permanent
aa:c1:ab:8f:c2:9c dev eth3 master br10 
aa:c1:ab:aa:e8:93 dev eth3 vlan 1 master br10 permanent
aa:c1:ab:aa:e8:93 dev eth3 master br10 permanent
33:33:00:00:00:01 dev eth3 self permanent
01:00:5e:00:00:01 dev eth3 self permanent
33:33:ff:aa:e8:93 dev eth3 self permanent

## leaf2 bridge links
676: eth3@if675: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 master br10 state forwarding priority 32 cost 2 
4: vxlan10010: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9450 master br10 state forwarding priority 32 cost 2 

## leaf2 FDB
33:33:00:00:00:01 dev eth0 self permanent
01:00:5e:00:00:01 dev eth0 self permanent
33:33:ff:00:00:08 dev eth0 self permanent
33:33:ff:ce:da:85 dev eth0 self permanent
33:33:00:00:00:01 dev br10 self permanent
01:00:5e:00:00:6a dev br10 self permanent
33:33:00:00:00:6a dev br10 self permanent
01:00:5e:00:00:01 dev br10 self permanent
33:33:ff:7b:ba:1b dev br10 self permanent
e6:6b:5a:6e:6f:5d dev vxlan10010 master br10 
aa:c1:ab:05:4b:42 dev vxlan10010 master br10 
32:99:53:00:76:5a dev vxlan10010 master br10 
ce:1b:c2:64:fc:f8 dev vxlan10010 master br10 
aa:c1:ab:57:31:a8 dev vxlan10010 master br10 
aa:c1:ab:59:5a:40 dev vxlan10010 vlan 1 extern_learn master br10 
aa:c1:ab:59:5a:40 dev vxlan10010 extern_learn master br10 
aa:c1:ab:8f:c2:9c dev vxlan10010 vlan 1 extern_learn master br10 
aa:c1:ab:8f:c2:9c dev vxlan10010 extern_learn master br10 
aa:c1:ab:b1:5f:e1 dev vxlan10010 vlan 1 extern_learn master br10 
aa:c1:ab:b1:5f:e1 dev vxlan10010 extern_learn master br10 
f6:d2:f4:03:32:3e dev vxlan10010 vlan 1 master br10 permanent
f6:d2:f4:03:32:3e dev vxlan10010 master br10 permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.3 self permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.1 self permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.4 self permanent
aa:c1:ab:b1:5f:e1 dev vxlan10010 dst 10.255.1.3 self extern_learn 
aa:c1:ab:59:5a:40 dev vxlan10010 dst 10.255.1.4 self extern_learn 
aa:c1:ab:8f:c2:9c dev vxlan10010 dst 10.255.1.1 self extern_learn 
33:33:00:00:00:01 dev eth2 self permanent
01:00:5e:00:00:01 dev eth2 self permanent
33:33:ff:9c:a4:3b dev eth2 self permanent
33:33:00:00:00:01 dev eth1 self permanent
01:00:5e:00:00:01 dev eth1 self permanent
33:33:ff:fc:4b:ef dev eth1 self permanent
aa:c1:ab:8f:be:bb dev eth3 master br10 
aa:c1:ab:f6:40:5f dev eth3 vlan 1 master br10 permanent
aa:c1:ab:f6:40:5f dev eth3 master br10 permanent
33:33:00:00:00:01 dev eth3 self permanent
01:00:5e:00:00:01 dev eth3 self permanent
33:33:ff:f6:40:5f dev eth3 self permanent

## leaf3 bridge links
654: eth3@if653: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 master br10 state forwarding priority 32 cost 2 
4: vxlan10010: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9450 master br10 state forwarding priority 32 cost 2 

## leaf3 FDB
33:33:00:00:00:01 dev eth0 self permanent
33:33:ff:00:00:02 dev eth0 self permanent
01:00:5e:00:00:01 dev eth0 self permanent
33:33:ff:25:78:d8 dev eth0 self permanent
33:33:00:00:00:01 dev br10 self permanent
01:00:5e:00:00:6a dev br10 self permanent
33:33:00:00:00:6a dev br10 self permanent
01:00:5e:00:00:01 dev br10 self permanent
33:33:ff:e3:70:aa dev br10 self permanent
aa:c1:ab:59:5a:40 dev vxlan10010 vlan 1 extern_learn master br10 
aa:c1:ab:8f:be:bb dev vxlan10010 vlan 1 extern_learn master br10 
aa:c1:ab:8f:c2:9c dev vxlan10010 vlan 1 extern_learn master br10 
aa:c1:ab:57:31:a8 dev vxlan10010 master br10 
aa:c1:ab:59:5a:40 dev vxlan10010 extern_learn master br10 
aa:c1:ab:f6:40:5f dev vxlan10010 master br10 
f6:d2:f4:03:32:3e dev vxlan10010 master br10 
aa:c1:ab:8f:be:bb dev vxlan10010 extern_learn master br10 
aa:c1:ab:8f:c2:9c dev vxlan10010 extern_learn master br10 
32:99:53:00:76:5a dev vxlan10010 master br10 
ce:1b:c2:64:fc:f8 dev vxlan10010 master br10 
e6:6b:5a:6e:6f:5d dev vxlan10010 vlan 1 master br10 permanent
e6:6b:5a:6e:6f:5d dev vxlan10010 master br10 permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.1 self permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.2 self permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.4 self permanent
aa:c1:ab:8f:be:bb dev vxlan10010 dst 10.255.1.2 self extern_learn 
aa:c1:ab:59:5a:40 dev vxlan10010 dst 10.255.1.4 self extern_learn 
aa:c1:ab:8f:c2:9c dev vxlan10010 dst 10.255.1.1 self extern_learn 
33:33:00:00:00:01 dev eth1 self permanent
01:00:5e:00:00:01 dev eth1 self permanent
33:33:ff:f6:46:5f dev eth1 self permanent
33:33:00:00:00:01 dev eth2 self permanent
01:00:5e:00:00:01 dev eth2 self permanent
33:33:ff:06:96:71 dev eth2 self permanent
aa:c1:ab:b1:5f:e1 dev eth3 master br10 
aa:c1:ab:05:4b:42 dev eth3 vlan 1 master br10 permanent
aa:c1:ab:05:4b:42 dev eth3 master br10 permanent
33:33:00:00:00:01 dev eth3 self permanent
01:00:5e:00:00:01 dev eth3 self permanent
33:33:ff:05:4b:42 dev eth3 self permanent

## leaf4 bridge links
656: eth3@if657: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 master br10 state forwarding priority 32 cost 2 
4: vxlan10010: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9450 master br10 state forwarding priority 32 cost 2 

## leaf4 FDB
33:33:00:00:00:01 dev eth0 self permanent
33:33:ff:00:00:09 dev eth0 self permanent
01:00:5e:00:00:01 dev eth0 self permanent
33:33:ff:4b:ad:0d dev eth0 self permanent
33:33:00:00:00:01 dev br10 self permanent
01:00:5e:00:00:6a dev br10 self permanent
33:33:00:00:00:6a dev br10 self permanent
01:00:5e:00:00:01 dev br10 self permanent
33:33:ff:2e:ff:82 dev br10 self permanent
aa:c1:ab:f6:40:5f dev vxlan10010 master br10 
e6:6b:5a:6e:6f:5d dev vxlan10010 master br10 
aa:c1:ab:05:4b:42 dev vxlan10010 master br10 
f6:d2:f4:03:32:3e dev vxlan10010 master br10 
32:99:53:00:76:5a dev vxlan10010 master br10 
aa:c1:ab:8f:be:bb dev vxlan10010 vlan 1 extern_learn master br10 
aa:c1:ab:8f:be:bb dev vxlan10010 extern_learn master br10 
aa:c1:ab:8f:c2:9c dev vxlan10010 vlan 1 extern_learn master br10 
aa:c1:ab:8f:c2:9c dev vxlan10010 extern_learn master br10 
aa:c1:ab:b1:5f:e1 dev vxlan10010 vlan 1 extern_learn master br10 
aa:c1:ab:b1:5f:e1 dev vxlan10010 extern_learn master br10 
ce:1b:c2:64:fc:f8 dev vxlan10010 vlan 1 master br10 permanent
ce:1b:c2:64:fc:f8 dev vxlan10010 master br10 permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.3 self permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.1 self permanent
00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.2 self permanent
aa:c1:ab:8f:be:bb dev vxlan10010 dst 10.255.1.2 self extern_learn 
aa:c1:ab:b1:5f:e1 dev vxlan10010 dst 10.255.1.3 self extern_learn 
aa:c1:ab:8f:c2:9c dev vxlan10010 dst 10.255.1.1 self extern_learn 
aa:c1:ab:59:5a:40 dev eth3 master br10 
aa:c1:ab:57:31:a8 dev eth3 vlan 1 master br10 permanent
aa:c1:ab:57:31:a8 dev eth3 master br10 permanent
33:33:00:00:00:01 dev eth3 self permanent
01:00:5e:00:00:01 dev eth3 self permanent
33:33:ff:57:31:a8 dev eth3 self permanent
33:33:00:00:00:01 dev eth2 self permanent
01:00:5e:00:00:01 dev eth2 self permanent
33:33:ff:62:ce:eb dev eth2 self permanent
33:33:00:00:00:01 dev eth1 self permanent
01:00:5e:00:00:01 dev eth1 self permanent
33:33:ff:dc:5a:dd dev eth1 self permanent

