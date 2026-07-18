# General BGP
Same as the normal BGP
Best route selection rules
1. Highest Weight # local only
2. Highest LP # Inside AS only
3. Originated by local # next-hop 0.0.0.0
4. Shortest AS path 
5. Lowest Origin code
6. Lowest MED
7. EBGP over IBGP
8. Path through the closet IGP neighbor
9. Oldest route for EBGP
10. Lowest neighbor BGP router ID
11. Lowest neighbor IP address

Enable ECMP, MAX 64
`nv set vrf default router bgp address-family ipv4-unicast multipaths ibgp <max path number>`
Support ECMP over different peer
`nv set vrf default router bgp path-selection multipath aspath-ignore on`
In order to do ECMP the following 8 value must be the same between the path
- Weight
- Local Prefrerence
- Locally Originated Routes
- AS Path
- Origin Code
- MED
- Neighbor Tyep(EBGP or IBGP)
- IGP Metric to next-hop

# BGP in Data Center

EBGP is perferred
Private ASN range:
- 2byte ASN: 64512 - 65534
- 4byte ASN: 4200000000 - 4294967294

ASN allocation rules:
- Super SPINE: All Super SPINE shares same ASN
- SPINE: The Spines in the same Pod share same ASN
- LEAF: Each Leaf swtich has its uniq ASN

## Auto-BGP ASN allocation

In two layers LEAF-SPINE topology, auto BGP automatically allocate ASN form the 4byte range
- SPINE: The first ASN in the range
- LEAF: Randomly allocated a uniq ASN

Key notes:
- Auto BGP only fit for two layer leaf-spine topo
- Leaf's ASN is Hashed from its MAC, thus it might be different after HW change

Default timer value for BGP in DC
- keepalive: 3 sec
- Holddown: 9 sec
- Advertisement interval: 0 sec
- Connect: 10 sec

## Config BGP

BGP config on LEAF
```
nv set router bgp autonomous-system 65101
nv set vrf default router bgp router-id 172.16.100.1
nv set vrf default router bgp neighbor 172.16.13.3 remote-as 65100
nv set vrf default router bgp neighbor 172.16.14.4 remote-as 65100
nv config apply
```
BGP config on SPINE
```
nv set router bgp autonomous-system 65100
nv set vrf default router bgp router-id 172.16.100.3
nv set vrf default router bgp neighbor 172.16.13.1 remote-as 65101
nv set vrf default router bgp neighbor 172.16.23.2 remote-as 65102
nv config apply
```
Advertise IP prefixes
```
nv set vrf default router bgp address-family ipv4-unicast network 172.16.18.0/24
nv set vrf default router bgp address-family ipv4-unicast network 172.16.19.0/24
```
Check BGP information
`nv show vrf default router bgp neighbor brief`

Validate routing table
`nv show vrf default router rib ipv4 route`

## BGP peer-group
A template for a group BGP nodes
It makes config easier, also for a group of BGP peers, system generate one BGP update and send to all.

BGP peer-group config
```
nv set vrf default router bgp peer-group SPINE
nv set vrf default router bgp peer-group SPINE remote-as external
nv set vrf default router bgp peer-group SPINE timers connection-retry 30
nv set vrf default router bgp peer-group SPINE timers route-advertisement 20
nv set vrf default router bgp neighbor 172.16.13.3 peer-group SPINE
nv set vrf default router bgp neighbor 172.16.14.4 peer-group SPINE
```
## BGP Unnumbered
Simply and increase the scalability of large scale network. BGP session established over the interfaces without assigned IP. 

The session is based on the ipv6 link-local address. IPv4 prefix exchange is over IPv6 BGP session.

## Config Unnumbered BGP
LEAF1
```
nv set interface lo ip address 172.16.100.1/32
nv set router bgp autonomous-system 65101
nv set vrf default router bgp router-id 172.16.100.1
nv set vrf default router bgp neighbor swp1 remote-as external
nv set vrf default router bgp neighbor swp2 remote-as external
nv set vrf default router bgp address-family ipv4-unicast network 172.16.18.0/24
nv set vrf default router bgp address-family ipv4-unicast network 172.16.19.0/24
nv config apply
```
LEAF2
```
nv set interface lo ip address 172.16.100.2/32
nv set router bgp autonomous-system 65102
nv set vrf default router bgp router-id 172.16.100.2
nv set vrf default router bgp neighbor swp1 remote-as external
nv set vrf default router bgp neighbor swp2 remote-as external
nv set vrf default router bgp address-family ipv4-unicast network 172.16.28.0/24
nv set vrf default router bgp address-family ipv4-unicast network 172.16.29.0/24
nv config apply
```
SPINE1
```
nv set interface lo ip address 172.16.100.3/32
nv set router bgp autonomous-system 65100
nv set vrf default router bgp router-id 172.16.100.3
nv set vrf default router bgp neighbor swp1 remote-as external
nv set vrf default router bgp neighbor swp2 remote-as external
nv config apply
```
SPINE2
```
nv set interface lo ip address 172.16.100.4/32
nv set router bgp autonomous-system 65100
nv set vrf default router bgp router-id 172.16.100.4
nv set vrf default router bgp neighbor swp1 remote-as external
nv set vrf default router bgp neighbor swp2 remote-as external
nv config apply
```


