# Four-leaf L3VNI VRF Validation

## VRF VNI mapping

### leaf1
VRF                                   VNI        VxLAN IF             L3-SVI               State Rmac              
tenant-a                              10099      vxlan10099           br10099              Up    00:00:00:99:00:01 

### leaf2
VRF                                   VNI        VxLAN IF             L3-SVI               State Rmac              
tenant-a                              10099      vxlan10099           br10099              Up    00:00:00:99:00:02 

### leaf3
VRF                                   VNI        VxLAN IF             L3-SVI               State Rmac              
tenant-a                              10099      vxlan10099           br10099              Up    00:00:00:99:00:03 

### leaf4
VRF                                   VNI        VxLAN IF             L3-SVI               State Rmac              
tenant-a                              10099      vxlan10099           br10099              Up    00:00:00:99:00:04 

## VRF routes

### leaf1
192.168.10.0/24 dev br10 proto kernel scope link src 192.168.10.1 
192.168.10.12 nhid 51 via 10.255.1.2 dev br10099 proto bgp metric 20 onlink 
192.168.20.0/24 nhid 43 proto bgp metric 20 
	nexthop via 10.255.1.3 dev br10099 weight 1 onlink 
	nexthop via 10.255.1.4 dev br10099 weight 1 onlink 
192.168.20.13 nhid 35 via 10.255.1.3 dev br10099 proto bgp metric 20 onlink 
192.168.20.14 nhid 44 via 10.255.1.4 dev br10099 proto bgp metric 20 onlink 

### leaf2
192.168.10.0/24 dev br10 proto kernel scope link src 192.168.10.1 
192.168.10.11 nhid 48 via 10.255.1.1 dev br10099 proto bgp metric 20 onlink 
192.168.20.0/24 nhid 43 proto bgp metric 20 
	nexthop via 10.255.1.3 dev br10099 weight 1 onlink 
	nexthop via 10.255.1.4 dev br10099 weight 1 onlink 
192.168.20.13 nhid 27 via 10.255.1.3 dev br10099 proto bgp metric 20 onlink 
192.168.20.14 nhid 44 via 10.255.1.4 dev br10099 proto bgp metric 20 onlink 

### leaf3
192.168.10.0/24 nhid 49 proto bgp metric 20 
	nexthop via 10.255.1.2 dev br10099 weight 1 onlink 
	nexthop via 10.255.1.1 dev br10099 weight 1 onlink 
192.168.10.11 nhid 50 via 10.255.1.1 dev br10099 proto bgp metric 20 onlink 
192.168.10.12 nhid 37 via 10.255.1.2 dev br10099 proto bgp metric 20 onlink 
192.168.20.0/24 dev br20 proto kernel scope link src 192.168.20.1 
192.168.20.14 nhid 53 via 10.255.1.4 dev br10099 proto bgp metric 20 onlink 

### leaf4
192.168.10.0/24 nhid 39 proto bgp metric 20 
	nexthop via 10.255.1.2 dev br10099 weight 1 onlink 
	nexthop via 10.255.1.1 dev br10099 weight 1 onlink 
192.168.10.11 nhid 40 via 10.255.1.1 dev br10099 proto bgp metric 20 onlink 
192.168.10.12 nhid 35 via 10.255.1.2 dev br10099 proto bgp metric 20 onlink 
192.168.20.0/24 dev br20 proto kernel scope link src 192.168.20.1 
192.168.20.13 nhid 50 via 10.255.1.3 dev br10099 proto bgp metric 20 onlink 

## EVPN routes

### leaf1
BGP table version is 4, local router ID is 10.255.1.1
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal
Origin codes: i - IGP, e - EGP, ? - incomplete
EVPN type-1 prefix: [1]:[EthTag]:[ESI]:[IPlen]:[VTEP-IP]:[Frag-id]
EVPN type-2 prefix: [2]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]
EVPN type-3 prefix: [3]:[EthTag]:[IPlen]:[OrigIP]
EVPN type-4 prefix: [4]:[ESI]:[IPlen]:[OrigIP]
EVPN type-5 prefix: [5]:[EthTag]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 10.255.1.1:2
*> [2]:[0]:[48]:[aa:c1:ab:64:5e:e8]
                    10.255.1.1                         32768 i
                    ET:8 RT:65000:10010
*> [2]:[0]:[48]:[aa:c1:ab:64:5e:e8]:[32]:[192.168.10.11]
                    10.255.1.1                         32768 i
                    ET:8 RT:65000:10010 RT:65000:10099 Rmac:00:00:00:99:00:01
*> [3]:[0]:[32]:[10.255.1.1]
                    10.255.1.1                         32768 i
                    ET:8 RT:65000:10010
Route Distinguisher: 10.255.1.1:3
*> [5]:[0]:[24]:[192.168.10.0]
                    10.255.1.1               0         32768 ?
                    ET:8 RT:65000:10099 Rmac:00:00:00:99:00:01
Route Distinguisher: 10.255.1.2:2
*  [2]:[0]:[48]:[aa:c1:ab:95:bd:a8]
                    10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*>                  10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*  [2]:[0]:[48]:[aa:c1:ab:95:bd:a8]:[32]:[192.168.10.12]
                    10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:02
*>                  10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:02
*  [3]:[0]:[32]:[10.255.1.2]
                    10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*>                  10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
Route Distinguisher: 10.255.1.2:3
*  [5]:[0]:[24]:[192.168.10.0]
                    10.255.1.2                             0 65000 65102 ?
                    RT:65000:10099 ET:8 Rmac:00:00:00:99:00:02
*>                  10.255.1.2                             0 65000 65102 ?
                    RT:65000:10099 ET:8 Rmac:00:00:00:99:00:02
Route Distinguisher: 10.255.1.3:2
*  [2]:[0]:[48]:[aa:c1:ab:5d:fb:f9]
                    10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*>                  10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*  [2]:[0]:[48]:[aa:c1:ab:5d:fb:f9]:[32]:[192.168.20.13]
                    10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:03
*>                  10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:03
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
*  [2]:[0]:[48]:[aa:c1:ab:14:73:da]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*>                  10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*  [2]:[0]:[48]:[aa:c1:ab:14:73:da]:[32]:[192.168.20.14]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:04
*>                  10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:04
*  [3]:[0]:[32]:[10.255.1.4]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*>                  10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
Route Distinguisher: 10.255.1.4:3
*  [5]:[0]:[24]:[192.168.20.0]
                    10.255.1.4                             0 65000 65104 ?
                    RT:65000:10099 ET:8 Rmac:00:00:00:99:00:04
*>                  10.255.1.4                             0 65000 65104 ?
                    RT:65000:10099 ET:8 Rmac:00:00:00:99:00:04

Displayed 16 out of 28 total prefixes

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
*  [2]:[0]:[48]:[aa:c1:ab:64:5e:e8]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*>                  10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*  [2]:[0]:[48]:[aa:c1:ab:64:5e:e8]:[32]:[192.168.10.11]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:01
*>                  10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:01
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
*> [2]:[0]:[48]:[aa:c1:ab:95:bd:a8]
                    10.255.1.2                         32768 i
                    ET:8 RT:65000:10010
*> [2]:[0]:[48]:[aa:c1:ab:95:bd:a8]:[32]:[192.168.10.12]
                    10.255.1.2                         32768 i
                    ET:8 RT:65000:10010 RT:65000:10099 Rmac:00:00:00:99:00:02
*> [3]:[0]:[32]:[10.255.1.2]
                    10.255.1.2                         32768 i
                    ET:8 RT:65000:10010
Route Distinguisher: 10.255.1.2:3
*> [5]:[0]:[24]:[192.168.10.0]
                    10.255.1.2               0         32768 ?
                    ET:8 RT:65000:10099 Rmac:00:00:00:99:00:02
Route Distinguisher: 10.255.1.3:2
*  [2]:[0]:[48]:[aa:c1:ab:5d:fb:f9]
                    10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*>                  10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*  [2]:[0]:[48]:[aa:c1:ab:5d:fb:f9]:[32]:[192.168.20.13]
                    10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:03
*>                  10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:03
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
*  [2]:[0]:[48]:[aa:c1:ab:14:73:da]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*>                  10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*  [2]:[0]:[48]:[aa:c1:ab:14:73:da]:[32]:[192.168.20.14]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:04
*>                  10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:04
*  [3]:[0]:[32]:[10.255.1.4]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*>                  10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
Route Distinguisher: 10.255.1.4:3
*  [5]:[0]:[24]:[192.168.20.0]
                    10.255.1.4                             0 65000 65104 ?
                    RT:65000:10099 ET:8 Rmac:00:00:00:99:00:04
*>                  10.255.1.4                             0 65000 65104 ?
                    RT:65000:10099 ET:8 Rmac:00:00:00:99:00:04

Displayed 16 out of 28 total prefixes

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
*  [2]:[0]:[48]:[aa:c1:ab:64:5e:e8]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*>                  10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*  [2]:[0]:[48]:[aa:c1:ab:64:5e:e8]:[32]:[192.168.10.11]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:01
*>                  10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:01
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
*  [2]:[0]:[48]:[aa:c1:ab:95:bd:a8]
                    10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*>                  10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*  [2]:[0]:[48]:[aa:c1:ab:95:bd:a8]:[32]:[192.168.10.12]
                    10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:02
*>                  10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:02
*  [3]:[0]:[32]:[10.255.1.2]
                    10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*>                  10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
Route Distinguisher: 10.255.1.2:3
*  [5]:[0]:[24]:[192.168.10.0]
                    10.255.1.2                             0 65000 65102 ?
                    RT:65000:10099 ET:8 Rmac:00:00:00:99:00:02
*>                  10.255.1.2                             0 65000 65102 ?
                    RT:65000:10099 ET:8 Rmac:00:00:00:99:00:02
Route Distinguisher: 10.255.1.3:2
*> [2]:[0]:[48]:[aa:c1:ab:5d:fb:f9]
                    10.255.1.3                         32768 i
                    ET:8 RT:65000:10020
*> [2]:[0]:[48]:[aa:c1:ab:5d:fb:f9]:[32]:[192.168.20.13]
                    10.255.1.3                         32768 i
                    ET:8 RT:65000:10020 RT:65000:10099 Rmac:00:00:00:99:00:03
*> [3]:[0]:[32]:[10.255.1.3]
                    10.255.1.3                         32768 i
                    ET:8 RT:65000:10020
Route Distinguisher: 10.255.1.3:3
*> [5]:[0]:[24]:[192.168.20.0]
                    10.255.1.3               0         32768 ?
                    ET:8 RT:65000:10099 Rmac:00:00:00:99:00:03
Route Distinguisher: 10.255.1.4:2
*  [2]:[0]:[48]:[aa:c1:ab:14:73:da]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*>                  10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*  [2]:[0]:[48]:[aa:c1:ab:14:73:da]:[32]:[192.168.20.14]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:04
*>                  10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:04
*  [3]:[0]:[32]:[10.255.1.4]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
*>                  10.255.1.4                             0 65000 65104 i
                    RT:65000:10020 ET:8
Route Distinguisher: 10.255.1.4:3
*  [5]:[0]:[24]:[192.168.20.0]
                    10.255.1.4                             0 65000 65104 ?
                    RT:65000:10099 ET:8 Rmac:00:00:00:99:00:04
*>                  10.255.1.4                             0 65000 65104 ?
                    RT:65000:10099 ET:8 Rmac:00:00:00:99:00:04

Displayed 16 out of 28 total prefixes

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
*> [2]:[0]:[48]:[aa:c1:ab:64:5e:e8]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*                   10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*  [2]:[0]:[48]:[aa:c1:ab:64:5e:e8]:[32]:[192.168.10.11]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:01
*>                  10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:01
*> [3]:[0]:[32]:[10.255.1.1]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*                   10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
Route Distinguisher: 10.255.1.1:3
*  [5]:[0]:[24]:[192.168.10.0]
                    10.255.1.1                             0 65000 65101 ?
                    RT:65000:10099 ET:8 Rmac:00:00:00:99:00:01
*>                  10.255.1.1                             0 65000 65101 ?
                    RT:65000:10099 ET:8 Rmac:00:00:00:99:00:01
Route Distinguisher: 10.255.1.2:2
*  [2]:[0]:[48]:[aa:c1:ab:95:bd:a8]
                    10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*>                  10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*  [2]:[0]:[48]:[aa:c1:ab:95:bd:a8]:[32]:[192.168.10.12]
                    10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:02
*>                  10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:02
*  [3]:[0]:[32]:[10.255.1.2]
                    10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*>                  10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
Route Distinguisher: 10.255.1.2:3
*  [5]:[0]:[24]:[192.168.10.0]
                    10.255.1.2                             0 65000 65102 ?
                    RT:65000:10099 ET:8 Rmac:00:00:00:99:00:02
*>                  10.255.1.2                             0 65000 65102 ?
                    RT:65000:10099 ET:8 Rmac:00:00:00:99:00:02
Route Distinguisher: 10.255.1.3:2
*  [2]:[0]:[48]:[aa:c1:ab:5d:fb:f9]
                    10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*>                  10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 ET:8
*  [2]:[0]:[48]:[aa:c1:ab:5d:fb:f9]:[32]:[192.168.20.13]
                    10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:03
*>                  10.255.1.3                             0 65000 65103 i
                    RT:65000:10020 RT:65000:10099 ET:8 Rmac:00:00:00:99:00:03
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
*> [2]:[0]:[48]:[aa:c1:ab:14:73:da]
                    10.255.1.4                         32768 i
                    ET:8 RT:65000:10020
*> [2]:[0]:[48]:[aa:c1:ab:14:73:da]:[32]:[192.168.20.14]
                    10.255.1.4                         32768 i
                    ET:8 RT:65000:10020 RT:65000:10099 Rmac:00:00:00:99:00:04
*> [3]:[0]:[32]:[10.255.1.4]
                    10.255.1.4                         32768 i
                    ET:8 RT:65000:10020
Route Distinguisher: 10.255.1.4:3
*> [5]:[0]:[24]:[192.168.20.0]
                    10.255.1.4               0         32768 ?
                    ET:8 RT:65000:10099 Rmac:00:00:00:99:00:04

Displayed 16 out of 28 total prefixes

## Cross-subnet host reachability

### host1 to host3
PING 192.168.20.13 (192.168.20.13) 56(84) bytes of data.
64 bytes from 192.168.20.13: icmp_seq=1 ttl=62 time=0.193 ms
64 bytes from 192.168.20.13: icmp_seq=2 ttl=62 time=0.162 ms
64 bytes from 192.168.20.13: icmp_seq=3 ttl=62 time=0.129 ms

--- 192.168.20.13 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2053ms
rtt min/avg/max/mdev = 0.129/0.161/0.193/0.026 ms

### host1 to host4
PING 192.168.20.14 (192.168.20.14) 56(84) bytes of data.
64 bytes from 192.168.20.14: icmp_seq=1 ttl=62 time=0.201 ms
64 bytes from 192.168.20.14: icmp_seq=2 ttl=62 time=0.153 ms
64 bytes from 192.168.20.14: icmp_seq=3 ttl=62 time=0.112 ms

--- 192.168.20.14 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2035ms
rtt min/avg/max/mdev = 0.112/0.155/0.201/0.036 ms

### host2 to host3
PING 192.168.20.13 (192.168.20.13) 56(84) bytes of data.
64 bytes from 192.168.20.13: icmp_seq=1 ttl=62 time=0.272 ms
64 bytes from 192.168.20.13: icmp_seq=2 ttl=62 time=0.181 ms
64 bytes from 192.168.20.13: icmp_seq=3 ttl=62 time=0.108 ms

--- 192.168.20.13 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2041ms
rtt min/avg/max/mdev = 0.108/0.187/0.272/0.067 ms

### host2 to host4
PING 192.168.20.14 (192.168.20.14) 56(84) bytes of data.
64 bytes from 192.168.20.14: icmp_seq=1 ttl=62 time=0.256 ms
64 bytes from 192.168.20.14: icmp_seq=2 ttl=62 time=0.109 ms
64 bytes from 192.168.20.14: icmp_seq=3 ttl=62 time=0.107 ms

--- 192.168.20.14 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2041ms
rtt min/avg/max/mdev = 0.107/0.157/0.256/0.069 ms

### host3 to host1
PING 192.168.10.11 (192.168.10.11) 56(84) bytes of data.
64 bytes from 192.168.10.11: icmp_seq=1 ttl=62 time=0.243 ms
64 bytes from 192.168.10.11: icmp_seq=2 ttl=62 time=0.109 ms
64 bytes from 192.168.10.11: icmp_seq=3 ttl=62 time=0.199 ms

--- 192.168.10.11 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2053ms
rtt min/avg/max/mdev = 0.109/0.183/0.243/0.055 ms

### host3 to host2
PING 192.168.10.12 (192.168.10.12) 56(84) bytes of data.
64 bytes from 192.168.10.12: icmp_seq=1 ttl=62 time=0.257 ms
64 bytes from 192.168.10.12: icmp_seq=2 ttl=62 time=0.108 ms
64 bytes from 192.168.10.12: icmp_seq=3 ttl=62 time=0.106 ms

--- 192.168.10.12 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2049ms
rtt min/avg/max/mdev = 0.106/0.157/0.257/0.070 ms

### host4 to host1
PING 192.168.10.11 (192.168.10.11) 56(84) bytes of data.
64 bytes from 192.168.10.11: icmp_seq=1 ttl=62 time=0.259 ms
64 bytes from 192.168.10.11: icmp_seq=2 ttl=62 time=0.107 ms
64 bytes from 192.168.10.11: icmp_seq=3 ttl=62 time=0.121 ms

--- 192.168.10.11 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2040ms
rtt min/avg/max/mdev = 0.107/0.162/0.259/0.068 ms

### host4 to host2
PING 192.168.10.12 (192.168.10.12) 56(84) bytes of data.
64 bytes from 192.168.10.12: icmp_seq=1 ttl=62 time=0.224 ms
64 bytes from 192.168.10.12: icmp_seq=2 ttl=62 time=0.193 ms
64 bytes from 192.168.10.12: icmp_seq=3 ttl=62 time=0.112 ms

--- 192.168.10.12 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2049ms
rtt min/avg/max/mdev = 0.112/0.176/0.224/0.047 ms
