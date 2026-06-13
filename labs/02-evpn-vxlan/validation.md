# Validation Guide — EVPN/VXLAN Lab

## Purpose

This file is the validation runbook and evidence index for Lab 02.

For the lab overview, topology summary, deployment steps, and learning relevance, see:

```text
README.md
```

This document focuses only on:

- what to validate
- which commands to run
- what the expected result means
- which output files should be saved as evidence
- how to interpret key EVPN/VXLAN validation results

---

## Validation Scope

Lab 02 validation covers the following stages:

| Stage | Validation focus | Evidence |
|---|---|---|
| 1 | Container state | `outputs/container-status.md` |
| 2 | eBGP IPv4 underlay | `outputs/underlay-bgp-summary.md` |
| 3 | VTEP loopback reachability | `outputs/vtep-reachability.md` |
| 4 | Static VXLAN data-plane check | `outputs/static-vxlan-data-plane.md` |
| 5 | EVPN L2VNI control plane | `outputs/four-leaf-evpn-bgp-summary.md`, `outputs/four-leaf-evpn-vni.md`, `outputs/four-leaf-evpn-routes.md` |
| 6 | Explicit L2VNI route-targets | `outputs/evpn-rt-cleanup.md` |
| 7 | Anycast gateway | `outputs/anycast-gateway-validation.md`, `outputs/anycast-gateway-neighbors.md` |
| 8 | Same-subnet L2VNI reachability | `outputs/two-l2vni-validation.md` |
| 9 | L3VNI / VRF POC | `outputs/l3vni-vrf-poc.md` |
| 10 | Explicit L3VNI route-target | `outputs/l3vni-rt-cleanup.md` |
| 11 | Final four-leaf inter-subnet routing | `outputs/four-leaf-l3vni-validation.md` |

---

## Before Running Validation

This file assumes the lab has already been deployed from the Lab 02 directory.

Create the output directory if needed:

```bash
mkdir -p outputs
```

Useful node list:

```bash
FABRIC_NODES="spine1 spine2 leaf1 leaf2 leaf3 leaf4"
LEAF_NODES="leaf1 leaf2 leaf3 leaf4"
HOST_NODES="host1 host2 host3 host4"
```

---

## 1. Container Status

Validate that all Lab 02 containers are running:

```bash
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' \
  | grep 'clab-evpn-vxlan' \
  | tee outputs/container-status.md
```

Expected result:

- `spine1` and `spine2` are running
- `leaf1` to `leaf4` are running
- `host1` to `host4` are running

Evidence:

```text
outputs/container-status.md
```

---

## 2. Underlay BGP Validation

Validate IPv4 unicast eBGP sessions:

```bash
{
  echo "# Underlay BGP Summary"
  echo

  for node in spine1 spine2 leaf1 leaf2 leaf3 leaf4; do
    echo "## $node"
    docker exec clab-evpn-vxlan-$node vtysh -c "show bgp ipv4 unicast summary"
    echo
  done
} | tee outputs/underlay-bgp-summary.md
```

Expected result:

- each spine has established BGP sessions to all leaves
- each leaf has established BGP sessions to both spines
- leaf loopback routes are reachable through the routed underlay

Evidence:

```text
outputs/underlay-bgp-summary.md
```

---

## 3. VTEP Loopback Reachability

Validate remote VTEP loopback reachability from `leaf1`:

```bash
{
  echo "# VTEP Reachability"
  echo

  for remote in 10.255.1.2 10.255.1.3 10.255.1.4; do
    echo "## leaf1 to $remote"
    docker exec clab-evpn-vxlan-leaf1 ping -c 3 -I 10.255.1.1 $remote
    echo
  done
} | tee outputs/vtep-reachability.md
```

Expected result:

- remote VTEP loopbacks are reachable
- packets use the underlay routing table
- packets are sourced from the local VTEP loopback IP

Important note:

Use the loopback IP as the source:

```bash
ping -I 10.255.1.1 10.255.1.2
```

Do not bind the test to the loopback interface name:

```bash
ping -I lo 10.255.1.2
```

Using `-I 10.255.1.1` sets the source IP and still allows Linux routing to choose the correct underlay interface. Using `-I lo` binds traffic to the loopback interface and does not validate routed underlay forwarding.

Evidence:

```text
outputs/vtep-reachability.md
```

---

## 4. Static VXLAN Data-Plane Evidence

This was an earlier validation step before relying on EVPN as the control plane.

It confirmed:

- Linux bridge forwarding
- VXLAN interface behavior
- VTEP source loopback behavior
- underlay reachability between VTEPs
- host forwarding across a VXLAN tunnel

Evidence:

```text
outputs/static-vxlan-data-plane.md
```

This step does not need to be rerun after the EVPN control plane is working unless the VXLAN dataplane is being debugged again.

---

## 5. EVPN Control Plane Validation

Validate EVPN BGP sessions:

```bash
{
  echo "# EVPN BGP Summary"
  echo

  for node in spine1 spine2 leaf1 leaf2 leaf3 leaf4; do
    echo "## $node"
    docker exec clab-evpn-vxlan-$node vtysh -c "show bgp l2vpn evpn summary"
    echo
  done
} | tee outputs/four-leaf-evpn-bgp-summary.md
```

Validate VNI discovery on leaves:

```bash
{
  echo "# EVPN VNI Summary"
  echo

  for leaf in leaf1 leaf2 leaf3 leaf4; do
    echo "## $leaf"
    docker exec clab-evpn-vxlan-$leaf vtysh -c "show evpn vni"
    echo
  done
} | tee outputs/four-leaf-evpn-vni.md
```

Save EVPN routes:

```bash
{
  echo "# EVPN Routes"
  echo

  for leaf in leaf1 leaf2 leaf3 leaf4; do
    echo "## $leaf"
    docker exec clab-evpn-vxlan-$leaf vtysh -c "show bgp l2vpn evpn"
    echo
  done
} | tee outputs/four-leaf-evpn-routes.md
```

Expected result:

- EVPN address-family sessions are established
- L2VNIs are discovered on the correct leaves
- Type-2 MAC/IP routes are visible
- Type-3 IMET routes are visible
- Type-5 IP prefix routes are visible after L3VNI / VRF is configured
- remote VTEPs are visible for the relevant VNIs

Evidence:

```text
outputs/four-leaf-evpn-bgp-summary.md
outputs/four-leaf-evpn-vni.md
outputs/four-leaf-evpn-routes.md
```

---

## 6. L2VNI Route-Target Validation

Validate that the L2VNI routes carry the expected route-targets:

| Service | Expected RT |
|---|---|
| VLAN 10 / L2VNI 10010 | `65000:10010` |
| VLAN 20 / L2VNI 10020 | `65000:10020` |

Command:

```bash
{
  echo "# L2VNI Route Target Validation"
  echo

  for leaf in leaf1 leaf2 leaf3 leaf4; do
    echo "## $leaf"
    docker exec clab-evpn-vxlan-$leaf vtysh -c "show bgp l2vpn evpn"
    echo
  done
} | tee outputs/evpn-rt-cleanup.md
```

Expected result:

- VNI `10010` routes carry `RT:65000:10010`
- VNI `10020` routes carry `RT:65000:10020`
- route import/export behavior matches L2VNI service membership

Evidence:

```text
outputs/evpn-rt-cleanup.md
```

---

## 7. Anycast Gateway Validation

Validate host routing tables:

```bash
{
  echo "# Host Route Tables"
  echo

  for host in host1 host2 host3 host4; do
    echo "## $host"
    docker exec clab-evpn-vxlan-$host ip route
    echo
  done
} | tee outputs/anycast-gateway-validation.md
```

Validate gateway reachability:

```bash
{
  echo "# Anycast Gateway Reachability"
  echo

  echo "## host1 to VLAN 10 gateway"
  docker exec clab-evpn-vxlan-host1 ping -c 3 192.168.10.1
  echo

  echo "## host2 to VLAN 10 gateway"
  docker exec clab-evpn-vxlan-host2 ping -c 3 192.168.10.1
  echo

  echo "## host3 to VLAN 20 gateway"
  docker exec clab-evpn-vxlan-host3 ping -c 3 192.168.20.1
  echo

  echo "## host4 to VLAN 20 gateway"
  docker exec clab-evpn-vxlan-host4 ping -c 3 192.168.20.1
} | tee -a outputs/anycast-gateway-validation.md
```

Optional neighbor check:

```bash
{
  echo "# Host Neighbor Tables"
  echo

  for host in host1 host2 host3 host4; do
    echo "## $host"
    docker exec clab-evpn-vxlan-$host ip neigh
    echo
  done
} | tee outputs/anycast-gateway-neighbors.md
```

Expected result:

- each host has a default route via the local anycast gateway
- each host can reach its gateway IP
- anycast gateway MAC learning is visible in neighbor / bridge state where applicable
- same-subnet overlay reachability still works

Evidence:

```text
outputs/anycast-gateway-validation.md
outputs/anycast-gateway-neighbors.md
```

---

## 8. Same-Subnet L2VNI Reachability

Validate same-subnet connectivity within each L2VNI:

```bash
{
  echo "# Same-subnet L2VNI Reachability"
  echo

  echo "## host1 to host2 / VLAN 10"
  docker exec clab-evpn-vxlan-host1 ping -c 3 192.168.10.12
  echo

  echo "## host3 to host4 / VLAN 20"
  docker exec clab-evpn-vxlan-host3 ping -c 3 192.168.20.14
} | tee outputs/two-l2vni-validation.md
```

Expected result:

- `host1` can reach `host2` within VLAN 10 / L2VNI 10010
- `host3` can reach `host4` within VLAN 20 / L2VNI 10020

Evidence:

```text
outputs/two-l2vni-validation.md
```

### Historical negative test before L3VNI

Before L3VNI / VRF was configured, cross-subnet traffic was expected to fail.

This historical result proves that L2VNI alone only provides same-subnet extension.

Do not rerun this as a failure test after the final L3VNI design is enabled. In the final design, cross-subnet traffic should succeed.

Evidence:

```text
outputs/two-l2vni-validation.md
```

---

## 9. L3VNI / VRF Validation

Validate VRF-to-L3VNI mapping:

```bash
{
  echo "# VRF VNI Mapping"
  echo

  for leaf in leaf1 leaf2 leaf3 leaf4; do
    echo "## $leaf"
    docker exec clab-evpn-vxlan-$leaf vtysh -c "show vrf vni"
    echo
  done
} | tee outputs/four-leaf-l3vni-validation.md
```

Validate tenant VRF routes:

```bash
{
  echo
  echo "# Tenant VRF Routes"
  echo

  for leaf in leaf1 leaf2 leaf3 leaf4; do
    echo "## $leaf"
    docker exec clab-evpn-vxlan-$leaf ip route show vrf tenant-a
    echo
  done
} | tee -a outputs/four-leaf-l3vni-validation.md
```

Validate EVPN routes, including Type-5 prefixes:

```bash
{
  echo
  echo "# EVPN Routes"
  echo

  for leaf in leaf1 leaf2 leaf3 leaf4; do
    echo "## $leaf"
    docker exec clab-evpn-vxlan-$leaf vtysh -c "show bgp l2vpn evpn"
    echo
  done
} | tee -a outputs/four-leaf-l3vni-validation.md
```

Expected result:

- all four leaves map `tenant-a` to L3VNI `10099`
- remote tenant prefixes are installed in the `tenant-a` VRF
- EVPN Type-5 routes are visible
- Type-5 routes for tenant prefixes carry the L3VNI route-target `65000:10099`

Evidence:

```text
outputs/four-leaf-l3vni-validation.md
```

---

## 10. L3VNI Route-Target Validation

Validate the L3VNI route-target:

| Service | Expected RT |
|---|---|
| VRF `tenant-a` / L3VNI 10099 | `65000:10099` |

Command:

```bash
{
  echo "# L3VNI Route Target Validation"
  echo

  for leaf in leaf1 leaf2 leaf3 leaf4; do
    echo "## $leaf"
    docker exec clab-evpn-vxlan-$leaf vtysh -c "show bgp l2vpn evpn"
    echo
  done
} | tee outputs/l3vni-rt-cleanup.md
```

Expected result:

- EVPN Type-5 routes for tenant prefixes carry `RT:65000:10099`
- the `tenant-a` VRF still learns remote prefixes
- inter-subnet reachability still works

Evidence:

```text
outputs/l3vni-rt-cleanup.md
```

---

## 11. Final Inter-Subnet Reachability

Validate final four-leaf inter-subnet reachability:

```bash
{
  echo
  echo "# Cross-subnet Host Reachability"
  echo

  echo "## host1 to host3"
  docker exec clab-evpn-vxlan-host1 ping -c 3 192.168.20.13
  echo

  echo "## host1 to host4"
  docker exec clab-evpn-vxlan-host1 ping -c 3 192.168.20.14
  echo

  echo "## host2 to host3"
  docker exec clab-evpn-vxlan-host2 ping -c 3 192.168.20.13
  echo

  echo "## host2 to host4"
  docker exec clab-evpn-vxlan-host2 ping -c 3 192.168.20.14
  echo

  echo "## host3 to host1"
  docker exec clab-evpn-vxlan-host3 ping -c 3 192.168.10.11
  echo

  echo "## host3 to host2"
  docker exec clab-evpn-vxlan-host3 ping -c 3 192.168.10.12
  echo

  echo "## host4 to host1"
  docker exec clab-evpn-vxlan-host4 ping -c 3 192.168.10.11
  echo

  echo "## host4 to host2"
  docker exec clab-evpn-vxlan-host4 ping -c 3 192.168.10.12
} | tee -a outputs/four-leaf-l3vni-validation.md
```

Expected result:

- hosts in VLAN 10 can reach hosts in VLAN 20
- hosts in VLAN 20 can reach hosts in VLAN 10
- successful reachability confirms L3VNI / VRF inter-subnet routing across the EVPN/VXLAN fabric

Evidence:

```text
outputs/four-leaf-l3vni-validation.md
```

---

## 12. Optional Bridge / FDB Checks

Use these commands when troubleshooting VXLAN forwarding or MAC learning:

```bash
{
  echo "# Bridge FDB"
  echo

  for leaf in leaf1 leaf2 leaf3 leaf4; do
    echo "## $leaf"
    docker exec clab-evpn-vxlan-$leaf bridge fdb show
    echo
  done
} | tee outputs/four-leaf-bridge-fdb.md
```

Evidence:

```text
outputs/four-leaf-bridge-fdb.md
```

---

## Key Interpretation Notes

### RD and RT

```text
RD = makes EVPN routes unique in the BGP table
RT = controls EVPN service import/export membership
```

Useful rule:

```text
RD can be different per VTEP.
RT should be consistent for the same EVPN service.
```

### EVPN route types used in this lab

```text
Type-2 = MAC/IP reachability
Type-3 = IMET / remote VTEP participation in a VNI
Type-5 = IP prefix reachability for routed tenant traffic
```

Same-subnet L2VNI forwarding mainly depends on Type-2 and Type-3 routes.

Inter-subnet routing with L3VNI depends on Type-5 prefix routes and remote router MAC information.

### L2VNI, L3VNI, and VRF

```text
L2VNI = bridge domain / subnet extension
L3VNI = routed tenant backbone
VRF = tenant routing table
```

In this lab:

```text
VNI 10010 = L2VNI for VLAN 10 / 192.168.10.0/24
VNI 10020 = L2VNI for VLAN 20 / 192.168.20.0/24
VNI 10099 = L3VNI for tenant-a routing
```

### br10099 and vxlan10099

```text
br10    = VLAN 10 host gateway
br20    = VLAN 20 host gateway
br10099 = L3VNI routing anchor
vxlan10099 = VXLAN tunnel interface for L3VNI 10099
```

Useful rule:

```text
br10/br20 face hosts.
br10099/vxlan10099 face the routed VXLAN overlay.
```

`br10099` should not be treated as a normal host-facing gateway interface.

### Rmac in EVPN Type-5 routes

Type-5 routes include a remote router MAC.

Example:

```text
Next Hop: 10.255.1.3
Rmac: 00:00:00:99:00:03
```

Interpretation:

```text
Next Hop = remote VTEP IP
Rmac     = remote router MAC for L3VNI forwarding
```

### Multiple EVPN paths through two spines

Seeing the same remote EVPN route through both spines is expected.

Useful rule:

```text
BGP EVPN chooses the control-plane best path.
VXLAN outer IP traffic follows the underlay routing table.
```

### EVPN convergence note

After a fresh deploy, inter-subnet ping may fail briefly even when the configuration is correct.

Wait until these are stable before treating a ping failure as a real fault:

```bash
show bgp l2vpn evpn summary
show evpn vni
show vrf vni
ip route show vrf tenant-a
```

A temporary `Destination Host Unreachable` can happen while EVPN routes, Linux VRF routes, bridge FDB entries, and ARP / neighbor state are still converging.

---

## Output Checklist

Expected output files for the completed Lab 02 validation stage:

```text
outputs/container-status.md
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
outputs/l3vni-rt-cleanup.md
outputs/four-leaf-l3vni-validation.md
```

---

## Completion Criteria

Lab 02 validation is complete when:

- all containers are running
- underlay eBGP sessions are established
- VTEP loopbacks are reachable through the underlay
- EVPN BGP sessions are established
- L2VNI `10010` and `10020` are discovered
- Type-2 MAC/IP routes are visible
- Type-3 IMET routes are visible
- explicit L2VNI route-targets are correct
- anycast gateways are reachable from hosts
- same-subnet L2VNI reachability works
- the historical pre-L3VNI cross-subnet failure is documented
- `tenant-a` maps to L3VNI `10099`
- EVPN Type-5 tenant prefix routes are visible
- explicit L3VNI route-target `65000:10099` is visible
- VLAN 10 hosts can reach VLAN 20 hosts
- VLAN 20 hosts can reach VLAN 10 hosts
- final evidence is saved in `outputs/four-leaf-l3vni-validation.md`
