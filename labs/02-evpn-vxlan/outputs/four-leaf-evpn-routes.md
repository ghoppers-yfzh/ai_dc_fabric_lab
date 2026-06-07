]633;E;echo "# Four-Leaf EVPN Routes";fbf5a41f-2d56-4ae0-adfc-bae181e9a759]633;C# Four-Leaf EVPN Routes

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
*> [2]:[0]:[48]:[aa:c1:ab:8f:c2:9c]
                    10.255.1.1                         32768 i
                    ET:8 RT:65000:10010
*> [3]:[0]:[32]:[10.255.1.1]
                    10.255.1.1                         32768 i
                    ET:8 RT:65000:10010
Route Distinguisher: 10.255.1.2:2
*> [2]:[0]:[48]:[aa:c1:ab:8f:be:bb]
                    10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*> [3]:[0]:[32]:[10.255.1.2]
                    10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
Route Distinguisher: 10.255.1.3:2
*> [2]:[0]:[48]:[aa:c1:ab:b1:5f:e1]
                    10.255.1.3                             0 65000 65103 i
                    RT:65000:10010 ET:8
*> [3]:[0]:[32]:[10.255.1.3]
                    10.255.1.3                             0 65000 65103 i
                    RT:65000:10010 ET:8
Route Distinguisher: 10.255.1.4:2
*> [2]:[0]:[48]:[aa:c1:ab:59:5a:40]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10010 ET:8
*> [3]:[0]:[32]:[10.255.1.4]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10010 ET:8

Displayed 8 out of 8 total prefixes

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
*> [2]:[0]:[48]:[aa:c1:ab:8f:c2:9c]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*> [3]:[0]:[32]:[10.255.1.1]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
Route Distinguisher: 10.255.1.2:2
*> [2]:[0]:[48]:[aa:c1:ab:8f:be:bb]
                    10.255.1.2                         32768 i
                    ET:8 RT:65000:10010
*> [3]:[0]:[32]:[10.255.1.2]
                    10.255.1.2                         32768 i
                    ET:8 RT:65000:10010
Route Distinguisher: 10.255.1.3:2
*  [2]:[0]:[48]:[aa:c1:ab:b1:5f:e1]
                    10.255.1.3                             0 65000 65103 i
                    RT:65000:10010 ET:8
*>                  10.255.1.3                             0 65000 65103 i
                    RT:65000:10010 ET:8
*  [3]:[0]:[32]:[10.255.1.3]
                    10.255.1.3                             0 65000 65103 i
                    RT:65000:10010 ET:8
*>                  10.255.1.3                             0 65000 65103 i
                    RT:65000:10010 ET:8
Route Distinguisher: 10.255.1.4:2
*  [2]:[0]:[48]:[aa:c1:ab:59:5a:40]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10010 ET:8
*>                  10.255.1.4                             0 65000 65104 i
                    RT:65000:10010 ET:8
*  [3]:[0]:[32]:[10.255.1.4]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10010 ET:8
*>                  10.255.1.4                             0 65000 65104 i
                    RT:65000:10010 ET:8

Displayed 8 out of 12 total prefixes

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
*> [2]:[0]:[48]:[aa:c1:ab:8f:c2:9c]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*> [3]:[0]:[32]:[10.255.1.1]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
Route Distinguisher: 10.255.1.2:2
*  [2]:[0]:[48]:[aa:c1:ab:8f:be:bb]
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
*> [2]:[0]:[48]:[aa:c1:ab:b1:5f:e1]
                    10.255.1.3                         32768 i
                    ET:8 RT:65000:10010
*> [3]:[0]:[32]:[10.255.1.3]
                    10.255.1.3                         32768 i
                    ET:8 RT:65000:10010
Route Distinguisher: 10.255.1.4:2
*  [2]:[0]:[48]:[aa:c1:ab:59:5a:40]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10010 ET:8
*>                  10.255.1.4                             0 65000 65104 i
                    RT:65000:10010 ET:8
*  [3]:[0]:[32]:[10.255.1.4]
                    10.255.1.4                             0 65000 65104 i
                    RT:65000:10010 ET:8
*>                  10.255.1.4                             0 65000 65104 i
                    RT:65000:10010 ET:8

Displayed 8 out of 12 total prefixes

## leaf4 EVPN routes
BGP table version is 2, local router ID is 10.255.1.4
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal
Origin codes: i - IGP, e - EGP, ? - incomplete
EVPN type-1 prefix: [1]:[EthTag]:[ESI]:[IPlen]:[VTEP-IP]:[Frag-id]
EVPN type-2 prefix: [2]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]
EVPN type-3 prefix: [3]:[EthTag]:[IPlen]:[OrigIP]
EVPN type-4 prefix: [4]:[ESI]:[IPlen]:[OrigIP]
EVPN type-5 prefix: [5]:[EthTag]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
Route Distinguisher: 10.255.1.1:2
*> [2]:[0]:[48]:[aa:c1:ab:8f:c2:9c]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*> [3]:[0]:[32]:[10.255.1.1]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
Route Distinguisher: 10.255.1.2:2
*  [2]:[0]:[48]:[aa:c1:ab:8f:be:bb]
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
*  [2]:[0]:[48]:[aa:c1:ab:b1:5f:e1]
                    10.255.1.3                             0 65000 65103 i
                    RT:65000:10010 ET:8
*>                  10.255.1.3                             0 65000 65103 i
                    RT:65000:10010 ET:8
*  [3]:[0]:[32]:[10.255.1.3]
                    10.255.1.3                             0 65000 65103 i
                    RT:65000:10010 ET:8
*>                  10.255.1.3                             0 65000 65103 i
                    RT:65000:10010 ET:8
Route Distinguisher: 10.255.1.4:2
*> [2]:[0]:[48]:[aa:c1:ab:59:5a:40]
                    10.255.1.4                         32768 i
                    ET:8 RT:65000:10010
*> [3]:[0]:[32]:[10.255.1.4]
                    10.255.1.4                         32768 i
                    ET:8 RT:65000:10010

Displayed 8 out of 12 total prefixes

