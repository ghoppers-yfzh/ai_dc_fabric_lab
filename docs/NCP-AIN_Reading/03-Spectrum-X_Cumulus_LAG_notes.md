# Bond
- Every physical port can only join one bond
- Intf name starts with "bond", NVE sets the interface type to bond automatically.
- Intf name doesn't start with "bond", interface type needs to be manually set as bond.

# LACP
Cumulus Linux uses LACP v1

Config for bond
```
nv set interface bond56 bond member swp5-6
nv set interface bond56 bridge domain br_default
nv config apply
```
Interface setup is in `/etc/network/interfaces' as usual debian setup

LACP bypass allows LACP bond becomes active without peer, this is useful for some env, PXE for example.

`nv show interface bond1 bond` check bond interface status

## load-balance
Based on Src/Dst IP, MAC and port number.
`nv show system forwarding lag-hash` checks current values

Remove some value from LB hash
- `nv set system forwarding lag-hash source-mac off`
- `nv set system forwarding lag-hash destination-mac off`

# MLAG
- Almost the same as Cisco vPC
- MLAG has Peerlink
- Vlan4094 and its SVI will setup for communication
- Each peer MLAG swtiches uses a Uniq MAC, NVIDIA's reserved MAC range is `00:00:5E:00:01:XX`
- Backup IP is used to check peer switch, this is like the Cisco vPC keepalive
- Backup IP can use mgmt
- Peerlink is used to sync information, for example MAC, VLAN, MLAG ID

Config
```
nv set interface peerlink bond member swp3-4
nv set mlag mac-address 44:38:39:00:00:0C
nv set mlag backup 192.168.200.5 vrf mgmt
nv set mlag priority 1000
nv set mlag peer-ip linklocal
nv config apply
nv set interface bond1 bond member swp1
nv set bridge domain br_default vlan 1-3
nv set interface bond1 bridge domain br_default
nv config apply
nv set interface bond1 bond mlag id 1
nv config apply
nv show mlag
```
Check status
- `nv show mlag`
- `clagctl`
