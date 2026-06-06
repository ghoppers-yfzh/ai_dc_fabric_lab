# EVPN/VXLAN Design Notes

## 1. Purpose

This document explains how the existing routed eBGP leaf-spine underlay can be extended into an EVPN/VXLAN overlay lab.

The goal is not to build a full production EVPN fabric immediately.

The goal is to understand the relationship between:

- routed underlay
- VTEP reachability
- VXLAN data plane
- BGP EVPN control plane
- L2VNI-based host reachability

The first EVPN/VXLAN lab should stay intentionally small and easy to troubleshoot.

---

## 2. Current Underlay Foundation

The existing `labs/01-frr-leaf-spine/` lab already provides:

- 2 spine switches
- 4 leaf switches
- 4 Linux hosts
- eBGP underlay
- loopback reachability
- ECMP validation
- L3 host-to-host reachability
- basic failure testing
- saved validation outputs

This underlay provides the IP reachability required for VTEPs to communicate.

In EVPN/VXLAN, the routed underlay does not need to know tenant MAC addresses.  
Its job is to provide stable IP reachability between VTEP loopbacks.

---

## 3. Underlay vs Overlay

The underlay is responsible for IP reachability between leaf switches.

In this project, the underlay uses:

- point-to-point `/31` links
- loopback addresses
- eBGP between spines and leaves
- ECMP paths across both spines

The overlay is responsible for carrying tenant or workload traffic across the routed underlay.

In EVPN/VXLAN:

- VXLAN provides the data plane encapsulation.
- EVPN provides the BGP control plane for MAC/IP reachability.
- leaf switches act as VTEPs.
- hosts can appear to be in the same L2 segment even when their leaf switches are separated by a routed L3 fabric.

This separation is important in modern data center fabrics because the underlay can stay simple and stable, while the overlay provides workload connectivity.

---

## 4. VTEP Loopbacks

Each leaf switch will act as a VTEP.

The VTEP source address should be a stable loopback address instead of a physical interface address.

Planned VTEP addresses:

| Leaf | VTEP Address |
|---|---|
| `leaf1` | `10.255.1.1` |
| `leaf2` | `10.255.1.2` |
| `leaf3` | `10.255.1.3` |
| `leaf4` | `10.255.1.4` |

The underlay must be able to route between these loopbacks before VXLAN can work.

Basic VTEP validation should confirm:

- each leaf has a stable loopback address
- each remote VTEP loopback is reachable through the underlay
- ECMP is available where expected
- VTEP reachability does not depend on a single physical interface

---

## 5. Initial EVPN/VXLAN Lab Scope

The first EVPN/VXLAN lab should be intentionally small.

Initial lab scope:

- 2 spines
- 2 leaves
- 2 hosts
- 1 VLAN
- 1 L2VNI
- same-subnet host-to-host reachability across VXLAN

Initial topology:

```text
          spine1        spine2
           /  \          /  \
        leaf1  \        /  leaf2
          |     \      /     |
        host1    routed    host2
                 underlay
```

Initial overlay design:

| Item | Value |
|---|---|
| VLAN | `10` |
| L2VNI | `10010` |
| host1 IP | `192.168.10.11/24` |
| host2 IP | `192.168.10.12/24` |
| VTEP leaf1 | `10.255.1.1` |
| VTEP leaf2 | `10.255.1.2` |

The expected result is that `host1` and `host2` can reach each other in the same subnet even though they are connected to different leaf switches.

---

## 6. Why Start with L2VNI Only

The first overlay lab should avoid too many moving parts.

Do first:

- one VLAN
- one L2VNI
- same-subnet host reachability
- EVPN MAC route learning
- VXLAN tunnel validation

Do not add yet:

- L3VNI
- VRF
- anycast gateway
- multi-tenant routing
- symmetric IRB
- automation

This keeps the first EVPN/VXLAN lab focused on the basic relationship between the EVPN control plane and the VXLAN data plane.

After the first L2VNI lab works, later labs can add distributed gateway and inter-subnet routing.

---

## 7. Control Plane and Data Plane

The EVPN/VXLAN lab has two major parts.

### Control Plane

The control plane is BGP EVPN.

Its job is to advertise reachability information such as:

- VTEP information
- MAC addresses
- MAC/IP bindings
- VNI membership

In this first lab, the most important behavior is MAC route advertisement between VTEPs.

### Data Plane

The data plane is VXLAN.

Its job is to encapsulate host traffic between VTEPs.

For same-subnet host traffic:

```text
host1 -> leaf1 VTEP -> VXLAN over routed underlay -> leaf2 VTEP -> host2
```

The routed underlay only sees IP traffic between VTEP loopbacks.  
The tenant or host traffic is carried inside the VXLAN encapsulation.

---

## 8. Validation Goals

The first EVPN/VXLAN lab is successful when:

- the routed underlay is established
- VTEP loopbacks are reachable
- EVPN BGP sessions are established
- MAC routes are advertised through EVPN
- host1 can ping host2 in the same subnet across VXLAN
- validation outputs are saved under `labs/02-evpn-vxlan/outputs/`

Expected validation files:

```text
labs/02-evpn-vxlan/outputs/underlay-bgp-summary.md
labs/02-evpn-vxlan/outputs/vtep-reachability.md
labs/02-evpn-vxlan/outputs/evpn-bgp-summary.md
labs/02-evpn-vxlan/outputs/evpn-routes.md
labs/02-evpn-vxlan/outputs/host-overlay-reachability.md
```

Suggested validation checks:

```text
show bgp ipv4 unicast summary
show bgp l2vpn evpn summary
show bgp l2vpn evpn
show evpn vni
show interface vxlan
ping between VTEP loopbacks
ping from host1 to host2
```

The exact command syntax may vary depending on the FRR version and configuration model used in the lab.

---

## 9. Planned Lab Directory

The implementation lab should be created under:

```text
labs/02-evpn-vxlan/
```

Planned files:

```text
labs/02-evpn-vxlan/
├── README.md
├── topology.clab.yml
├── ip-asn-plan.md
├── validation.md
├── configs/
├── outputs/
└── failure-tests/
```

The first version should focus on a minimal two-leaf overlay lab.

It should not copy every feature from the completed `labs/01-frr-leaf-spine/` lab immediately.  
The purpose is to reduce troubleshooting scope while learning EVPN/VXLAN behavior.

---

## 10. Relationship to AI Data Center Networking

EVPN/VXLAN is not specific to AI workloads, but it is relevant to modern data center fabric design.

For AI infrastructure networking, this topic is useful because it builds understanding of:

- routed leaf-spine foundations
- separation between underlay and overlay
- workload mobility and segmentation
- BGP-based fabric control planes
- operational validation of data center fabrics

However, EVPN/VXLAN is not the same as RoCEv2 or lossless Ethernet.

Future AI fabric topics such as RDMA, PFC, ECN, and DCQCN should be studied separately after the basic fabric and overlay concepts are clear.

---

## 11. Future Extensions

After the first L2VNI lab works, future extensions can include:

- leaf3 and leaf4
- multiple VNIs
- anycast gateway
- L3VNI
- VRF
- inter-subnet routing
- failure testing
- automation with Ansible
- comparison with Cumulus Linux and SONiC EVPN models

A practical extension sequence could be:

```text
1. L2VNI between leaf1 and leaf2
2. L2VNI across four leaves
3. anycast gateway
4. L3VNI and VRF
5. failure testing
6. automation
7. comparison with Cumulus or SONiC
```

---

## 12. Completion Criteria

This design step is complete when:

- the purpose of EVPN/VXLAN in this project is clear
- the underlay/overlay relationship is documented
- VTEP loopback usage is documented
- the first L2VNI lab scope is defined
- validation goals are listed
- the next lab directory and expected artifacts are defined

The next implementation step is to create the initial `labs/02-evpn-vxlan/` lab with a minimal 2-leaf / 2-host topology.
