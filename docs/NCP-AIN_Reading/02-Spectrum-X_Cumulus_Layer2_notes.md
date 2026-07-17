# Agenda
- VLAN and Trunk
- Cumulus Linux Bridge
- SVI
- STP

# Cumulus Linux Bridge and VLAN
- Bridge is a layer2 domain
- Bridge is a logic interface, it has MAC and MTU
- By default, bridge inheritage the first port's MTU in the bridge port list

Bridge mode
- Traditional bridge mode # One bridge, one vlan
- VLAN-aware bridge mode  # One bridge, multiple vlan (Max 2000))

VLAN Aware Bridge config for 200 vlans
```
auto bridge
iface bridge
  bridge-vlan-aware yes
  bridge-ports swp1 swp2
  bridge-vids 1-200
  bridge pvid 1
```
Traditional Bridge config for 200 vlans
```
auto br-vlan1
iface br-vlan1
  bridge-ports swp1 swp2

auto br-vlan2
iface br-vlan2
  bridge-ports swp1 swp2

auto br-vlan3
iface br-vlan3
  bridge-ports swp1 swp2
  .
  .
  .
auto br-vlan200
iface br-vlan200
  bridge-ports swp1 swp2
```

## VLAN-Aware Bridge
VLAN-Aware bridge is like a smart traffic controller, forward traffic based on vlan tags

Some key points and restractions:
- By default, all vlans share single STP
- PVSTP can be enabled if required
- MAC learning and forwarding is per vlan based
- MLAG can not be setup cross multiple VLAN-aware bridges
- Each physical port can only join one vlan-aware bridge
- VNI must be uniqe between different bridges
- Some VLAN IDs are reserved, 3725-3999

Configuration
```
nv set interface swp1-2 bridge domain br_default
nv set bridge domain br_default vlan 1-3
nv set interface swp8 bridge domain br_default access 2
nv set interface swp9 bridge domain br_default access 3
nv config apply
```
Commands:
- Use `bridge vlan` to check port-VLAN member
- `nv set interface swp1 bridge domain br_default untagged none` drops untagged traffic, remove native VLAN
- `nv show bridge domain br_default mac-table` checks bridge's MAC address table
- `nv action clear bridge domain br_default mac-table dynamic` clears MAC table
- Default MAC address table timer is 1800s(30 mins), use `nv show bridge domain br_default` to check
- `nv set bridge domain br_default ageing 600` sets MAC table aging time to 600s

# SVI

Setup SVI
```
nv set interface vlan2 ip address 172.16.2.254/24
nv set interface vlan2 vlan 2
nv config apply
```
`ifquery vlan2` checks SVI (IP, status, vlanID)

# STP
RSTP is the default
Default STP priority is 32768
Commands:
```
# Set STP mode to Per vlan STP
nv set bridge domain br_default stp mode pvrst
# Set STP priority
nv set bridge domain br_default stp priority 4096
# STP edge port must has BGPDU guard enabled at the same time
nv set interface swp8 bridge domain br_default stp admin-edge on
nv set interface swp8 bridge domain br_default stp bpdu-guard on
# PortAutoEdge, it switchs the port to normal STP when receiving BPDU, otherwise it is edge port, it is enabled by default
nv set interface swp1 bridge domain br_default stp auto-edge on
# Check STP inforamtion
nv show bridge domain br_default stp
# Check STP operational status and config status
nv show interface swp1 bridge domain br_default stp

