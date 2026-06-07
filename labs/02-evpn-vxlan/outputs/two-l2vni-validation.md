]633;E;echo "# Two-L2VNI EVPN Validation";fbf5a41f-2d56-4ae0-adfc-bae181e9a759]633;C# Two-L2VNI EVPN Validation

## Host IP and route table

### host1
lo               UNKNOWN        127.0.0.1/8 ::1/128 
eth0@if758       UP             172.20.20.11/24 3fff:172:20:20::b/64 fe80::ecca:c2ff:fe98:a9f6/64 
eth1@if744       UP             192.168.10.11/24 fe80::a8c1:abff:fea2:a8a9/64 
default via 192.168.10.1 dev eth1 
172.20.20.0/24 dev eth0 proto kernel scope link src 172.20.20.11 
192.168.10.0/24 dev eth1 proto kernel scope link src 192.168.10.11 

### host2
lo               UNKNOWN        127.0.0.1/8 ::1/128 
eth0@if737       UP             172.20.20.4/24 3fff:172:20:20::4/64 fe80::548d:6eff:fe83:5a89/64 
eth1@if749       UP             192.168.10.12/24 fe80::a8c1:abff:fe40:6c61/64 
default via 192.168.10.1 dev eth1 
172.20.20.0/24 dev eth0 proto kernel scope link src 172.20.20.4 
192.168.10.0/24 dev eth1 proto kernel scope link src 192.168.10.12 

### host3
lo               UNKNOWN        127.0.0.1/8 ::1/128 
eth0@if740       UP             172.20.20.5/24 3fff:172:20:20::5/64 fe80::2cce:edff:fe42:bbd8/64 
eth1@if751       UP             192.168.20.13/24 fe80::a8c1:abff:fe48:799e/64 
default via 192.168.20.1 dev eth1 
172.20.20.0/24 dev eth0 proto kernel scope link src 172.20.20.5 
192.168.20.0/24 dev eth1 proto kernel scope link src 192.168.20.13 

### host4
lo               UNKNOWN        127.0.0.1/8 ::1/128 
eth0@if736       UP             172.20.20.3/24 3fff:172:20:20::3/64 fe80::308d:28ff:feaf:1473/64 
eth1@if745       UP             192.168.20.14/24 fe80::a8c1:abff:fe17:3ccb/64 
default via 192.168.20.1 dev eth1 
172.20.20.0/24 dev eth0 proto kernel scope link src 172.20.20.3 
192.168.20.0/24 dev eth1 proto kernel scope link src 192.168.20.14 

## EVPN VNI state

### leaf1
VNI        Type VxLAN IF              # MACs   # ARPs   # Remote VTEPs  Tenant VRF                           
10010      L2   vxlan10010            2        1        1               default                              

### leaf2
VNI        Type VxLAN IF              # MACs   # ARPs   # Remote VTEPs  Tenant VRF                           
10010      L2   vxlan10010            2        1        1               default                              

### leaf3
VNI        Type VxLAN IF              # MACs   # ARPs   # Remote VTEPs  Tenant VRF                           
10020      L2   vxlan10020            2        1        1               default                              

### leaf4
VNI        Type VxLAN IF              # MACs   # ARPs   # Remote VTEPs  Tenant VRF                           
10020      L2   vxlan10020            2        1        1               default                              

## EVPN routes

### leaf1
BGP table version is 3, local router ID is 10.255.1.1
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal
Origin codes: i - IGP, e - EGP, ? - incomplete
EVPN type-1 prefix: [1]:[EthTag]:[ESI]:[IPlen]:[VTEP-IP]:[Frag-id]
EVPN type-2 prefix: [2]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]
EVPN type-3 prefix: [3]:[EthTag]:[IPlen]:[OrigIP]
EVPN type-4 prefix: [4]:[ESI]:[IPlen]:[OrigIP]
EVPN type-5 prefix: [5]:[EthTag]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 10.255.1.1:2
*> [2]:[0]:[48]:[aa:c1:ab:a2:a8:a9]
                    10.255.1.1                         32768 i
                    ET:8 RT:65000:10010
*> [2]:[0]:[48]:[aa:c1:ab:a2:a8:a9]:[32]:[192.168.10.11]
                    10.255.1.1                         32768 i
                    ET:8 RT:65000:10010
*> [3]:[0]:[32]:[10.255.1.1]
                    10.255.1.1                         32768 i
                    ET:8 RT:65000:10010
Route Distinguisher: 10.255.1.2:2
*> [2]:[0]:[48]:[aa:c1:ab:40:6c:61]
                    10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*                   10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*> [3]:[0]:[32]:[10.255.1.2]
                    10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*                   10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
Route Distinguisher: 10.255.1.3:2
*> [2]:[0]:[48]:[aa:c1:ab:48:79:9e]
                    10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*                   10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*> [2]:[0]:[48]:[aa:c1:ab:48:79:9e]:[32]:[192.168.20.13]
                    10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*                   10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*> [3]:[0]:[32]:[10.255.1.3]
                    10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*                   10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
Route Distinguisher: 10.255.1.4:2
*> [2]:[0]:[48]:[aa:c1:ab:17:3c:cb]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*                   10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*> [3]:[0]:[32]:[10.255.1.4]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*                   10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8

Displayed 10 out of 17 total prefixes

### leaf2
BGP table version is 3, local router ID is 10.255.1.2
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal
Origin codes: i - IGP, e - EGP, ? - incomplete
EVPN type-1 prefix: [1]:[EthTag]:[ESI]:[IPlen]:[VTEP-IP]:[Frag-id]
EVPN type-2 prefix: [2]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]
EVPN type-3 prefix: [3]:[EthTag]:[IPlen]:[OrigIP]
EVPN type-4 prefix: [4]:[ESI]:[IPlen]:[OrigIP]
EVPN type-5 prefix: [5]:[EthTag]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 10.255.1.1:2
*  [2]:[0]:[48]:[aa:c1:ab:a2:a8:a9]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*>                  10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*> [2]:[0]:[48]:[aa:c1:ab:a2:a8:a9]:[32]:[192.168.10.11]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*                   10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*  [3]:[0]:[32]:[10.255.1.1]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*>                  10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
Route Distinguisher: 10.255.1.2:2
*> [2]:[0]:[48]:[aa:c1:ab:40:6c:61]
                    10.255.1.2                         32768 i
                    ET:8 RT:65000:10010
*> [3]:[0]:[32]:[10.255.1.2]
                    10.255.1.2                         32768 i
                    ET:8 RT:65000:10010
Route Distinguisher: 10.255.1.3:2
*> [2]:[0]:[48]:[aa:c1:ab:48:79:9e]
                    10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*                   10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*> [2]:[0]:[48]:[aa:c1:ab:48:79:9e]:[32]:[192.168.20.13]
                    10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*                   10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*> [3]:[0]:[32]:[10.255.1.3]
                    10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*                   10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
Route Distinguisher: 10.255.1.4:2
*> [2]:[0]:[48]:[aa:c1:ab:17:3c:cb]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*                   10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*> [3]:[0]:[32]:[10.255.1.4]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*                   10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8

Displayed 10 out of 18 total prefixes

### leaf3
BGP table version is 3, local router ID is 10.255.1.3
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal
Origin codes: i - IGP, e - EGP, ? - incomplete
EVPN type-1 prefix: [1]:[EthTag]:[ESI]:[IPlen]:[VTEP-IP]:[Frag-id]
EVPN type-2 prefix: [2]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]
EVPN type-3 prefix: [3]:[EthTag]:[IPlen]:[OrigIP]
EVPN type-4 prefix: [4]:[ESI]:[IPlen]:[OrigIP]
EVPN type-5 prefix: [5]:[EthTag]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 10.255.1.1:2
*  [2]:[0]:[48]:[aa:c1:ab:a2:a8:a9]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*>                  10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*> [2]:[0]:[48]:[aa:c1:ab:a2:a8:a9]:[32]:[192.168.10.11]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*                   10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*  [3]:[0]:[32]:[10.255.1.1]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*>                  10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
Route Distinguisher: 10.255.1.2:2
*> [2]:[0]:[48]:[aa:c1:ab:40:6c:61]
                    10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*                   10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*> [3]:[0]:[32]:[10.255.1.2]
                    10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*                   10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
Route Distinguisher: 10.255.1.3:2
*> [2]:[0]:[48]:[aa:c1:ab:48:79:9e]
                    10.255.1.3                         32768 i
                    ET:8 RT:65000:10020
*> [2]:[0]:[48]:[aa:c1:ab:48:79:9e]:[32]:[192.168.20.13]
                    10.255.1.3                         32768 i
                    ET:8 RT:65000:10020
*> [3]:[0]:[32]:[10.255.1.3]
                    10.255.1.3                         32768 i
                    ET:8 RT:65000:10020
Route Distinguisher: 10.255.1.4:2
*> [2]:[0]:[48]:[aa:c1:ab:17:3c:cb]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*                   10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*> [3]:[0]:[32]:[10.255.1.4]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*                   10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8

Displayed 10 out of 17 total prefixes

### leaf4
BGP table version is 3, local router ID is 10.255.1.4
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal
Origin codes: i - IGP, e - EGP, ? - incomplete
EVPN type-1 prefix: [1]:[EthTag]:[ESI]:[IPlen]:[VTEP-IP]:[Frag-id]
EVPN type-2 prefix: [2]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]
EVPN type-3 prefix: [3]:[EthTag]:[IPlen]:[OrigIP]
EVPN type-4 prefix: [4]:[ESI]:[IPlen]:[OrigIP]
EVPN type-5 prefix: [5]:[EthTag]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 10.255.1.1:2
*  [2]:[0]:[48]:[aa:c1:ab:a2:a8:a9]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*>                  10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*> [2]:[0]:[48]:[aa:c1:ab:a2:a8:a9]:[32]:[192.168.10.11]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*                   10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*  [3]:[0]:[32]:[10.255.1.1]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*>                  10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
Route Distinguisher: 10.255.1.2:2
*> [2]:[0]:[48]:[aa:c1:ab:40:6c:61]
                    10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*                   10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*> [3]:[0]:[32]:[10.255.1.2]
                    10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*                   10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
Route Distinguisher: 10.255.1.3:2
*> [2]:[0]:[48]:[aa:c1:ab:48:79:9e]
                    10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*                   10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*> [2]:[0]:[48]:[aa:c1:ab:48:79:9e]:[32]:[192.168.20.13]
                    10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*                   10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*> [3]:[0]:[32]:[10.255.1.3]
                    10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*                   10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
Route Distinguisher: 10.255.1.4:2
*> [2]:[0]:[48]:[aa:c1:ab:17:3c:cb]
                    10.255.1.4                         32768 i
                    ET:8 RT:65000:10020
*> [3]:[0]:[32]:[10.255.1.4]
                    10.255.1.4                         32768 i
                    ET:8 RT:65000:10020

Displayed 10 out of 18 total prefixes

## Same-subnet reachability

### host1 to host2 in VLAN 10 / VNI 10010
PING 192.168.10.12 (192.168.10.12) 56(84) bytes of data.
64 bytes from 192.168.10.12: icmp_seq=1 ttl=64 time=0.176 ms
64 bytes from 192.168.10.12: icmp_seq=2 ttl=64 time=0.081 ms
64 bytes from 192.168.10.12: icmp_seq=3 ttl=64 time=0.079 ms

--- 192.168.10.12 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2051ms
rtt min/avg/max/mdev = 0.079/0.112/0.176/0.045 ms

### host3 to host4 in VLAN 20 / VNI 10020
PING 192.168.20.14 (192.168.20.14) 56(84) bytes of data.
64 bytes from 192.168.20.14: icmp_seq=1 ttl=64 time=0.173 ms
64 bytes from 192.168.20.14: icmp_seq=2 ttl=64 time=0.078 ms
64 bytes from 192.168.20.14: icmp_seq=3 ttl=64 time=0.085 ms

--- 192.168.20.14 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2051ms
rtt min/avg/max/mdev = 0.078/0.112/0.173/0.043 ms

## Cross-subnet reachability before L3VNI

### host1 to host3 should fail before L3VNI
PING 192.168.20.13 (192.168.20.13) 56(84) bytes of data.

--- 192.168.20.13 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2038ms


### host3 to host1 should fail before L3VNI
PING 192.168.10.11 (192.168.10.11) 56(84) bytes of data.

--- 192.168.10.11 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2055ms

