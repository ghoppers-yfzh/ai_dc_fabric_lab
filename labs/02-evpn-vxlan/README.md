# Lab 02 — EVPN/VXLAN Fabric

## Purpose

This lab builds on Lab 01 and extends the basic eBGP leaf-spine fabric into an EVPN/VXLAN data center fabric.

The goal is to demonstrate how a small data center fabric can use:

- eBGP underlay
- EVPN control plane
- VXLAN overlay
- L2VNI for Layer 2 tenant segments
- L3VNI for inter-subnet routing
- Anycast gateway
- Host-to-host validation across the overlay

This lab is part of the `ai-dc-fabric-lab` project. It provides foundational EVPN/VXLAN knowledge that is relevant to modern data center networking, cloud networking, GPU cloud infrastructure, and AI data center fabric design.

---

## Topology Summary

The lab uses a small leaf-spine topology:

```text
             spine1              spine2
               |                   |
        -------------------------------
        |                             |
      leaf1                         leaf2
        |                             |
   -------------                -------------
   |           |                |           |
 host1       host2            host3       host4
```

### Nodes

| Node | Role |
|---|---|
| `spine1` | Spine switch for the fabric underlay and EVPN route exchange |
| `spine2` | Spine switch for the fabric underlay and EVPN route exchange |
| `leaf1` | Leaf switch with EVPN/VXLAN services |
| `leaf2` | Leaf switch with EVPN/VXLAN services |
| `host1` | Linux test host in VLAN 10 |
| `host2` | Linux test host in VLAN 10 |
| `host3` | Linux test host in VLAN 20 |
| `host4` | Linux test host in VLAN 20 |

---

## Network Services Demonstrated

### Underlay

The underlay uses eBGP between the leaf and spine nodes.

The underlay provides IP reachability between loopback addresses. These loopbacks are used as VTEP source addresses for VXLAN.

### Overlay

The overlay uses BGP EVPN to advertise MAC, IP, and VTEP reachability information between leaf switches.

This allows hosts behind different leaf switches to communicate through VXLAN tunnels.

### L2VNI

The lab uses L2VNIs to represent Layer 2 tenant segments.

Example tenant networks:

| VLAN | Subnet | Purpose |
|---|---|---|
| VLAN 10 | `192.168.10.0/24` | Tenant network 10 |
| VLAN 20 | `192.168.20.0/24` | Tenant network 20 |

### L3VNI

The lab also uses an L3VNI for inter-subnet routing.

This allows hosts in different subnets to communicate through the EVPN/VXLAN fabric.

Example:

```text
host1 / host2 in 192.168.10.0/24
can reach
host3 / host4 in 192.168.20.0/24
```

### Anycast Gateway

The leaf switches provide distributed anycast gateway functionality.

This allows the same default gateway IP/MAC to exist on multiple leaf switches, which is a common data center fabric design pattern.

---

## Lab Files

Expected files in this lab directory:

```text
labs/02-evpn-vxlan/
├── README.md
├── topology.clab.yml
├── validation.md
├── configs/
├── outputs/
└── notes/
```

Some directories may be added gradually as the lab evolves.

---

## Deploy the Lab

From the lab directory:

```bash
cd labs/02-evpn-vxlan
sudo containerlab deploy -t topology.clab.yml
```

Check running containers:

```bash
docker ps
```

Check containerlab status:

```bash
sudo containerlab inspect -t topology.clab.yml
```

---

## Basic Validation

### Check BGP Summary

On each FRR node:

```bash
docker exec -it clab-evpn-vxlan-leaf1 vtysh
show bgp summary
show bgp l2vpn evpn summary
```

Repeat on other fabric nodes as needed:

```bash
docker exec -it clab-evpn-vxlan-leaf2 vtysh
docker exec -it clab-evpn-vxlan-spine1 vtysh
docker exec -it clab-evpn-vxlan-spine2 vtysh
```

Expected result:

- Underlay BGP sessions are established.
- EVPN address-family sessions are established.
- Leaf nodes receive EVPN routes from the fabric.

---

## EVPN Route Validation

Useful commands:

```bash
show bgp l2vpn evpn
show bgp l2vpn evpn route type macip
show bgp l2vpn evpn route type multicast
show evpn vni
show evpn mac vni all
```

Expected result:

- Type-2 MAC/IP routes are learned for connected hosts.
- Type-3 inclusive multicast routes are present for VXLAN flood-list handling.
- VNIs are active.
- Remote MAC/IP entries are learned through EVPN.

---

## Host Connectivity Validation

### VLAN 10 to VLAN 20

From `host1`:

```bash
docker exec clab-evpn-vxlan-host1 ping -c 3 192.168.20.13
docker exec clab-evpn-vxlan-host1 ping -c 3 192.168.20.14
```

From `host2`:

```bash
docker exec clab-evpn-vxlan-host2 ping -c 3 192.168.20.13
docker exec clab-evpn-vxlan-host2 ping -c 3 192.168.20.14
```

### VLAN 20 to VLAN 10

From `host3`:

```bash
docker exec clab-evpn-vxlan-host3 ping -c 3 192.168.10.11
docker exec clab-evpn-vxlan-host3 ping -c 3 192.168.10.12
```

From `host4`:

```bash
docker exec clab-evpn-vxlan-host4 ping -c 3 192.168.10.11
docker exec clab-evpn-vxlan-host4 ping -c 3 192.168.10.12
```

Expected result:

```text
0% packet loss
```

---

## Validation Notes

Detailed validation output is recorded in:

```text
validation.md
```

That file should contain command output and test results from the actual lab run.

The README provides the high-level explanation. The validation file provides the operational evidence.

---

## Lessons Learned

Key learning points from this lab:

- EVPN/VXLAN separates the underlay from the overlay.
- The underlay only needs stable IP reachability between VTEPs.
- EVPN provides a control plane for MAC/IP and VTEP reachability.
- L2VNI handles Layer 2 tenant extension.
- L3VNI enables inter-subnet routing through the overlay.
- Anycast gateway allows the gateway function to be distributed across leaf switches.
- Validation must include both control-plane checks and data-plane host testing.

---

## Cleanup

Destroy the lab when finished:

```bash
sudo containerlab destroy -t topology.clab.yml
```

If needed, remove generated runtime files:

```bash
sudo rm -rf clab-evpn-vxlan
```

Do not commit generated containerlab runtime directories to Git.

---

## Suggested Commit Message

```bash
git add labs/02-evpn-vxlan/README.md
git commit -m "Document EVPN VXLAN lab README"
```
