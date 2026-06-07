## Current Status

The initial EVPN/VXLAN L2VNI lab has been validated.

Completed scope:

- 2-spine / 2-leaf routed underlay
- eBGP IPv4 unicast underlay
- VTEP loopback reachability
- Linux bridge and VXLAN interface
- EVPN BGP address-family
- L2VNI `10010`
- EVPN Type-2 MAC routes
- EVPN Type-3 IMET routes
- same-subnet host-to-host reachability across VXLAN

Validated overlay:

| Item | Value |
|---|---|
| VLAN | `10` |
| L2VNI | `10010` |
| host1 | `192.168.10.11/24` |
| host2 | `192.168.10.12/24` |
| leaf1 VTEP | `10.255.1.1` |
| leaf2 VTEP | `10.255.1.2` |

The lab confirms that `host1` and `host2` can communicate in the same subnet across a routed underlay using EVPN/VXLAN.