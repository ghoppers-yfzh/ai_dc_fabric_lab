# L3VNI Route Target Cleanup Validation

## leaf1 EVPN routes
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
*> [2]:[0]:[48]:[aa:c1:ab:da:b4:00]
                    10.255.1.1                         32768 i
                    ET:8 RT:65000:10010
*> [3]:[0]:[32]:[10.255.1.1]
                    10.255.1.1                         32768 i
                    ET:8 RT:65000:10010
Route Distinguisher: 10.255.1.1:3
*> [5]:[0]:[24]:[192.168.10.0]
                    10.255.1.1               0         32768 ?
                    ET:8 RT:65000:10099 Rmac:00:00:00:99:00:01
Route Distinguisher: 10.255.1.2:2
*  [2]:[0]:[48]:[aa:c1:ab:08:d0:bb]
                    10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*>                  10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*  [3]:[0]:[32]:[10.255.1.2]
                    10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*>                  10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
Route Distinguisher: 10.255.1.3:2
*  [2]:[0]:[48]:[aa:c1:ab:83:15:bc]
                    10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*>                  10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*  [3]:[0]:[32]:[10.255.1.3]
                    10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*>                  10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
Route Distinguisher: 10.255.1.3:3
*  [5]:[0]:[24]:[192.168.20.0]
                    10.255.1.3                             0 65000 65103 ?
                    RT:65000:10099 ET:8 Rmac:00:00:00:99:00:03
*>                  10.255.1.3                             0 65000 65103 ?
                    RT:65000:10099 ET:8 Rmac:00:00:00:99:00:03
Route Distinguisher: 10.255.1.4:2
*  [2]:[0]:[48]:[aa:c1:ab:e3:4a:bf]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*>                  10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*  [3]:[0]:[32]:[10.255.1.4]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*>                  10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8

Displayed 10 out of 17 total prefixes

## leaf3 EVPN routes
BGP table version is 2, local router ID is 10.255.1.3
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal
Origin codes: i - IGP, e - EGP, ? - incomplete
EVPN type-1 prefix: [1]:[EthTag]:[ESI]:[IPlen]:[VTEP-IP]:[Frag-id]
EVPN type-2 prefix: [2]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]
EVPN type-3 prefix: [3]:[EthTag]:[IPlen]:[OrigIP]
EVPN type-4 prefix: [4]:[ESI]:[IPlen]:[OrigIP]
EVPN type-5 prefix: [5]:[EthTag]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 10.255.1.1:2
*  [2]:[0]:[48]:[aa:c1:ab:da:b4:00]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*>                  10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*  [3]:[0]:[32]:[10.255.1.1]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*>                  10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
Route Distinguisher: 10.255.1.1:3
*  [5]:[0]:[24]:[192.168.10.0]
                    10.255.1.1                             0 65000 65101 ?
                    RT:65000:10099 ET:8 Rmac:00:00:00:99:00:01
*>                  10.255.1.1                             0 65000 65101 ?
                    RT:65000:10099 ET:8 Rmac:00:00:00:99:00:01
Route Distinguisher: 10.255.1.2:2
*  [2]:[0]:[48]:[aa:c1:ab:08:d0:bb]
                    10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*>                  10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*  [3]:[0]:[32]:[10.255.1.2]
                    10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*>                  10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
Route Distinguisher: 10.255.1.3:2
*> [2]:[0]:[48]:[aa:c1:ab:83:15:bc]
                    10.255.1.3                         32768 i
                    ET:8 RT:65000:10020
*> [3]:[0]:[32]:[10.255.1.3]
                    10.255.1.3                         32768 i
                    ET:8 RT:65000:10020
Route Distinguisher: 10.255.1.3:3
*> [5]:[0]:[24]:[192.168.20.0]
                    10.255.1.3               0         32768 ?
                    ET:8 RT:65000:10099 Rmac:00:00:00:99:00:03
Route Distinguisher: 10.255.1.4:2
*  [2]:[0]:[48]:[aa:c1:ab:e3:4a:bf]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*>                  10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*  [3]:[0]:[32]:[10.255.1.4]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*>                  10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8

Displayed 10 out of 17 total prefixes

## leaf1 VRF routes
192.168.10.0/24 dev br10 proto kernel scope link src 192.168.10.1 
192.168.20.0/24 nhid 37 via 10.255.1.3 dev br10099 proto bgp metric 20 onlink 

## leaf3 VRF routes
192.168.10.0/24 nhid 33 via 10.255.1.1 dev br10099 proto bgp metric 20 onlink 
192.168.20.0/24 dev br20 proto kernel scope link src 192.168.20.1 

## host1 to host3
PING 192.168.20.13 (192.168.20.13) 56(84) bytes of data.
64 bytes from 192.168.20.13: icmp_seq=1 ttl=62 time=0.536 ms
64 bytes from 192.168.20.13: icmp_seq=2 ttl=62 time=0.206 ms
64 bytes from 192.168.20.13: icmp_seq=3 ttl=62 time=0.184 ms

--- 192.168.20.13 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2026ms
rtt min/avg/max/mdev = 0.184/0.308/0.536/0.161 ms

## host3 to host1
PING 192.168.10.11 (192.168.10.11) 56(84) bytes of data.
64 bytes from 192.168.10.11: icmp_seq=1 ttl=62 time=0.196 ms
64 bytes from 192.168.10.11: icmp_seq=2 ttl=62 time=0.086 ms
64 bytes from 192.168.10.11: icmp_seq=3 ttl=62 time=0.183 ms

--- 192.168.10.11 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2030ms
rtt min/avg/max/mdev = 0.086/0.155/0.196/0.049 ms
