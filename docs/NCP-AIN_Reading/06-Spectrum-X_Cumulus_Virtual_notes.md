# VXLAN
- Layer3 underlay
- Logical overlay
- VNI  # VXLAN Network Identifier, Global Significance
- VTEP # VXLAN Tunnel Endpoint
- VLAN # Local significance

VXLAN packet

- 'Outer Ethernet Header'             # Underlay Ethernet Frame
- 'Outer IP Header'                   # Underlay Ethernet Frame 
- 'Outer UDP Header, Dest Port 4789'  # Underlay Ethernet Frame
- 'VXLAN Header, 24bit VNI'           # Underlay Ethernet Frame
- 'Inner Ethernet Header'             # Overlay Network Ethernet Frame
- 'Original Payload'                  # Overlay Network Ethernet Frame
- 'Inner FCS'                         # Overlay Network Ethernet Frame
- 'Outer FCS'                         # Underlay Ethernet Frame

# EVPN
Control plan for VXLAN, MP-BGP

- SPINE-LEAF topo
- All SPINEs share same ASN
- Each LEAF has its own ASN
- SPINE establish EBGP with LEAF, unnumbered
- Each loopback is advertised into BGP, LEAF uses loopback as VTEP
- VNI is global significance
- VLAN is local significance

## EVPN route types

- Type 1 # Ethernet Auto-Discovery, for multihoming, multi-vtep to announce we are in the same group
- Type 2 # MAC/IP Advertisement, Core function
- Type 3 # Inclusive Multicast, BUM traffic, discover VTEP in the same VNI
- Type 4 # Ethernet Segment Route, elect DF, for multihoming elect DF for BUM traffic
- Type 5 # IP Prefix Route, network advertisement, for IP prefix rather than single host

Type3
- VTEP auto discovery and dynamically establish VXLAN tunnel
- Same tunnel for forward BUM traffic

Type2
- Learn MAC in VNI
- Proactive learning
- VTEP will advertise the MAC it gets, reduce BUM (ARP request .etc)

RD: Distinguish route in different VNI. For example, same MAC in different VNI.
FRR will auto generate RD in  "Router ID: VNI Index" format.

RT usual uses AS:VNI format.
System usually set import RT as *:VNI

```
Leaf1 VNI 10100
Export RT: 65000:10100
          │
          │ EVPN Type-2
          │ RT 65000:10100
          ▼
Leaf2 received the route
Import RT: 65000:10100
          │
          ├─ match → import VNI 10100
          │
          └─ not match → not import
```
Conect two VTEP's condition is `Leaf1's Export RT = Leaf2's Import RT`

# VXLAN Routing

## Centralized
Only one or one group of VTEP act as GW


## Distributed Asymmetric Routing
- Each VTEP config all VNI + L3 VNI
- Inbound route, outbound bridge
- Outbound VTEP bridge
- Simple, less route hops
- Doesn't support EVPN multihoming


## Distributed Symmetric Routing
- Each VTEP only config local VNI + L3 VNI
- Inbound route, outbound route
- Outbound VTEP route traffic from L3 VNI to Dest VNI
- High scalability
- Easy migration
- L3 VNI and VLAN config required
- NVIDIA perferred

# LAB to validate
- EVPN Centralized Routing
- EVPN Distributed Symmetric Routing
- EVPN Distributed Asymmetric Routing