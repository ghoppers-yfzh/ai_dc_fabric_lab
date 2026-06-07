]633;E;echo "# EVPN Routes and VNI State";fbf5a41f-2d56-4ae0-adfc-bae181e9a759]633;C# EVPN Routes and VNI State

## leaf1 show evpn vni
VNI        Type VxLAN IF              # MACs   # ARPs   # Remote VTEPs  Tenant VRF                           
10010      L2   vxlan10010            2        0        1               default                              

## leaf1 EVPN routes
BGP table version is 2, local router ID is 10.255.1.1
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal
Origin codes: i - IGP, e - EGP, ? - incomplete
EVPN type-1 prefix: [1]:[EthTag]:[ESI]:[IPlen]:[VTEP-IP]:[Frag-id]
EVPN type-2 prefix: [2]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]
EVPN type-3 prefix: [3]:[EthTag]:[IPlen]:[OrigIP]
EVPN type-4 prefix: [4]:[ESI]:[IPlen]:[OrigIP]
EVPN type-5 prefix: [5]:[EthTag]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 10.255.1.1:2
*> [2]:[0]:[48]:[aa:c1:ab:cc:87:c0]
                    10.255.1.1                         32768 i
                    ET:8 RT:65101:10010
*> [3]:[0]:[32]:[10.255.1.1]
                    10.255.1.1                         32768 i
                    ET:8 RT:65101:10010
Route Distinguisher: 10.255.1.2:2
*  [2]:[0]:[48]:[aa:c1:ab:fd:92:8e]
                    10.255.1.2                             0 65000 65102 i
                    RT:65102:10010 ET:8
*>                  10.255.1.2                             0 65000 65102 i
                    RT:65102:10010 ET:8
*  [3]:[0]:[32]:[10.255.1.2]
                    10.255.1.2                             0 65000 65102 i
                    RT:65102:10010 ET:8
*>                  10.255.1.2                             0 65000 65102 i
                    RT:65102:10010 ET:8

Displayed 4 out of 6 total prefixes

## leaf2 show evpn vni
VNI        Type VxLAN IF              # MACs   # ARPs   # Remote VTEPs  Tenant VRF                           
10010      L2   vxlan10010            2        0        1               default                              

## leaf2 EVPN routes
BGP table version is 2, local router ID is 10.255.1.2
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal
Origin codes: i - IGP, e - EGP, ? - incomplete
EVPN type-1 prefix: [1]:[EthTag]:[ESI]:[IPlen]:[VTEP-IP]:[Frag-id]
EVPN type-2 prefix: [2]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]
EVPN type-3 prefix: [3]:[EthTag]:[IPlen]:[OrigIP]
EVPN type-4 prefix: [4]:[ESI]:[IPlen]:[OrigIP]
EVPN type-5 prefix: [5]:[EthTag]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 10.255.1.1:2
*  [2]:[0]:[48]:[aa:c1:ab:cc:87:c0]
                    10.255.1.1                             0 65000 65101 i
                    RT:65101:10010 ET:8
*>                  10.255.1.1                             0 65000 65101 i
                    RT:65101:10010 ET:8
*  [3]:[0]:[32]:[10.255.1.1]
                    10.255.1.1                             0 65000 65101 i
                    RT:65101:10010 ET:8
*>                  10.255.1.1                             0 65000 65101 i
                    RT:65101:10010 ET:8
Route Distinguisher: 10.255.1.2:2
*> [2]:[0]:[48]:[aa:c1:ab:fd:92:8e]
                    10.255.1.2                         32768 i
                    ET:8 RT:65102:10010
*> [3]:[0]:[32]:[10.255.1.2]
                    10.255.1.2                         32768 i
                    ET:8 RT:65102:10010

Displayed 4 out of 6 total prefixes
