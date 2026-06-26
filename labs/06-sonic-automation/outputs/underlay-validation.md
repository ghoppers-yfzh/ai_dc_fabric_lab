# SONiC Underlay Validation

## Validate spine1

### Interface addresses
$ docker exec clab-06-sonic-automation-spine1 ip -br addr
lo               UNKNOWN        127.0.0.1/8 ::1/128 
eth0@if1014      UP             172.20.20.2/24 3fff:172:20:20::2/64 fe80::94f9:fff:fea8:75b7/64 
Ethernet0        UNKNOWN        10.0.11.0/31 fe80::94f9:fff:fea8:75b7/64 
Ethernet4        UNKNOWN        10.0.21.0/31 fe80::94f9:fff:fea8:75b7/64 
Ethernet24       DOWN           
Ethernet28       DOWN           
Ethernet36       DOWN           
Ethernet32       DOWN           
Ethernet40       DOWN           
Ethernet44       DOWN           
Ethernet8        DOWN           
Ethernet12       DOWN           
Ethernet20       DOWN           
Ethernet16       DOWN           
Ethernet52       DOWN           
Ethernet48       DOWN           
Ethernet56       DOWN           
Ethernet60       DOWN           
Ethernet68       DOWN           
Ethernet64       DOWN           
Ethernet72       DOWN           
Ethernet76       DOWN           
Ethernet104      DOWN           
Ethernet108      DOWN           
Ethernet116      DOWN           
Ethernet112      DOWN           
Ethernet124      DOWN           
Ethernet120      DOWN           
Ethernet84       DOWN           
Ethernet80       DOWN           
Ethernet88       DOWN           
Ethernet92       DOWN           
Ethernet100      DOWN           
Ethernet96       DOWN           
Bridge           UP             fe80::94f9:fff:fea8:75b7/64 
dummy            UNKNOWN        fe80::9cfd:c7ff:fe90:716d/64 
Loopback0        UNKNOWN        10.255.0.1/32 fe80::88b7:8ff:fe01:a51/64 
eth1@if1017      UP             fe80::a8c1:abff:fea5:80ab/64 
eth2@if1020      UP             fe80::a8c1:abff:fe09:303a/64 

### Direct peer ping
- spine1 -> leaf1: 10.0.11.1
$ docker exec clab-06-sonic-automation-spine1 ping -c 3 -W 1 10.0.11.1
PING 10.0.11.1 (10.0.11.1) 56(84) bytes of data.
64 bytes from 10.0.11.1: icmp_seq=1 ttl=64 time=0.492 ms
64 bytes from 10.0.11.1: icmp_seq=2 ttl=64 time=0.445 ms
64 bytes from 10.0.11.1: icmp_seq=3 ttl=64 time=0.327 ms

--- 10.0.11.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2053ms
rtt min/avg/max/mdev = 0.327/0.421/0.492/0.069 ms

- spine1 -> leaf2: 10.0.21.1
$ docker exec clab-06-sonic-automation-spine1 ping -c 3 -W 1 10.0.21.1
PING 10.0.21.1 (10.0.21.1) 56(84) bytes of data.
64 bytes from 10.0.21.1: icmp_seq=1 ttl=64 time=0.392 ms
64 bytes from 10.0.21.1: icmp_seq=2 ttl=64 time=0.345 ms
64 bytes from 10.0.21.1: icmp_seq=3 ttl=64 time=0.377 ms

--- 10.0.21.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2030ms
rtt min/avg/max/mdev = 0.345/0.371/0.392/0.019 ms

### BGP summary
$ docker exec clab-06-sonic-automation-spine1 vtysh -c 'show ip bgp summary'

IPv4 Unicast Summary:
BGP router identifier 10.255.0.1, local AS number 65001 VRF default vrf-id 0
BGP table version 4
RIB entries 7, using 896 bytes of memory
Peers 2, using 47 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.11.1       4      65101        26        27        4    0    0 00:19:32            2        4 N/A
10.0.21.1       4      65102        26        27        4    0    0 00:19:32            2        4 N/A

Total number of neighbors 2

### BGP routes
$ docker exec clab-06-sonic-automation-spine1 vtysh -c 'show ip route bgp'
Codes: K - kernel route, C - connected, L - local, S - static,
       R - RIP, O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric, t - Table-Direct,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

IPv4 unicast VRF default:
B>* 10.255.0.2/32 [20/0] via 10.0.11.1, Ethernet0, weight 1, 00:19:30
B>* 10.255.0.11/32 [20/0] via 10.0.11.1, Ethernet0, weight 1, 00:19:31
B>* 10.255.0.12/32 [20/0] via 10.0.21.1, Ethernet4, weight 1, 00:19:30

### Loopback reachability
- spine1 (10.255.0.1) -> spine2: 10.255.0.2
$ docker exec clab-06-sonic-automation-spine1 ping -I 10.255.0.1 -c 3 -W 1 10.255.0.2
PING 10.255.0.2 (10.255.0.2) from 10.255.0.1 : 56(84) bytes of data.
64 bytes from 10.255.0.2: icmp_seq=1 ttl=63 time=0.932 ms
64 bytes from 10.255.0.2: icmp_seq=2 ttl=63 time=0.819 ms
64 bytes from 10.255.0.2: icmp_seq=3 ttl=63 time=0.768 ms

--- 10.255.0.2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2032ms
rtt min/avg/max/mdev = 0.768/0.839/0.932/0.068 ms

- spine1 (10.255.0.1) -> leaf1: 10.255.0.11
$ docker exec clab-06-sonic-automation-spine1 ping -I 10.255.0.1 -c 3 -W 1 10.255.0.11
PING 10.255.0.11 (10.255.0.11) from 10.255.0.1 : 56(84) bytes of data.
64 bytes from 10.255.0.11: icmp_seq=1 ttl=64 time=0.490 ms
64 bytes from 10.255.0.11: icmp_seq=2 ttl=64 time=0.405 ms
64 bytes from 10.255.0.11: icmp_seq=3 ttl=64 time=0.399 ms

--- 10.255.0.11 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2031ms
rtt min/avg/max/mdev = 0.399/0.431/0.490/0.041 ms

- spine1 (10.255.0.1) -> leaf2: 10.255.0.12
$ docker exec clab-06-sonic-automation-spine1 ping -I 10.255.0.1 -c 3 -W 1 10.255.0.12
PING 10.255.0.12 (10.255.0.12) from 10.255.0.1 : 56(84) bytes of data.
64 bytes from 10.255.0.12: icmp_seq=1 ttl=64 time=0.427 ms
64 bytes from 10.255.0.12: icmp_seq=2 ttl=64 time=0.360 ms
64 bytes from 10.255.0.12: icmp_seq=3 ttl=64 time=0.296 ms

--- 10.255.0.12 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2040ms
rtt min/avg/max/mdev = 0.296/0.361/0.427/0.053 ms

---

## Validate spine2

### Interface addresses
$ docker exec clab-06-sonic-automation-spine2 ip -br addr
lo               UNKNOWN        127.0.0.1/8 ::1/128 
eth0@if1016      UP             172.20.20.4/24 3fff:172:20:20::4/64 fe80::b8d4:ecff:feba:b925/64 
Ethernet0        UNKNOWN        10.0.12.0/31 fe80::b8d4:ecff:feba:b925/64 
Ethernet4        UNKNOWN        10.0.22.0/31 fe80::b8d4:ecff:feba:b925/64 
Ethernet24       DOWN           
Ethernet28       DOWN           
Ethernet36       DOWN           
Ethernet32       DOWN           
Ethernet40       DOWN           
Ethernet44       DOWN           
Ethernet8        DOWN           
Ethernet12       DOWN           
Ethernet20       DOWN           
Ethernet16       DOWN           
Ethernet52       DOWN           
Ethernet48       DOWN           
Ethernet56       DOWN           
Ethernet60       DOWN           
Ethernet68       DOWN           
Ethernet64       DOWN           
Ethernet72       DOWN           
Ethernet76       DOWN           
Ethernet104      DOWN           
Ethernet108      DOWN           
Ethernet116      DOWN           
Ethernet112      DOWN           
Ethernet124      DOWN           
Ethernet120      DOWN           
Ethernet84       DOWN           
Ethernet80       DOWN           
Ethernet88       DOWN           
Ethernet92       DOWN           
Ethernet100      DOWN           
Ethernet96       DOWN           
Bridge           UP             fe80::b8d4:ecff:feba:b925/64 
dummy            UNKNOWN        fe80::cc61:5dff:fe8d:8203/64 
Loopback0        UNKNOWN        10.255.0.2/32 fe80::1480:18ff:fe5a:cac2/64 
eth2@if1023      UP             fe80::a8c1:abff:fe6f:978f/64 
eth1@if1024      UP             fe80::a8c1:abff:fe19:6cf/64 

### Direct peer ping
- spine2 -> leaf1: 10.0.12.1
$ docker exec clab-06-sonic-automation-spine2 ping -c 3 -W 1 10.0.12.1
PING 10.0.12.1 (10.0.12.1) 56(84) bytes of data.
64 bytes from 10.0.12.1: icmp_seq=1 ttl=64 time=0.387 ms
64 bytes from 10.0.12.1: icmp_seq=2 ttl=64 time=0.434 ms
64 bytes from 10.0.12.1: icmp_seq=3 ttl=64 time=0.316 ms

--- 10.0.12.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2032ms
rtt min/avg/max/mdev = 0.316/0.379/0.434/0.048 ms

- spine2 -> leaf2: 10.0.22.1
$ docker exec clab-06-sonic-automation-spine2 ping -c 3 -W 1 10.0.22.1
PING 10.0.22.1 (10.0.22.1) 56(84) bytes of data.
64 bytes from 10.0.22.1: icmp_seq=1 ttl=64 time=0.507 ms
64 bytes from 10.0.22.1: icmp_seq=2 ttl=64 time=0.355 ms
64 bytes from 10.0.22.1: icmp_seq=3 ttl=64 time=0.356 ms

--- 10.0.22.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2042ms
rtt min/avg/max/mdev = 0.355/0.406/0.507/0.071 ms

### BGP summary
$ docker exec clab-06-sonic-automation-spine2 vtysh -c 'show ip bgp summary'

IPv4 Unicast Summary:
BGP router identifier 10.255.0.2, local AS number 65002 VRF default vrf-id 0
BGP table version 4
RIB entries 7, using 896 bytes of memory
Peers 2, using 47 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.12.1       4      65101        26        27        4    0    0 00:19:43            3        4 N/A
10.0.22.1       4      65102        26        27        4    0    0 00:19:43            3        4 N/A

Total number of neighbors 2

### BGP routes
$ docker exec clab-06-sonic-automation-spine2 vtysh -c 'show ip route bgp'
Codes: K - kernel route, C - connected, L - local, S - static,
       R - RIP, O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric, t - Table-Direct,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

IPv4 unicast VRF default:
B>* 10.255.0.1/32 [20/0] via 10.0.12.1, Ethernet0, weight 1, 00:19:41
B>* 10.255.0.11/32 [20/0] via 10.0.12.1, Ethernet0, weight 1, 00:19:42
B>* 10.255.0.12/32 [20/0] via 10.0.22.1, Ethernet4, weight 1, 00:19:41

### Loopback reachability
- spine2 (10.255.0.2) -> spine1: 10.255.0.1
$ docker exec clab-06-sonic-automation-spine2 ping -I 10.255.0.2 -c 3 -W 1 10.255.0.1
PING 10.255.0.1 (10.255.0.1) from 10.255.0.2 : 56(84) bytes of data.
64 bytes from 10.255.0.1: icmp_seq=1 ttl=63 time=0.866 ms
64 bytes from 10.255.0.1: icmp_seq=2 ttl=63 time=0.752 ms
64 bytes from 10.255.0.1: icmp_seq=3 ttl=63 time=0.753 ms

--- 10.255.0.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2032ms
rtt min/avg/max/mdev = 0.752/0.790/0.866/0.053 ms

- spine2 (10.255.0.2) -> leaf1: 10.255.0.11
$ docker exec clab-06-sonic-automation-spine2 ping -I 10.255.0.2 -c 3 -W 1 10.255.0.11
PING 10.255.0.11 (10.255.0.11) from 10.255.0.2 : 56(84) bytes of data.
64 bytes from 10.255.0.11: icmp_seq=1 ttl=64 time=0.404 ms
64 bytes from 10.255.0.11: icmp_seq=2 ttl=64 time=0.388 ms
64 bytes from 10.255.0.11: icmp_seq=3 ttl=64 time=0.340 ms

--- 10.255.0.11 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2041ms
rtt min/avg/max/mdev = 0.340/0.377/0.404/0.027 ms

- spine2 (10.255.0.2) -> leaf2: 10.255.0.12
$ docker exec clab-06-sonic-automation-spine2 ping -I 10.255.0.2 -c 3 -W 1 10.255.0.12
PING 10.255.0.12 (10.255.0.12) from 10.255.0.2 : 56(84) bytes of data.
64 bytes from 10.255.0.12: icmp_seq=1 ttl=64 time=0.423 ms
64 bytes from 10.255.0.12: icmp_seq=2 ttl=64 time=0.407 ms
64 bytes from 10.255.0.12: icmp_seq=3 ttl=64 time=0.428 ms

--- 10.255.0.12 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2028ms
rtt min/avg/max/mdev = 0.407/0.419/0.428/0.009 ms

---

## Validate leaf1

### Interface addresses
$ docker exec clab-06-sonic-automation-leaf1 ip -br addr
lo               UNKNOWN        127.0.0.1/8 ::1/128 
eth0@if1019      UP             172.20.20.5/24 3fff:172:20:20::5/64 fe80::e400:6dff:fe54:955a/64 
Ethernet0        UNKNOWN        10.0.11.1/31 fe80::e400:6dff:fe54:955a/64 
Ethernet4        UNKNOWN        10.0.12.1/31 fe80::e400:6dff:fe54:955a/64 
Ethernet24       DOWN           
Ethernet28       DOWN           
Ethernet36       DOWN           
Ethernet32       DOWN           
Ethernet40       DOWN           
Ethernet44       DOWN           
Ethernet8        DOWN           
Ethernet12       DOWN           
Ethernet20       DOWN           
Ethernet16       DOWN           
Ethernet52       DOWN           
Ethernet48       DOWN           
Ethernet56       DOWN           
Ethernet60       DOWN           
Ethernet68       DOWN           
Ethernet64       DOWN           
Ethernet72       DOWN           
Ethernet76       DOWN           
Ethernet104      DOWN           
Ethernet108      DOWN           
Ethernet116      DOWN           
Ethernet112      DOWN           
Ethernet124      DOWN           
Ethernet120      DOWN           
Ethernet84       DOWN           
Ethernet80       DOWN           
Ethernet88       DOWN           
Ethernet92       DOWN           
Ethernet100      DOWN           
Ethernet96       DOWN           
Bridge           UP             fe80::e400:6dff:fe54:955a/64 
dummy            UNKNOWN        fe80::d8a5:efff:fe20:d887/64 
Loopback0        UNKNOWN        10.255.0.11/32 fe80::1403:90ff:feb9:5477/64 
eth1@if1018      UP             fe80::a8c1:abff:fe61:d2b6/64 
eth2@if1025      UP             fe80::a8c1:abff:fee2:9217/64 

### Direct peer ping
- leaf1 -> spine1: 10.0.11.0
$ docker exec clab-06-sonic-automation-leaf1 ping -c 3 -W 1 10.0.11.0
PING 10.0.11.0 (10.0.11.0) 56(84) bytes of data.
64 bytes from 10.0.11.0: icmp_seq=1 ttl=64 time=0.438 ms
64 bytes from 10.0.11.0: icmp_seq=2 ttl=64 time=0.476 ms
64 bytes from 10.0.11.0: icmp_seq=3 ttl=64 time=0.426 ms

--- 10.0.11.0 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2026ms
rtt min/avg/max/mdev = 0.426/0.446/0.476/0.021 ms

- leaf1 -> spine2: 10.0.12.0
$ docker exec clab-06-sonic-automation-leaf1 ping -c 3 -W 1 10.0.12.0
PING 10.0.12.0 (10.0.12.0) 56(84) bytes of data.
64 bytes from 10.0.12.0: icmp_seq=1 ttl=64 time=0.435 ms
64 bytes from 10.0.12.0: icmp_seq=2 ttl=64 time=0.390 ms
64 bytes from 10.0.12.0: icmp_seq=3 ttl=64 time=0.369 ms

--- 10.0.12.0 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2039ms
rtt min/avg/max/mdev = 0.369/0.398/0.435/0.027 ms

### BGP summary
$ docker exec clab-06-sonic-automation-leaf1 vtysh -c 'show ip bgp summary'

IPv4 Unicast Summary:
BGP router identifier 10.255.0.11, local AS number 65101 VRF default vrf-id 0
BGP table version 4
RIB entries 7, using 896 bytes of memory
Peers 2, using 47 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.11.0       4      65001        26        26        4    0    0 00:19:54            2        4 N/A
10.0.12.0       4      65002        26        26        4    0    0 00:19:54            2        4 N/A

Total number of neighbors 2

### BGP routes
$ docker exec clab-06-sonic-automation-leaf1 vtysh -c 'show ip route bgp'
Codes: K - kernel route, C - connected, L - local, S - static,
       R - RIP, O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric, t - Table-Direct,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

IPv4 unicast VRF default:
B>* 10.255.0.1/32 [20/0] via 10.0.11.0, Ethernet0, weight 1, 00:19:52
B>* 10.255.0.2/32 [20/0] via 10.0.12.0, Ethernet4, weight 1, 00:19:52
B>* 10.255.0.12/32 [20/0] via 10.0.11.0, Ethernet0, weight 1, 00:19:52

### Loopback reachability
- leaf1 (10.255.0.11) -> spine1: 10.255.0.1
$ docker exec clab-06-sonic-automation-leaf1 ping -I 10.255.0.11 -c 3 -W 1 10.255.0.1
PING 10.255.0.1 (10.255.0.1) from 10.255.0.11 : 56(84) bytes of data.
64 bytes from 10.255.0.1: icmp_seq=1 ttl=64 time=0.399 ms
64 bytes from 10.255.0.1: icmp_seq=2 ttl=64 time=0.493 ms
64 bytes from 10.255.0.1: icmp_seq=3 ttl=64 time=0.476 ms

--- 10.255.0.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2030ms
rtt min/avg/max/mdev = 0.399/0.456/0.493/0.040 ms

- leaf1 (10.255.0.11) -> spine2: 10.255.0.2
$ docker exec clab-06-sonic-automation-leaf1 ping -I 10.255.0.11 -c 3 -W 1 10.255.0.2
PING 10.255.0.2 (10.255.0.2) from 10.255.0.11 : 56(84) bytes of data.
64 bytes from 10.255.0.2: icmp_seq=1 ttl=64 time=0.437 ms
64 bytes from 10.255.0.2: icmp_seq=2 ttl=64 time=0.286 ms
64 bytes from 10.255.0.2: icmp_seq=3 ttl=64 time=0.455 ms

--- 10.255.0.2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2030ms
rtt min/avg/max/mdev = 0.286/0.392/0.455/0.075 ms

- leaf1 (10.255.0.11) -> leaf2: 10.255.0.12
$ docker exec clab-06-sonic-automation-leaf1 ping -I 10.255.0.11 -c 3 -W 1 10.255.0.12
PING 10.255.0.12 (10.255.0.12) from 10.255.0.11 : 56(84) bytes of data.
64 bytes from 10.255.0.12: icmp_seq=1 ttl=63 time=0.797 ms
64 bytes from 10.255.0.12: icmp_seq=2 ttl=63 time=0.760 ms
64 bytes from 10.255.0.12: icmp_seq=3 ttl=63 time=0.879 ms

--- 10.255.0.12 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2037ms
rtt min/avg/max/mdev = 0.760/0.812/0.879/0.049 ms

---

## Validate leaf2

### Interface addresses
$ docker exec clab-06-sonic-automation-leaf2 ip -br addr
lo               UNKNOWN        127.0.0.1/8 ::1/128 
eth0@if1015      UP             172.20.20.3/24 3fff:172:20:20::3/64 fe80::f49e:b5ff:fe65:f0e1/64 
Ethernet0        UNKNOWN        10.0.21.1/31 fe80::f49e:b5ff:fe65:f0e1/64 
Ethernet4        UNKNOWN        10.0.22.1/31 fe80::f49e:b5ff:fe65:f0e1/64 
Ethernet24       DOWN           
Ethernet28       DOWN           
Ethernet36       DOWN           
Ethernet32       DOWN           
Ethernet40       DOWN           
Ethernet44       DOWN           
Ethernet8        DOWN           
Ethernet12       DOWN           
Ethernet20       DOWN           
Ethernet16       DOWN           
Ethernet52       DOWN           
Ethernet48       DOWN           
Ethernet56       DOWN           
Ethernet60       DOWN           
Ethernet68       DOWN           
Ethernet64       DOWN           
Ethernet72       DOWN           
Ethernet76       DOWN           
Ethernet104      DOWN           
Ethernet108      DOWN           
Ethernet116      DOWN           
Ethernet112      DOWN           
Ethernet124      DOWN           
Ethernet120      DOWN           
Ethernet84       DOWN           
Ethernet80       DOWN           
Ethernet88       DOWN           
Ethernet92       DOWN           
Ethernet100      DOWN           
Ethernet96       DOWN           
Bridge           UP             fe80::f49e:b5ff:fe65:f0e1/64 
dummy            UNKNOWN        fe80::a013:beff:fe74:cc9b/64 
Loopback0        UNKNOWN        10.255.0.12/32 fe80::a011:77ff:fee8:9243/64 
eth1@if1021      UP             fe80::a8c1:abff:fe80:3f54/64 
eth2@if1022      UP             fe80::a8c1:abff:fe6e:448/64 

### Direct peer ping
- leaf2 -> spine1: 10.0.21.0
$ docker exec clab-06-sonic-automation-leaf2 ping -c 3 -W 1 10.0.21.0
PING 10.0.21.0 (10.0.21.0) 56(84) bytes of data.
64 bytes from 10.0.21.0: icmp_seq=1 ttl=64 time=0.489 ms
64 bytes from 10.0.21.0: icmp_seq=2 ttl=64 time=0.475 ms
64 bytes from 10.0.21.0: icmp_seq=3 ttl=64 time=0.386 ms

--- 10.0.21.0 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2032ms
rtt min/avg/max/mdev = 0.386/0.450/0.489/0.045 ms

- leaf2 -> spine2: 10.0.22.0
$ docker exec clab-06-sonic-automation-leaf2 ping -c 3 -W 1 10.0.22.0
PING 10.0.22.0 (10.0.22.0) 56(84) bytes of data.
64 bytes from 10.0.22.0: icmp_seq=1 ttl=64 time=0.391 ms
64 bytes from 10.0.22.0: icmp_seq=2 ttl=64 time=0.385 ms
64 bytes from 10.0.22.0: icmp_seq=3 ttl=64 time=0.416 ms

--- 10.0.22.0 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2046ms
rtt min/avg/max/mdev = 0.385/0.397/0.416/0.013 ms

### BGP summary
$ docker exec clab-06-sonic-automation-leaf2 vtysh -c 'show ip bgp summary'

IPv4 Unicast Summary:
BGP router identifier 10.255.0.12, local AS number 65102 VRF default vrf-id 0
BGP table version 4
RIB entries 7, using 896 bytes of memory
Peers 2, using 47 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.21.0       4      65001        27        27        4    0    0 00:20:05            3        4 N/A
10.0.22.0       4      65002        27        27        4    0    0 00:20:05            3        4 N/A

Total number of neighbors 2

### BGP routes
$ docker exec clab-06-sonic-automation-leaf2 vtysh -c 'show ip route bgp'
Codes: K - kernel route, C - connected, L - local, S - static,
       R - RIP, O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric, t - Table-Direct,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

IPv4 unicast VRF default:
B>* 10.255.0.1/32 [20/0] via 10.0.21.0, Ethernet0, weight 1, 00:20:03
B>* 10.255.0.2/32 [20/0] via 10.0.22.0, Ethernet4, weight 1, 00:20:03
B>* 10.255.0.11/32 [20/0] via 10.0.21.0, Ethernet0, weight 1, 00:20:03

### Loopback reachability
- leaf2 (10.255.0.12) -> spine1: 10.255.0.1
$ docker exec clab-06-sonic-automation-leaf2 ping -I 10.255.0.12 -c 3 -W 1 10.255.0.1
PING 10.255.0.1 (10.255.0.1) from 10.255.0.12 : 56(84) bytes of data.
64 bytes from 10.255.0.1: icmp_seq=1 ttl=64 time=0.477 ms
64 bytes from 10.255.0.1: icmp_seq=2 ttl=64 time=0.433 ms
64 bytes from 10.255.0.1: icmp_seq=3 ttl=64 time=0.436 ms

--- 10.255.0.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2046ms
rtt min/avg/max/mdev = 0.433/0.448/0.477/0.020 ms

- leaf2 (10.255.0.12) -> spine2: 10.255.0.2
$ docker exec clab-06-sonic-automation-leaf2 ping -I 10.255.0.12 -c 3 -W 1 10.255.0.2
PING 10.255.0.2 (10.255.0.2) from 10.255.0.12 : 56(84) bytes of data.
64 bytes from 10.255.0.2: icmp_seq=1 ttl=64 time=0.462 ms
64 bytes from 10.255.0.2: icmp_seq=2 ttl=64 time=0.431 ms
64 bytes from 10.255.0.2: icmp_seq=3 ttl=64 time=0.379 ms

--- 10.255.0.2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2048ms
rtt min/avg/max/mdev = 0.379/0.424/0.462/0.034 ms

- leaf2 (10.255.0.12) -> leaf1: 10.255.0.11
$ docker exec clab-06-sonic-automation-leaf2 ping -I 10.255.0.12 -c 3 -W 1 10.255.0.11
PING 10.255.0.11 (10.255.0.11) from 10.255.0.12 : 56(84) bytes of data.
64 bytes from 10.255.0.11: icmp_seq=1 ttl=63 time=0.716 ms
64 bytes from 10.255.0.11: icmp_seq=2 ttl=63 time=0.802 ms
64 bytes from 10.255.0.11: icmp_seq=3 ttl=63 time=0.805 ms

--- 10.255.0.11 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2026ms
rtt min/avg/max/mdev = 0.716/0.774/0.805/0.041 ms

---

