# Validation Guide — EVPN/VXLAN Lab

## 1. Purpose

This file documents the validation workflow for the EVPN/VXLAN lab.

The first validation step is to confirm that the routed underlay works and that VTEP loopbacks are reachable across the fabric.

The second validation step is to confirm that a minimal EVPN/VXLAN L2VNI service works between `host1` and `host2`.

---

## 2. Current Validation Scope

Current completed scope:

- deploy the minimal EVPN/VXLAN lab topology
- validate all FRR containers are running
- validate eBGP IPv4 unicast underlay sessions
- validate loopback route advertisement
- validate VTEP loopback reachability between `leaf1` and `leaf2`
- validate EVPN BGP address-family
- validate L2VNI `10010`
- validate EVPN Type-2 MAC routes
- validate EVPN Type-3 IMET routes
- validate explicit route-target `65000:10010`
- validate same-subnet host-to-host reachability across VXLAN

Not included yet:

- L3VNI
- VRF
- anycast gateway
- inter-subnet routing
- multi-leaf expansion
- EVPN/VXLAN failure testing

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
- `host1` is running
- `host2` is running

---

## 4. Interface and IP Address Checks

Check IP addresses on the FRR nodes:

```bash
for node in spine1 spine2 leaf1 leaf2; do
  echo
  echo "===== $node ====="
  docker exec clab-evpn-vxlan-$node ip -br addr
done
```

Expected result:

- `spine1` has loopback `10.255.0.1/32`
- `spine2` has loopback `10.255.0.2/32`
- `leaf1` has loopback `10.255.1.1/32`
- `leaf2` has loopback `10.255.1.2/32`
- spine-leaf point-to-point addresses match `ip-asn-plan.md`

Check host addresses:

```bash
for host in host1 host2; do
  echo
  echo "===== $host ====="
  docker exec clab-evpn-vxlan-$host ip -br addr
done
```

Expected result:

- `host1` has `192.168.10.11/24`
- `host2` has `192.168.10.12/24`

---

## 5. Underlay BGP Validation

Check IPv4 unicast BGP sessions:

```bash
for node in spine1 spine2 leaf1 leaf2; do
  echo
  echo "===== $node ====="
  docker exec clab-evpn-vxlan-$node vtysh -c "show bgp ipv4 unicast summary"
done
```

Expected result:

- `spine1` has 2 established BGP neighbors
- `spine2` has 2 established BGP neighbors
- `leaf1` has 2 established BGP neighbors
- `leaf2` has 2 established BGP neighbors

Expected sessions:

```text
spine1 <-> leaf1
spine1 <-> leaf2
spine2 <-> leaf1
spine2 <-> leaf2
```

Save output:

```bash
{
  echo "# Lab 02 Underlay BGP Summary"
  echo
  for node in spine1 spine2 leaf1 leaf2; do
    echo "## $node"
    docker exec clab-evpn-vxlan-$node vtysh -c "show bgp ipv4 unicast summary"
    echo
  done
} > outputs/underlay-bgp-summary.md
```

---

## 6. Underlay Route Validation

Check BGP routes on both leaves:

```bash
docker exec clab-evpn-vxlan-leaf1 vtysh -c "show bgp ipv4 unicast"
docker exec clab-evpn-vxlan-leaf2 vtysh -c "show bgp ipv4 unicast"
```

Expected result:

- `leaf1` learns `10.255.1.2/32`
- `leaf2` learns `10.255.1.1/32`
- spine loopbacks are also visible through BGP where advertised
- remote loopbacks are installed in the routing table

Check installed BGP routes:

```bash
docker exec clab-evpn-vxlan-leaf1 vtysh -c "show ip route bgp"
docker exec clab-evpn-vxlan-leaf2 vtysh -c "show ip route bgp"
```

Save output:

```bash
{
  echo "# Lab 02 Underlay Routes"
  echo
  echo "## leaf1 BGP table"
  docker exec clab-evpn-vxlan-leaf1 vtysh -c "show bgp ipv4 unicast"
  echo
  echo "## leaf1 installed BGP routes"
  docker exec clab-evpn-vxlan-leaf1 vtysh -c "show ip route bgp"
  echo
  echo "## leaf2 BGP table"
  docker exec clab-evpn-vxlan-leaf2 vtysh -c "show bgp ipv4 unicast"
  echo
  echo "## leaf2 installed BGP routes"
  docker exec clab-evpn-vxlan-leaf2 vtysh -c "show ip route bgp"
} > outputs/underlay-routes.md
```

---

## 7. VTEP Loopback Reachability

The leaf loopbacks are used as VTEP source addresses in the EVPN/VXLAN lab.

Validate VTEP loopback reachability:

```bash
docker exec clab-evpn-vxlan-leaf1 ping -c 3 -I 10.255.1.1 10.255.1.2
docker exec clab-evpn-vxlan-leaf2 ping -c 3 -I 10.255.1.2 10.255.1.1
```

Expected result:

- `leaf1` can reach `leaf2` loopback using `10.255.1.1` as the source IP
- `leaf2` can reach `leaf1` loopback using `10.255.1.2` as the source IP
- packets are routed through the underlay, not through the local loopback interface

Save output:

```bash
{
  echo "# VTEP Reachability"
  echo
  echo "## leaf1 to leaf2 VTEP"
  docker exec clab-evpn-vxlan-leaf1 ping -c 3 -I 10.255.1.1 10.255.1.2
  echo
  echo "## leaf2 to leaf1 VTEP"
  docker exec clab-evpn-vxlan-leaf2 ping -c 3 -I 10.255.1.2 10.255.1.1
} > outputs/vtep-reachability.md
```

---

## 8. Important Note: Source IP vs Source Interface

When validating VTEP loopback reachability, use the loopback IP as the source address:

```bash
ping -I 10.255.1.1 10.255.1.2
```

Do not use the loopback interface name as the source interface:

```bash
ping -I lo 10.255.1.2
```

These two commands are different.

Using `-I 10.255.1.1` means:

```text
Use 10.255.1.1 as the source IP address, but let the kernel routing table choose the outgoing underlay interface.
```

Using `-I lo` means:

```text
Bind the packet to the local loopback interface.
```

For VTEP validation, the correct test is to source the packet from the VTEP loopback IP while allowing normal underlay routing to choose the outgoing path.

This reflects how VXLAN works: the VTEP source is a loopback IP, but the encapsulated traffic is still forwarded through physical underlay interfaces.

Useful route lookup commands:

```bash
docker exec clab-evpn-vxlan-leaf1 ip route get 10.255.1.2
docker exec clab-evpn-vxlan-leaf1 ip route get 10.255.1.2 from 10.255.1.1
```

Expected result:

- the route lookup should select an underlay interface such as `eth1` or `eth2`
- the outgoing interface should not be `lo`

---

## 9. Static VXLAN Data Plane Validation

Before relying on EVPN as the control plane, the VXLAN data plane can be validated with a static flood FDB entry.

This confirms that the following components work before EVPN route learning is introduced:

- Linux bridge
- VXLAN interface
- VTEP source loopback
- underlay reachability between VTEPs
- host-to-host forwarding across VXLAN

Example static FDB entries:

```bash
docker exec clab-evpn-vxlan-leaf1 bridge fdb append 00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.2
docker exec clab-evpn-vxlan-leaf2 bridge fdb append 00:00:00:00:00:00 dev vxlan10010 dst 10.255.1.1
```

Expected result:

```bash
docker exec clab-evpn-vxlan-host1 ping -c 3 192.168.10.12
docker exec clab-evpn-vxlan-host2 ping -c 3 192.168.10.11
```

Save output:

```bash
{
  echo "# Static VXLAN Data Plane Test"
  echo
  echo "## leaf1 bridge links"
  docker exec clab-evpn-vxlan-leaf1 bridge link
  echo
  echo "## leaf1 FDB"
  docker exec clab-evpn-vxlan-leaf1 bridge fdb show
  echo
  echo "## leaf2 bridge links"
  docker exec clab-evpn-vxlan-leaf2 bridge link
  echo
  echo "## leaf2 FDB"
  docker exec clab-evpn-vxlan-leaf2 bridge fdb show
  echo
  echo "## host1 to host2"
  docker exec clab-evpn-vxlan-host1 ping -c 3 192.168.10.12
} > outputs/static-vxlan-data-plane.md
```

---

## 10. EVPN L2VNI Overlay Validation

This validation confirms that EVPN/VXLAN is working for a basic L2VNI service.

Validated scope:

- EVPN BGP sessions are established.
- VNI `10010` is discovered as an L2 VNI on both leaves.
- Each leaf learns one remote VTEP.
- EVPN Type-2 MAC routes are visible.
- EVPN Type-3 IMET routes are visible.
- `host1` can reach `host2` in the same subnet across VXLAN.
- `host2` can reach `host1` in the same subnet across VXLAN.

Validation commands:

```bash
for node in spine1 spine2 leaf1 leaf2; do
  echo
  echo "===== $node ====="
  docker exec clab-evpn-vxlan-$node vtysh -c "show bgp l2vpn evpn summary"
done
```

```bash
docker exec clab-evpn-vxlan-leaf1 vtysh -c "show evpn vni"
docker exec clab-evpn-vxlan-leaf2 vtysh -c "show evpn vni"

docker exec clab-evpn-vxlan-leaf1 vtysh -c "show bgp l2vpn evpn"
docker exec clab-evpn-vxlan-leaf2 vtysh -c "show bgp l2vpn evpn"
```

```bash
docker exec clab-evpn-vxlan-host1 ping -c 3 192.168.10.12
docker exec clab-evpn-vxlan-host2 ping -c 3 192.168.10.11
```

Evidence:

- `outputs/evpn-bgp-summary.md`
- `outputs/evpn-routes.md`
- `outputs/host-overlay-reachability.md`

---

## 11. Explicit Route Target Cleanup Validation

The lab originally worked with auto-derived route targets. Because `leaf1` and `leaf2` use different ASNs, the auto-derived RT values were different per leaf.

For clearer service-level design, L2VNI `10010` now uses an explicit common RT:

```text
RT: 65000:10010
```

Expected result:

- local and remote EVPN routes for VNI `10010` carry `RT:65000:10010`
- Type-2 MAC routes are still visible
- Type-3 IMET routes are still visible
- remote VTEP learning still works
- host overlay reachability still works

Validation commands:

```bash
docker exec clab-evpn-vxlan-leaf1 vtysh -c "show bgp l2vpn evpn"
docker exec clab-evpn-vxlan-leaf2 vtysh -c "show bgp l2vpn evpn"

docker exec clab-evpn-vxlan-host1 ping -c 3 192.168.10.12
docker exec clab-evpn-vxlan-host2 ping -c 3 192.168.10.11
```

Save output:

```bash
{
  echo "# EVPN Route Target Cleanup Validation"
  echo
  echo "## leaf1 EVPN routes"
  docker exec clab-evpn-vxlan-leaf1 vtysh -c "show bgp l2vpn evpn"
  echo
  echo "## leaf2 EVPN routes"
  docker exec clab-evpn-vxlan-leaf2 vtysh -c "show bgp l2vpn evpn"
  echo
  echo "## host1 to host2"
  docker exec clab-evpn-vxlan-host1 ping -c 3 192.168.10.12
  echo
  echo "## host2 to host1"
  docker exec clab-evpn-vxlan-host2 ping -c 3 192.168.10.11
} > outputs/evpn-rt-cleanup.md
```

Evidence:

- `outputs/evpn-rt-cleanup.md`

---

## 12. Key Interpretation Notes

### RD and RT have different roles

The Route Distinguisher and Route Target are not the same thing.

The RD makes EVPN routes unique in the BGP table.

In this lab, each leaf has its own RD:

```text
leaf1 RD: 10.255.1.1:2
leaf2 RD: 10.255.1.2:2
```

This is expected and does not need to be the same across leaves.

The RT controls route import and export.

For the same L2VNI, both leaves should import and export the same RT:

```text
RT: 65000:10010
```

This means both VTEPs are participating in the same EVPN service for L2VNI `10010`.

A useful rule:

```text
RD can be different per VTEP.
RT should be consistent for the same EVPN service.
```

---

### EVPN Type-2 routes are MAC reachability routes

EVPN Type-2 routes advertise MAC reachability.

Example:

```text
[2]:[0]:[48]:[aa:c1:ab:fc:81:0c]
```

Interpretation:

```text
[2]  = EVPN Type-2 route
[48] = MAC address length, 48 bits
aa:c1:ab:fc:81:0c = advertised MAC address
```

For a local Type-2 route, the next hop is the local VTEP.

Example:

```text
Next Hop: 10.255.1.1
Weight: 32768
```

This means the MAC is locally attached to `leaf1`.

For a remote Type-2 route, the next hop is the remote VTEP.

Example:

```text
Next Hop: 10.255.1.2
AS Path: 65000 65102
```

This means the MAC is reachable behind `leaf2`, and traffic should be sent through VXLAN toward VTEP `10.255.1.2`.

Type-2 routes are the key EVPN routes that allow one VTEP to learn where remote host MAC addresses live.

---

### EVPN Type-3 routes identify remote VTEPs for the VNI

EVPN Type-3 routes are IMET routes.

They indicate that a VTEP participates in a given VNI.

Example:

```text
[3]:[0]:[32]:[10.255.1.2]
```

Interpretation:

```text
[3] = EVPN Type-3 route
10.255.1.2 = remote VTEP address
```

In this lab, Type-3 routes allow:

```text
leaf1 to know that leaf2 participates in VNI 10010
leaf2 to know that leaf1 participates in VNI 10010
```

This is also why `show evpn vni` shows:

```text
# Remote VTEPs: 1
```

Type-3 routes are important for BUM traffic handling:

```text
Broadcast
Unknown unicast
Multicast
```

A useful rule:

```text
Type-2 tells us where MAC addresses are.
Type-3 tells us which remote VTEPs participate in the VNI.
```

---

### Multiple remote paths are expected with two spines

Remote EVPN routes may appear twice in the BGP table.

Example:

```text
*> [2] ... 10.255.1.2 ... 65000 65102 i
*          10.255.1.2 ... 65000 65102 i
```

This is expected because the route can be received through both spines:

```text
leaf2 -> spine1 -> leaf1
leaf2 -> spine2 -> leaf1
```

The symbols mean:

```text
* = valid path
> = selected best path
```

So:

```text
*> = valid and selected as best
*  = valid but not selected as best
```

This is not a problem.

It shows that the EVPN control plane has multiple valid paths through the fabric.

Important distinction:

```text
BGP EVPN chooses a best control-plane path.
The VXLAN data-plane outer IP traffic still follows the underlay routing table.
```

For VXLAN traffic, the outer IP path is between VTEP loopbacks:

```text
10.255.1.1 -> 10.255.1.2
```

The underlay can still use ECMP to forward that outer IP traffic across the available spine paths.

---

### ET:8 is not the main validation focus at this stage

The output includes:

```text
ET:8
```

For this lab stage, do not over-focus on this field.

It is related to EVPN Ethernet Tag information.

At this stage, the more important validation points are:

```text
Type-2 routes exist
Type-3 routes exist
RT is consistent
next hop is the correct local or remote VTEP
remote VTEP is learned
host overlay ping works
```

The current lab is successful because:

```text
RT is now consistently 65000:10010
Type-2 MAC routes are visible
Type-3 IMET routes are visible
leaf1 and leaf2 learn each other as remote VTEPs
host1 and host2 can ping across VXLAN
```

---

## 13. Output Checklist

Expected output files for this completed step:

```text
outputs/underlay-bgp-summary.md
outputs/vtep-reachability.md
outputs/static-vxlan-data-plane.md
outputs/evpn-bgp-summary.md
outputs/evpn-routes.md
outputs/host-overlay-reachability.md
outputs/evpn-rt-cleanup.md
```

Optional additional outputs:

```text
outputs/interface-addresses.md
outputs/underlay-routes.md
```

---

## 14. Cleanup

Destroy the lab:

```bash
sudo containerlab destroy -t topology.clab.yml
```

Destroy and remove runtime files if needed:

```bash
sudo containerlab destroy -t topology.clab.yml --cleanup
```

---

## 15. Completion Criteria

This EVPN/VXLAN validation stage is complete when:

- all containers start successfully
- all underlay eBGP sessions are established
- VTEP loopback reachability works with loopback IP source addresses
- VXLAN data plane works
- EVPN BGP sessions are established
- VNI `10010` is discovered as an L2VNI
- Type-2 MAC routes are visible
- Type-3 IMET routes are visible
- RT is explicitly and consistently set to `65000:10010`
- host overlay reachability works between `host1` and `host2`



## Note: A dedicated spine-path failure test is skipped for now. The EVPN route table already showed remote Type-2 and Type-3 routes learned through both spine paths, which is enough evidence for the current lab stage. Failure convergence testing can be added later.
