
# Default Gateway

## VRRP
- Active-standy
- Only the master forwarding traffic

## VRR
- active-active 
- Must be used with MLAG together
- Multiple switches share same virtual MAC and IP, forward traffic at the same time
- Virtual MAC range: 00:00:5E:00:01:00 to 00:00:5E:00:01:ff
- Cumulus linux only support VRR on SVI, not on physical port or sub-interface

VRR configuration
```
# SPINE3 config
nv set interface vlan2 vlan 2
nv set interface vlan2 ip address 172.16.2.252/24
nv set interface vlan2 ip vrr address 172.16.2.254/24
nv set interface vlan2 ip vrr mac-address 00:00:5e:00:01:02

nv set interface vlan3 vlan 3
nv set interface vlan3 ip address 172.16.3.252/24
nv set interface vlan3 ip vrr address 172.16.3.254/24
nv set interface vlan3 ip vrr mac-address 00:00:5e:00:01:03

# SPINE4 config
nv set interface vlan2 vlan 2
nv set interface vlan2 ip address 172.16.2.253/24
nv set interface vlan2 vrr address 172.16.2.254/24
nv set interface vlan2 vrr mac-address 00:00:5e:00:01:02

nv set interface vlan3 vlan 3
nv set interface vlan3 ip address 172.16.3.253/24
nv set interface vlan3 vrr address 172.16.3.254
nv set interface vlan3 vrr mac-address 00:00:5e:00:01:02
nv config apply
```
Some check command
```
# check interface status
nv show interface
# check vlan2 vrr virtual interface
nv show interface vlan2-v0

# VRF
MAX: 255
mgmt is a reserved vrf

VRF is also show as network interface in the system, check with `nv show interface`



Setup a vrf and attach interface to it.
```
nv set vrf BLUE table auto
nv set interface swp1 ip vrf BLUE
nv config apply
```

Using VRF
```
# Start service in specified VRF
sudo systemctl start dhcpd@BLUE

# ping in vrf
ping -I mgmt 10.143.33.187
# Tracroute in vrf
sudo traceroute -i BLUE
```

Check vrf in vtysh(FRR)
```
show vrf
show bgp vrfs
show ip route vrf all

# FRR
Free range routing

default config file: `/etc/frr/frr.conf`

Zebra and staticd are enabled by default in Cumulus

