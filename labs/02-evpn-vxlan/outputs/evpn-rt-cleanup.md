]633;E;echo "# EVPN Route Target Cleanup Validation";fbf5a41f-2d56-4ae0-adfc-bae181e9a759]633;C# EVPN Route Target Cleanup Validation

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
*> [2]:[0]:[48]:[aa:c1:ab:fc:81:0c]
                    10.255.1.1                         32768 i
                    ET:8 RT:65000:10010
*> [3]:[0]:[32]:[10.255.1.1]
                    10.255.1.1                         32768 i
                    ET:8 RT:65000:10010
Route Distinguisher: 10.255.1.2:2
*> [2]:[0]:[48]:[aa:c1:ab:1f:a5:1d]
                    10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*                   10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*> [3]:[0]:[32]:[10.255.1.2]
                    10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8
*                   10.255.1.2                             0 65000 65102 i
                    RT:65000:10010 ET:8

Displayed 4 out of 6 total prefixes

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
*> [2]:[0]:[48]:[aa:c1:ab:fc:81:0c]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*                   10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*> [3]:[0]:[32]:[10.255.1.1]
                    10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
*                   10.255.1.1                             0 65000 65101 i
                    RT:65000:10010 ET:8
Route Distinguisher: 10.255.1.2:2
*> [2]:[0]:[48]:[aa:c1:ab:1f:a5:1d]
                    10.255.1.2                         32768 i
                    ET:8 RT:65000:10010
*> [3]:[0]:[32]:[10.255.1.2]
                    10.255.1.2                         32768 i
                    ET:8 RT:65000:10010

Displayed 4 out of 6 total prefixes

## host1 to host2
PING 192.168.10.12 (192.168.10.12) 56(84) bytes of data.
64 bytes from 192.168.10.12: icmp_seq=1 ttl=64 time=0.145 ms
64 bytes from 192.168.10.12: icmp_seq=2 ttl=64 time=0.082 ms
64 bytes from 192.168.10.12: icmp_seq=3 ttl=64 time=0.113 ms

--- 192.168.10.12 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2027ms
rtt min/avg/max/mdev = 0.082/0.113/0.145/0.025 ms

## host2 to host1
PING 192.168.10.11 (192.168.10.11) 56(84) bytes of data.
64 bytes from 192.168.10.11: icmp_seq=1 ttl=64 time=0.138 ms
64 bytes from 192.168.10.11: icmp_seq=2 ttl=64 time=0.078 ms
64 bytes from 192.168.10.11: icmp_seq=3 ttl=64 time=0.078 ms

--- 192.168.10.11 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2047ms
rtt min/avg/max/mdev = 0.078/0.098/0.138/0.028 ms
