## Current Status

The four-leaf EVPN/VXLAN L2VNI overlay has been validated.

Completed scope:

- 2-spine / 4-leaf routed underlay
- eBGP IPv4 unicast underlay
- VTEP loopback reachability
- EVPN BGP address-family
- L2VNI `10010`
- explicit RT `65000:10010`
- EVPN Type-2 MAC route exchange
- EVPN Type-3 IMET route exchange
- four Linux hosts in the same overlay subnet
- host-to-host reachability across VXLAN

Validated hosts:

| Host | Leaf | IP |
|---|---|---|
| `host1` | `leaf1` | `192.168.10.11/24` |
| `host2` | `leaf2` | `192.168.10.12/24` |
| `host3` | `leaf3` | `192.168.10.13/24` |
| `host4` | `leaf4` | `192.168.10.14/24` |

Evidence:

- `outputs/four-leaf-evpn-bgp-summary.md`
- `outputs/four-leaf-evpn-vni.md`
- `outputs/four-leaf-evpn-routes.md`
- `outputs/four-leaf-host-overlay-reachability.md`
- `outputs/four-leaf-bridge-fdb.md`