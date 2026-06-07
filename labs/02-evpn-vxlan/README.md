# EVPN/VXLAN Lab

## 1. Goal

This lab builds an EVPN/VXLAN overlay on top of a routed eBGP leaf-spine underlay.

The goal is to understand how a routed data center fabric can support overlay network services using:

- eBGP underlay
- VTEP loopbacks
- VXLAN data plane
- BGP EVPN control plane
- L2VNI services
- explicit route-target design
- distributed anycast gateway
- future L3VNI / VRF-based inter-subnet routing

This lab builds on the routed underlay foundation from:

```text
labs/01-frr-leaf-spine/
```

---

## 2. Current Lab Status

Current status:

```text
Four-leaf EVPN/VXLAN L2VNI fabric completed.
Two independent L2VNI services completed.
Anycast gateway validation completed.
L3VNI / VRF inter-subnet routing is planned next.
```

Completed scope:

- 2-spine / 4-leaf routed underlay
- eBGP IPv4 unicast underlay
- VTEP loopback reachability
- EVPN BGP address-family
- L2VNI `10010` for VLAN 10
- L2VNI `10020` for VLAN 20
- explicit route-target design
- EVPN Type-2 MAC route exchange
- EVPN Type-3 IMET route exchange
- Linux bridge and VXLAN interfaces
- distributed anycast gateway for both L2VNI services
- validation outputs saved under `outputs/`

Not completed yet:

- VRF
- L3VNI
- inter-subnet routing
- symmetric IRB
- EVPN Type-5 route validation
- failure testing for the multi-VNI design

---

## 3. Current Topology

```text
                  spine1              spine2
                 /  |  \\            /  |  \\
                /   |   \\          /   |   \\
             leaf1 leaf2 leaf3    leaf1 leaf2 leaf3 leaf4
               |     |     |        |
             host1 host2 host3    host4
```

Logical topology:

```text
VLAN 10 / L2VNI 10010:
  host1 -- leaf1
  host2 -- leaf2

VLAN 20 / L2VNI 10020:
  host3 -- leaf3
  host4 -- leaf4
```

---

## 4. Underlay Design

The underlay provides IP reachability between VTEP loopbacks.

Underlay components:

- point-to-point routed links between spines and leaves
- `/31` addressing for spine-leaf links
- loopback addresses on all spines and leaves
- eBGP IPv4 unicast between spines and leaves
- ECMP-capable paths through both spines

The VTEP source addresses are the leaf loopbacks:

| Leaf | VTEP Loopback |
|---|---|
| `leaf1` | `10.255.1.1` |
| `leaf2` | `10.255.1.2` |
| `leaf3` | `10.255.1.3` |
| `leaf4` | `10.255.1.4` |

The underlay must be working before EVPN/VXLAN can work.

---

## 5. Overlay Services

### VLAN 10 / L2VNI 10010

| Item | Value |
|---|---|
| VLAN | `10` |
| L2VNI | `10010` |
| Subnet | `192.168.10.0/24` |
| Anycast gateway IP | `192.168.10.1/24` |
| Anycast gateway MAC | `00:00:00:00:10:01` |
| Route target | `65000:10010` |

Hosts:

| Host | Leaf | IP | Gateway |
|---|---|---|---|
| `host1` | `leaf1` | `192.168.10.11/24` | `192.168.10.1` |
| `host2` | `leaf2` | `192.168.10.12/24` | `192.168.10.1` |

### VLAN 20 / L2VNI 10020

| Item | Value |
|---|---|
| VLAN | `20` |
| L2VNI | `10020` |
| Subnet | `192.168.20.0/24` |
| Anycast gateway IP | `192.168.20.1/24` |
| Anycast gateway MAC | `00:00:00:00:20:01` |
| Route target | `65000:10020` |

Hosts:

| Host | Leaf | IP | Gateway |
|---|---|---|---|
| `host3` | `leaf3` | `192.168.20.13/24` | `192.168.20.1` |
| `host4` | `leaf4` | `192.168.20.14/24` | `192.168.20.1` |

---

## 6. What Has Been Validated

### Underlay validation

Validated:

- all spine-leaf IPv4 unicast BGP sessions
- loopback route advertisement
- VTEP loopback reachability

Evidence:

```text
outputs/underlay-bgp-summary.md
outputs/vtep-reachability.md
outputs/underlay-routes.md
```

### Static VXLAN data plane validation

Before relying on EVPN as the control plane, the VXLAN data plane was tested with static FDB entries.

This confirmed:

- Linux bridge behavior
- VXLAN interface behavior
- VTEP loopback reachability
- same-subnet host reachability over VXLAN

Evidence:

```text
outputs/static-vxlan-data-plane.md
```

### EVPN L2VNI validation

Validated:

- EVPN BGP address-family
- L2VNI discovery
- Type-2 MAC route exchange
- Type-3 IMET route exchange
- explicit route-target configuration
- same-subnet overlay reachability

Evidence:

```text
outputs/evpn-bgp-summary.md
outputs/evpn-routes.md
outputs/host-overlay-reachability.md
outputs/evpn-rt-cleanup.md
```

### Four-leaf L2VNI validation

Validated:

- EVPN/VXLAN across four leaves
- multiple VTEPs in the same L2VNI
- host-to-host overlay reachability across the fabric
- bridge and FDB state

Evidence:

```text
outputs/four-leaf-evpn-bgp-summary.md
outputs/four-leaf-evpn-vni.md
outputs/four-leaf-evpn-routes.md
outputs/four-leaf-host-overlay-reachability.md
outputs/four-leaf-bridge-fdb.md
```

### Anycast gateway validation

Validated:

- each host has a default gateway
- each leaf has a local anycast gateway IP/MAC
- hosts can reach their distributed gateway
- same-subnet overlay reachability still works after adding the gateway

Evidence:

```text
outputs/anycast-gateway-validation.md
outputs/anycast-gateway-neighbors.md
```

### Two-L2VNI validation

Validated:

- VLAN 10 / L2VNI 10010 works independently
- VLAN 20 / L2VNI 10020 works independently
- same-subnet reachability works within each L2VNI
- cross-subnet reachability is expected to fail before L3VNI / VRF is configured

Evidence:

```text
outputs/two-l2vni-validation.md
```

---

## 7. Important Interpretation Notes

### L2VNI vs L3VNI

L2VNI provides same-subnet extension across the routed fabric.

In this lab:

```text
VLAN 10 / L2VNI 10010 = 192.168.10.0/24
VLAN 20 / L2VNI 10020 = 192.168.20.0/24
```

Hosts in the same L2VNI should be able to communicate.

Hosts in different subnets should not communicate until L3VNI / VRF inter-subnet routing is added.

### RD vs RT

RD and RT have different purposes.

```text
RD = makes EVPN routes unique in the BGP table
RT = controls import/export membership for an EVPN service
```

A useful rule:

```text
RD can be different per VTEP.
RT should be consistent for the same EVPN service.
```

Current route-target design:

| Service | RT |
|---|---|
| L2VNI `10010` | `65000:10010` |
| L2VNI `10020` | `65000:10020` |

### Type-2 and Type-3 routes

EVPN Type-2 routes advertise MAC reachability.

EVPN Type-3 routes identify remote VTEPs participating in a VNI and support BUM traffic handling.

Useful rule:

```text
Type-2 tells us where MAC addresses are.
Type-3 tells us which remote VTEPs participate in the VNI.
```

---

## 8. Next Step: L3VNI / VRF / Inter-subnet Routing

The current lab has two independent L2VNI services.

At this stage:

```text
host1 <-> host2 should work within 192.168.10.0/24
host3 <-> host4 should work within 192.168.20.0/24
host1 <-> host3 should not work yet
```

The next step is to introduce:

- a tenant VRF
- an L3VNI
- inter-subnet routing between VLAN 10 and VLAN 20
- EVPN routing behavior for the tenant VRF

Planned L3VNI design:

| Item | Value |
|---|---|
| VRF | `tenant-a` |
| L3VNI | `10099` |
| L3VNI RT | `65000:10099` |

Expected future result:

- `host1` can reach `host3` across subnets
- `host1` can reach `host4` across subnets
- `host3` can reach `host1` across subnets
- traffic is routed through the local anycast gateway and carried across the fabric using the L3VNI

The first L3VNI implementation should be kept small and validated carefully before expanding the design further.

---

## 9. Recommended Next Implementation Sequence

Recommended sequence:

```text
1. Add VRF tenant-a on the leaves.
2. Attach VLAN 10 and VLAN 20 gateway interfaces to tenant-a.
3. Add L3VNI 10099.
4. Configure EVPN route-target import/export for L3VNI.
5. Validate local routing table behavior.
6. Validate EVPN route advertisement.
7. Validate inter-subnet host reachability.
8. Save outputs under outputs/.
9. Document route interpretation.
```

Avoid adding more complexity until basic inter-subnet routing works.

Do not add yet:

- multiple VRFs
- route leaking
- external connectivity
- firewalling
- automation
- failure testing

Those should come after the basic L3VNI behavior is understood.
