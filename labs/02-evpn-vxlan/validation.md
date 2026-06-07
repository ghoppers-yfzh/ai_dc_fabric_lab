# Validation Guide — EVPN/VXLAN Lab

## 1. Purpose

This file documents the validation workflow for the EVPN/VXLAN lab.

The lab validates a routed eBGP underlay, EVPN/VXLAN L2VNI overlay services, explicit route-target design, distributed anycast gateways, and prepares for future L3VNI / VRF inter-subnet routing.

---

## 2. Current Completed Scope

Completed scope:

- minimal EVPN/VXLAN lab topology
- routed eBGP IPv4 unicast underlay
- VTEP loopback reachability
- static VXLAN data plane validation
- EVPN BGP address-family
- four-leaf EVPN/VXLAN L2VNI fabric
- L2VNI `10010` for VLAN 10
- L2VNI `10020` for VLAN 20
- explicit route-target design
- EVPN Type-2 MAC routes
- EVPN Type-3 IMET routes
- distributed anycast gateway validation
- same-subnet host-to-host reachability within each L2VNI
- expected cross-subnet failure before L3VNI / VRF
- minimal L3VNI / VRF POC between `leaf1` and `leaf3`
- EVPN Type-5 route visibility
- inter-subnet reachability between `host1` and `host3`

Not included yet:

- full four-leaf L3VNI expansion
- explicit L3VNI route-target cleanup
- symmetric IRB validation across all leaves
- multi-tenant routing
- external routing

---

## 3. Deploy the Lab

From the Lab 02 directory:

```bash
cd ~/ai_dc_fabric_lab/labs/02-evpn-vxlan
sudo containerlab deploy -t topology.clab.yml
```

Check containers:

```bash
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
```

Expected result:

- `spine1` is running
- `spine2` is running
- `leaf1` is running
- `leaf2` is running
- `leaf3` is running
- `leaf4` is running
- `host1` is running
- `host2` is running
- `host3` is running
- `host4` is running

---

## 4. Underlay BGP Validation

Check IPv4 unicast BGP sessions:

```bash
for node in spine1 spine2 leaf1 leaf2 leaf3 leaf4; do
  echo
  echo "===== $node IPv4 BGP ====="
  docker exec clab-evpn-vxlan-$node vtysh -c "show bgp ipv4 unicast summary"
done
```

Expected result:

- each spine has established BGP sessions to all leaves
- each leaf has established BGP sessions to both spines
- loopback routes are advertised through the underlay

Save output:

```bash
{
  echo "# Underlay BGP Summary"
  echo
  for node in spine1 spine2 leaf1 leaf2 leaf3 leaf4; do
    echo "## $node"
    docker exec clab-evpn-vxlan-$node vtysh -c "show bgp ipv4 unicast summary"
    echo
  done
} > outputs/underlay-bgp-summary.md
```

---

## 5. VTEP Loopback Reachability

The leaf loopbacks are used as VTEP source addresses.

Validate VTEP loopback reachability:

```bash
docker exec clab-evpn-vxlan-leaf1 ping -c 3 -I 10.255.1.1 10.255.1.2
docker exec clab-evpn-vxlan-leaf1 ping -c 3 -I 10.255.1.1 10.255.1.3
docker exec clab-evpn-vxlan-leaf1 ping -c 3 -I 10.255.1.1 10.255.1.4
```

Expected result:

- remote VTEP loopbacks are reachable
- packets are routed through the underlay
- packets are not bound to the local loopback interface

Important note:

Use the loopback IP as the source address:

```bash
ping -I 10.255.1.1 10.255.1.2
```

Do not use the loopback interface name:

```bash
ping -I lo 10.255.1.2
```

Using `-I 10.255.1.1` sets the source IP and allows the routing table to choose the outgoing underlay interface.

Using `-I lo` binds the packet to the loopback interface and does not test the routed underlay path.

---

## 6. Static VXLAN Data Plane Validation

Before relying on EVPN as the control plane, the VXLAN data plane can be validated with static FDB entries.

This confirms:

- Linux bridge behavior
- VXLAN interface behavior
- VTEP source loopback behavior
- underlay reachability between VTEPs
- host forwarding across VXLAN

Evidence:

```text
outputs/static-vxlan-data-plane.md
```

---

## 7. EVPN L2VNI Overlay Validation

This validation confirms that EVPN/VXLAN works for L2VNI services.

Core commands:

```bash
for node in spine1 spine2 leaf1 leaf2 leaf3 leaf4; do
  echo
  echo "===== $node EVPN BGP ====="
  docker exec clab-evpn-vxlan-$node vtysh -c "show bgp l2vpn evpn summary"
done
```

```bash
for leaf in leaf1 leaf2 leaf3 leaf4; do
  echo
  echo "===== $leaf EVPN VNI ====="
  docker exec clab-evpn-vxlan-$leaf vtysh -c "show evpn vni"
done
```

```bash
for leaf in leaf1 leaf2 leaf3 leaf4; do
  echo
  echo "===== $leaf EVPN routes ====="
  docker exec clab-evpn-vxlan-$leaf vtysh -c "show bgp l2vpn evpn"
done
```

Expected result:

- EVPN BGP sessions are established
- L2VNI services are discovered
- remote VTEPs are visible
- Type-2 MAC routes are present
- Type-3 IMET routes are present
- expected RT values are present

Evidence:

```text
outputs/evpn-bgp-summary.md
outputs/evpn-routes.md
outputs/four-leaf-evpn-bgp-summary.md
outputs/four-leaf-evpn-vni.md
outputs/four-leaf-evpn-routes.md
```

---

## 8. Explicit Route Target Validation

The lab uses explicit route-targets for clarity.

Current route-target design:

| Service | RT |
|---|---|
| VLAN 10 / L2VNI 10010 | `65000:10010` |
| VLAN 20 / L2VNI 10020 | `65000:10020` |

Validation command:

```bash
for leaf in leaf1 leaf2 leaf3 leaf4; do
  echo
  echo "===== $leaf EVPN routes ====="
  docker exec clab-evpn-vxlan-$leaf vtysh -c "show bgp l2vpn evpn"
done
```

Expected result:

- VNI `10010` routes carry `RT:65000:10010`
- VNI `10020` routes carry `RT:65000:10020`
- route import/export behavior matches the L2VNI service membership

Evidence:

```text
outputs/evpn-rt-cleanup.md
```

---

## 9. Anycast Gateway Validation

This validation confirms that distributed anycast gateways can be added to the L2VNI services.

Current gateway design:

| Service | Gateway IP | Gateway MAC |
|---|---|---|
| VLAN 10 / L2VNI 10010 | `192.168.10.1/24` | `00:00:00:00:10:01` |
| VLAN 20 / L2VNI 10020 | `192.168.20.1/24` | `00:00:00:00:20:01` |

Validation commands:

```bash
for host in host1 host2 host3 host4; do
  echo
  echo "===== $host route table ====="
  docker exec clab-evpn-vxlan-$host ip route
done
```

```bash
docker exec clab-evpn-vxlan-host1 ping -c 3 192.168.10.1
docker exec clab-evpn-vxlan-host2 ping -c 3 192.168.10.1
docker exec clab-evpn-vxlan-host3 ping -c 3 192.168.20.1
docker exec clab-evpn-vxlan-host4 ping -c 3 192.168.20.1
```

Expected result:

- each host has a default route via its local anycast gateway
- each host can reach its gateway IP
- same-subnet overlay reachability still works

Evidence:

```text
outputs/anycast-gateway-validation.md
outputs/anycast-gateway-neighbors.md
```

---

## 10. Two-L2VNI Validation

This validation confirms that the EVPN/VXLAN fabric can support two independent L2VNI services.

Validated services:

| VLAN | L2VNI | Subnet | Hosts | RT |
|---|---:|---|---|---|
| 10 | 10010 | `192.168.10.0/24` | `host1`, `host2` | `65000:10010` |
| 20 | 10020 | `192.168.20.0/24` | `host3`, `host4` | `65000:10020` |

Validation commands:

```bash
docker exec clab-evpn-vxlan-host1 ping -c 3 192.168.10.12
docker exec clab-evpn-vxlan-host3 ping -c 3 192.168.20.14
```

Expected result:

- `host1` can reach `host2` within VLAN 10 / L2VNI 10010
- `host3` can reach `host4` within VLAN 20 / L2VNI 10020

Cross-subnet validation before L3VNI:

```bash
docker exec clab-evpn-vxlan-host1 ping -c 3 192.168.20.13
docker exec clab-evpn-vxlan-host3 ping -c 3 192.168.10.11
```

Expected result:

- cross-subnet ping should fail before L3VNI / VRF is configured

This is the correct result at this stage because L2VNI only provides same-subnet extension.

Evidence:

```text
outputs/two-l2vni-validation.md
outputs/l3vni-vrf-poc.md
```

---

## 11. Key Interpretation Notes

### RD and RT have different roles

RD and RT are not the same thing.

```text
RD = makes EVPN routes unique in the BGP table
RT = controls import/export membership for an EVPN service
```

A useful rule:

```text
RD can be different per VTEP.
RT should be consistent for the same EVPN service.
```

### EVPN Type-2 routes are MAC reachability routes

Type-2 routes advertise MAC reachability.

They tell a VTEP where a MAC address is located.

### EVPN Type-3 routes identify remote VTEPs

Type-3 routes are IMET routes.

They identify which remote VTEPs participate in a VNI and help build the BUM flood list.

A useful rule:

```text
Type-2 tells us where MAC addresses are.
Type-3 tells us which remote VTEPs participate in the VNI.
```

### Multiple remote paths are expected with two spines

Remote EVPN routes may appear through both spines.

This is expected because the same remote EVPN route can be received through multiple spine paths.

A useful rule:

```text
BGP EVPN chooses a best control-plane path.
VXLAN outer IP traffic still follows the underlay routing table.
```

---

## 12. Next Step: L3VNI / VRF / Inter-subnet Routing

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

---


## 13. L3VNI / VRF POC Validation

This validation confirms that a minimal L3VNI / VRF inter-subnet routing POC works between VLAN 10 and VLAN 20.

Validated POC scope:

| Item | Value |
|---|---|
| VRF | `tenant-a` |
| L3VNI | `10099` |
| Source subnet | `192.168.10.0/24` |
| Destination subnet | `192.168.20.0/24` |
| Source leaf | `leaf1` |
| Destination leaf | `leaf3` |

Expected result:

- `tenant-a` exists on `leaf1` and `leaf3`.
- `tenant-a` is mapped to L3VNI `10099`.
- `vxlan10099` and `br10099` are up.
- `leaf1` learns `192.168.20.0/24` through BGP EVPN.
- `leaf3` learns `192.168.10.0/24` through BGP EVPN.
- EVPN Type-5 routes are visible.
- `host1` can reach `host3` across subnets.
- `host3` can reach `host1` across subnets.

Validation commands:

```bash
for leaf in leaf1 leaf3; do
  echo
  echo "===== $leaf VRF routes ====="
  docker exec clab-evpn-vxlan-$leaf ip route show vrf tenant-a

  echo
  echo "===== $leaf interfaces in tenant-a ====="
  docker exec clab-evpn-vxlan-$leaf ip link show master tenant-a
done
```

```bash
docker exec clab-evpn-vxlan-leaf1 vtysh -c "show vrf"
docker exec clab-evpn-vxlan-leaf3 vtysh -c "show vrf"

docker exec clab-evpn-vxlan-leaf1 vtysh -c "show vrf vni"
docker exec clab-evpn-vxlan-leaf3 vtysh -c "show vrf vni"
```

```bash
docker exec clab-evpn-vxlan-leaf1 vtysh -c "show bgp l2vpn evpn"
docker exec clab-evpn-vxlan-leaf3 vtysh -c "show bgp l2vpn evpn"
```

```bash
docker exec clab-evpn-vxlan-host1 ping -c 3 192.168.20.13
docker exec clab-evpn-vxlan-host3 ping -c 3 192.168.10.11
```

Save output:

```bash
{
  echo "# L3VNI VRF Inter-subnet Routing POC"
  echo

  echo "## leaf1 VRF routes"
  docker exec clab-evpn-vxlan-leaf1 ip route show vrf tenant-a
  echo

  echo "## leaf3 VRF routes"
  docker exec clab-evpn-vxlan-leaf3 ip route show vrf tenant-a
  echo

  echo "## leaf1 show vrf vni"
  docker exec clab-evpn-vxlan-leaf1 vtysh -c "show vrf vni"
  echo

  echo "## leaf3 show vrf vni"
  docker exec clab-evpn-vxlan-leaf3 vtysh -c "show vrf vni"
  echo

  echo "## leaf1 EVPN routes"
  docker exec clab-evpn-vxlan-leaf1 vtysh -c "show bgp l2vpn evpn"
  echo

  echo "## leaf3 EVPN routes"
  docker exec clab-evpn-vxlan-leaf3 vtysh -c "show bgp l2vpn evpn"
  echo

  echo "## host1 to host3"
  docker exec clab-evpn-vxlan-host1 ping -c 3 192.168.20.13
  echo

  echo "## host3 to host1"
  docker exec clab-evpn-vxlan-host3 ping -c 3 192.168.10.11
} > outputs/l3vni-vrf-poc.md
```

Evidence:

```text
outputs/l3vni-vrf-poc.md
```

---

## 14. L3VNI / VRF Interpretation Notes

### EVPN Type-5 routes provide IP prefix reachability

In the earlier L2VNI stage, EVPN Type-2 and Type-3 routes were enough for same-subnet reachability.

For inter-subnet routing, the leaves need to know which remote VTEP owns which IP prefix.

This is provided by EVPN Type-5 routes.

Example:

```text
[5]:[0]:[24]:[192.168.20.0]
  Next Hop: 10.255.1.3
  Rmac: 00:00:00:99:00:03
```

Interpretation:

```text
192.168.20.0/24 is reachable behind remote VTEP 10.255.1.3.
The remote router MAC for L3VNI forwarding is 00:00:00:99:00:03.
```

Useful rule:

```text
Type-2 = MAC reachability
Type-3 = remote VTEP participation in a VNI
Type-5 = IP prefix reachability
```

---

### L3VNI builds the tenant routing layer

The lab now has two L2VNIs:

```text
VLAN 10 / L2VNI 10010 / 192.168.10.0/24
VLAN 20 / L2VNI 10020 / 192.168.20.0/24
```

These L2VNIs provide same-subnet extension only.

The L3VNI provides the routed tenant backbone between subnets.

In this lab:

```text
VRF: tenant-a
L3VNI: 10099
```

Interpretation:

```text
tenant-a is the tenant routing table.
VNI 10099 is the EVPN/VXLAN routed service used by tenant-a.
```

Useful rule:

```text
L2VNI = bridge domain / subnet extension
L3VNI = routed tenant backbone
VRF = tenant routing table
```

---

### Why a VRF is needed

A VRF creates an independent routing table for a tenant or routing domain.

In this lab, `tenant-a` contains:

```text
192.168.10.0/24
192.168.20.0/24
```

Because both subnets are in the same VRF, they can be routed together after L3VNI is configured.

The VRF also provides tenant separation. A future `tenant-b` could use overlapping IP addresses without mixing routes with `tenant-a`.

Useful rule:

```text
VRF = the tenant's Layer 3 routing world
```

---

### Why VNI 10099 is needed

VNI `10099` is the L3VNI for `tenant-a`.

It is different from the L2VNIs:

```text
VNI 10010 = L2VNI for VLAN 10 / 192.168.10.0/24
VNI 10020 = L2VNI for VLAN 20 / 192.168.20.0/24
VNI 10099 = L3VNI for tenant-a routing
```

The L3VNI carries routed traffic between subnets inside the same tenant VRF.

Useful rule:

```text
L2VNI carries bridged host traffic.
L3VNI carries routed tenant traffic.
```

---

### br10099 and vxlan10099 roles

`br10099` is the L3-SVI for the L3VNI.

It should not be used as a host gateway subnet interface.

In this lab:

```text
br10    = VLAN 10 anycast gateway, has 192.168.10.1/24
br20    = VLAN 20 anycast gateway, has 192.168.20.1/24
br10099 = L3VNI SVI, no host subnet IP
```

`vxlan10099` is the VXLAN tunnel interface for L3VNI `10099`.

The relationship is:

```text
tenant-a VRF
  ├── br10     -> local VLAN 10 gateway
  ├── br20     -> local VLAN 20 gateway
  └── br10099  -> L3VNI SVI
        └── vxlan10099 -> VXLAN encapsulation for routed tenant traffic
```

Useful rule:

```text
br10/br20 face the hosts.
br10099/vxlan10099 face the routed VXLAN overlay.
```

---

### Inter-subnet forwarding sequence

Example: `host1` pings `host3`.

```text
host1: 192.168.10.11
host3: 192.168.20.13
```

Forwarding sequence:

```text
1. host1 sees that 192.168.20.13 is outside 192.168.10.0/24.
2. host1 sends the packet to its default gateway 192.168.10.1.
3. leaf1 receives the packet on br10.
4. br10 belongs to VRF tenant-a, so leaf1 performs a tenant-a routing lookup.
5. leaf1 finds 192.168.20.0/24 via remote VTEP 10.255.1.3 using br10099.
6. leaf1 encapsulates the routed packet into VXLAN VNI 10099 using vxlan10099.
7. The underlay forwards the outer packet from 10.255.1.1 to 10.255.1.3.
8. leaf3 receives and decapsulates the VXLAN packet.
9. leaf3 uses the remote router MAC / L3VNI information to place the packet into tenant-a.
10. leaf3 forwards the packet out br20 toward host3.
```

Return traffic follows the reverse logic:

```text
host3 -> br20 on leaf3 -> tenant-a route lookup -> L3VNI 10099 -> leaf1 -> br10 -> host1
```

Useful rule:

```text
The host sends traffic to the local anycast gateway.
The local leaf routes inside the VRF.
The L3VNI carries the routed packet to the remote VTEP.
The remote leaf delivers it into the destination L2VNI.
```

---

### br10099 is not a user-facing gateway

`br10` and `br20` are user-facing gateway interfaces.

They have subnet gateway IP addresses:

```text
br10: 192.168.10.1/24
br20: 192.168.20.1/24
```

`br10099` should not have a host subnet gateway IP.

Its job is to act as the L3VNI SVI / anchor that allows FRR and the Linux dataplane to associate:

```text
VRF tenant-a
L3VNI 10099
vxlan10099
router MAC / Rmac
EVPN Type-5 routes
```

Useful rule:

```text
br10/br20 = local host gateway interfaces
br10099   = L3VNI routing anchor, not a host gateway
```

---

### Rmac is the remote router MAC used for routed VXLAN forwarding

EVPN Type-5 routes include an `Rmac` value.

Example:

```text
Rmac:00:00:00:99:00:03
```

Interpretation:

```text
The prefix is reachable behind remote VTEP 10.255.1.3.
When sending routed tenant traffic to that VTEP, use 00:00:00:99:00:03 as the remote router MAC.
```

Useful rule:

```text
Next Hop = remote VTEP IP
Rmac     = remote router MAC for L3VNI forwarding
```

This is why the MAC address on `br10099` matters. It becomes part of the EVPN routing information used by other VTEPs.

---

## 15. Output Checklist

Expected output files for the completed L2VNI stage:

```text
outputs/underlay-bgp-summary.md
outputs/vtep-reachability.md
outputs/static-vxlan-data-plane.md
outputs/evpn-bgp-summary.md
outputs/evpn-routes.md
outputs/host-overlay-reachability.md
outputs/evpn-rt-cleanup.md
outputs/four-leaf-evpn-bgp-summary.md
outputs/four-leaf-evpn-vni.md
outputs/four-leaf-evpn-routes.md
outputs/four-leaf-host-overlay-reachability.md
outputs/four-leaf-bridge-fdb.md
outputs/anycast-gateway-validation.md
outputs/anycast-gateway-neighbors.md
outputs/two-l2vni-validation.md
outputs/l3vni-vrf-poc.md
```

---

## 16. Cleanup

Destroy the lab:

```bash
sudo containerlab destroy -t topology.clab.yml
```

Destroy and remove runtime files if needed:

```bash
sudo containerlab destroy -t topology.clab.yml --cleanup
```

---

## 17. Completion Criteria

This L2VNI validation stage is complete when:

- all containers start successfully
- all underlay eBGP sessions are established
- VTEP loopback reachability works
- EVPN BGP sessions are established
- VNI `10010` and VNI `10020` are discovered as L2VNIs
- Type-2 MAC routes are visible
- Type-3 IMET routes are visible
- explicit RTs are correct
- distributed anycast gateways work
- same-subnet host reachability works within each L2VNI
- cross-subnet reachability is not expected until L3VNI / VRF is added
- minimal L3VNI / VRF POC validates `host1` to `host3` inter-subnet routing
- EVPN Type-5 routes are visible for tenant prefixes
- `show vrf vni` maps `tenant-a` to L3VNI `10099`
