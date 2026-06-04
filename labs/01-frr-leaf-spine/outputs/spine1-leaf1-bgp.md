## SPINE1 basic bgp config
```
spine1# sh run
Building configuration...

Current configuration:
!
frr version 8.4_git
frr defaults traditional
hostname spine1
no ipv6 forwarding
!
interface eth1
 ip address 10.0.0.0/31
exit
!
interface lo
 ip address 10.255.0.1/32
exit
!
router bgp 65000
 bgp router-id 10.255.0.1
 no bgp ebgp-requires-policy
 neighbor 10.0.0.1 remote-as 65101
 !
 address-family ipv4 unicast
  network 10.255.0.1/32
 exit-address-family
exit
!
end
spine1# show interface brief 
Interface       Status  VRF             Addresses
---------       ------  ---             ---------
eth0            up      default         172.20.20.7/24
                                        + 3fff:172:20:20::7/64
eth1            up      default         10.0.0.0/31
eth2            up      default         
eth3            up      default         
eth4            up      default         
lo              up      default         10.255.0.1/32

spine1# show bgp summary 

IPv4 Unicast Summary (VRF default):
BGP router identifier 10.255.0.1, local AS number 65000 vrf-id 0
BGP table version 2
RIB entries 3, using 576 bytes of memory
Peers 1, using 717 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.0.1        4      65101        24        26        0    0    0 00:01:46            1        2 N/A

Total number of neighbors 1
spine1# show ip route
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

K>* 0.0.0.0/0 [0/0] via 172.20.20.1, eth0, 00:11:32
C>* 10.0.0.0/31 is directly connected, eth1, 00:07:56
C>* 10.255.0.1/32 is directly connected, lo, 00:07:24
B>* 10.255.1.1/32 [20/0] via 10.0.0.1, eth1, weight 1, 00:01:48
C>* 172.20.20.0/24 is directly connected, eth0, 00:11:32
spine1# 
```




## LEAF1 basic bgp config
```
leaf1# sh run
Building configuration...

Current configuration:
!
frr version 8.4_git
frr defaults traditional
hostname leaf1
no ipv6 forwarding
!
interface eth1
 ip address 10.0.0.1/31
exit
!
interface lo
 ip address 10.255.1.1/32
exit
!
router bgp 65101
 bgp router-id 10.255.1.1
 no bgp ebgp-requires-policy
 neighbor 10.0.0.0 remote-as 65000
 !
 address-family ipv4 unicast
  network 10.255.1.1/32
 exit-address-family
exit
!
end
leaf1# sh bgp summary 

IPv4 Unicast Summary (VRF default):
BGP router identifier 10.255.1.1, local AS number 65101 vrf-id 0
BGP table version 2
RIB entries 3, using 576 bytes of memory
Peers 1, using 717 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.0.0        4      65000        20        19        0    0    0 00:00:50            1        2 N/A

Total number of neighbors 1
leaf1# sh interface brief 
Interface       Status  VRF             Addresses
---------       ------  ---             ---------
eth0            up      default         172.20.20.2/24
                                        + 3fff:172:20:20::2/64
eth1            up      default         10.0.0.1/31
eth2            up      default         
eth3            up      default         
lo              up      default         10.255.1.1/32

leaf1# show ip route
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

K>* 0.0.0.0/0 [0/0] via 172.20.20.1, eth0, 00:10:44
C>* 10.0.0.0/31 is directly connected, eth1, 00:04:59
B>* 10.255.0.1/32 [20/0] via 10.0.0.0, eth1, weight 1, 00:00:59
C>* 10.255.1.1/32 is directly connected, lo, 00:05:10
C>* 172.20.20.0/24 is directly connected, eth0, 00:10:44
leaf1# 
```