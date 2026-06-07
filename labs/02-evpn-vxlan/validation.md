# Validation Guide — EVPN/VXLAN Lab

## 1. Purpose

This file documents the validation workflow for the EVPN/VXLAN lab.

The first validation step is to confirm that the routed underlay works and that VTEP loopbacks are reachable across the fabric.

EVPN/VXLAN should not be configured until the underlay and VTEP reachability are working.

---

## 2. Current Validation Scope

Current scope:

- deploy the minimal EVPN/VXLAN lab topology
- validate all FRR containers are running
- validate eBGP IPv4 unicast underlay sessions
- validate loopback route advertisement
- validate VTEP loopback reachability between `leaf1` and `leaf2`
- save validation outputs under `outputs/`

Not included yet:

- EVPN address-family
- VXLAN interface
- VLAN to VNI mapping
- L2VNI
- host-to-host overlay reachability

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

At this stage, host-to-host reachability is not expected yet because VXLAN/L2VNI has not been configured.

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

The leaf loopbacks will be used as VTEP source addresses in the EVPN/VXLAN lab.

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

## 9. Current Output Checklist

Expected output files for this step:

```text
outputs/underlay-bgp-summary.md
outputs/vtep-reachability.md
```

Optional additional outputs:

```text
outputs/interface-addresses.md
outputs/underlay-routes.md
```

---

## 10. Cleanup

Destroy the lab:

```bash
sudo containerlab destroy -t topology.clab.yml
```

Destroy and remove runtime files if needed:

```bash
sudo containerlab destroy -t topology.clab.yml --cleanup
```

---

## 11. Completion Criteria

This validation step is complete when:

- all containers start successfully
- all underlay eBGP sessions are established
- `leaf1` learns `leaf2` loopback through BGP
- `leaf2` learns `leaf1` loopback through BGP
- VTEP loopback reachability works with loopback IP source addresses
- validation outputs are saved as Markdown files under `outputs/`

The next step is to add EVPN/VXLAN configuration:

- EVPN BGP address-family
- bridge and VLAN configuration
- VXLAN interface
- L2VNI `10010`
- same-subnet host-to-host reachability between `host1` and `host2`


## EVPN L2VNI Overlay Validation

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