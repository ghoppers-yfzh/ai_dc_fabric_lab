# AI Data Center Fabric Lab — Master Learning Roadmap

## Purpose

This document keeps the project focused on practical data center fabric learning.

The goal is to build a clear evidence trail through:

- lab topologies
- configuration files
- validation output
- troubleshooting notes
- design notes
- operational lessons learned

## Lab 00 — Platform Validation

### What this lab proves

Lab 00 proves that the local platform can run small Containerlab topologies.

Main topics:

- Docker
- Containerlab
- basic Linux container networking
- simple point-to-point links
- FRR container access
- basic command capture

### Reading focus

Read enough Containerlab documentation to understand:

- what Containerlab creates
- how topology files describe nodes and links
- how Containerlab names containers
- how management networks differ from lab data links
- how to destroy and clean up a lab

### Do not over-study

Do not spend time on advanced Containerlab features yet. The purpose of Lab 00 is only to prove the platform.

---

## Lab 01 — FRR Leaf-Spine Routed Underlay

### What this lab proves

Lab 01 proves the basic routed fabric model:

- leaf-spine topology
- `/31` point-to-point links
- loopbacks
- private ASNs
- eBGP sessions
- loopback route advertisement
- ECMP
- failure testing
- host reachability through a routed underlay

### Reading focus

Study these topics:

- Clos / leaf-spine design
- why data center fabrics often use routed point-to-point links
- why loopbacks are used as stable node identifiers
- why eBGP is commonly used in data center fabrics
- why ECMP matters
- what failure testing should prove

### Output to keep

The most useful evidence from this lab is not only the topology. It is the validation output showing sessions, routes, ECMP, host reachability, and failure behavior.

---

## Lab 02 — EVPN/VXLAN

### What this lab proves

Lab 02 proves how a routed underlay can support an overlay.

Main topics:

- underlay vs overlay
- VTEP loopbacks
- VXLAN data plane
- BGP EVPN control plane
- L2VNI
- L3VNI
- anycast gateway
- host reachability across the overlay

### Reading focus

Study these topics:

- what a VTEP is
- why VTEP loopback reachability must exist before VXLAN works
- what EVPN type-2 and type-3 routes are
- what L2VNI and L3VNI are used for
- why the routed underlay should not need tenant MAC information
- how to validate control plane and data plane separately

### Important boundary

EVPN/VXLAN is relevant to modern data center fabrics, but it is not the same thing as RoCEv2 or lossless Ethernet. Treat it as a fabric and segmentation foundation.

---

## Lab 03 — SONiC Containerlab Basics

### What this lab proves

Lab 03 proves that SONiC VS can run in Containerlab and that basic interface configuration and reachability can work.

Main topics:

- SONiC VS boot
- management vs data interface
- `eth1` mapped to `Ethernet0`
- ConfigDB basics
- SONiC CLI limitations in the lab image
- Linux commands as backup validation tools

### Reading focus

Study:

- SONiC architecture
- ConfigDB
- Redis database model at a high level
- `sonic-vs` interface mapping
- how SONiC differs from a raw FRR container

---

## Lab 04 — SONiC eBGP

### What this lab proves

Lab 04 proves that two SONiC VS nodes can run basic eBGP once the data link and FRR runtime are handled correctly.

Main lessons:

- the data interface was present but ARP failed until the Linux-side `eth1` veth was brought up
- `show ip interfaces` was not reliable in this image because it tried to call `sudo`
- `bgpd=yes` in `/etc/frr/daemons` did not mean `bgpd` was currently running
- `vtysh` could open even when `bgpd` was not running
- BGP config only applied after `bgpd` was started

### Reading focus

Study:

- FRR daemon model
- `vtysh` as a frontend to FRR daemons
- difference between configuration files and running processes
- SONiC ConfigDB vs FRR runtime config

---

## Lab 05 — SONiC Leaf-Spine eBGP Underlay

### What this lab proves

Lab 05 extends Lab 04 to a small SONiC fabric:

- 2 spines
- 2 leaves
- eBGP on all spine-leaf links
- loopback advertisement
- leaf-to-leaf loopback reachability
- underlay validation on SONiC VS

Main lesson:

A SONiC underlay can be validated with the same fabric logic as the earlier FRR lab, but the operational model is different because SONiC has ConfigDB, Linux interface mapping, and service runtime behavior.

### Reading focus

Study:

- how the same eBGP underlay concept appears across FRR and SONiC
- why validation should check direct links before BGP
- why BGP route learning and loopback reachability are the useful success criteria
- what parts are control-plane learning only and what parts would require real hardware to validate

---

## Lab 06 — Automation Workflow

Lab 06 should not start by generating configs.

It should start by automating the manual workflow that is already understood:

```text
deploy lab
load existing ConfigDB files
bring up needed Linux-side veth links if required
start bgpd if required
load BGP config
run validation
save output
```

Automation should encode known behavior. It should not hide behavior that is still unclear.

Recommended Lab 06 scope:

- use the existing Lab 05 topology and configs
- write small scripts to run repeatable steps
- collect output into `outputs/`
- do not introduce NetBox yet
- do not generate config templates yet

---

---

## AI Fabric Reading Track — RoCEv2 and Lossless Ethernet

This track runs in parallel with the hands-on labs.

The first AI fabric requirement note is:

```text
docs/05-ai-fabric-requirements-notes.md
```

The detailed RoCEv2 congestion-control note is:

```text
docs/08-rocev2-lossless-ethernet-notes.md
```

### What this reading track explains

- why AI/GPU workloads create heavy east-west traffic
- why RDMA/RoCEv2 is more sensitive to packet loss
- why EVPN/VXLAN does not solve RoCEv2 congestion by itself
- how PFC, ECN, DCQCN, buffer management, and telemetry fit together
- why virtual labs are useful for fabric control-plane learning but limited for RoCEv2/lossless Ethernet validation

### Practical learning goal

Be able to explain this relationship clearly:

```text
ECN detects congestion early.
DCQCN slows down the sender.
PFC prevents loss as a last resort.
Buffer management provides room for these mechanisms to work.
Telemetry proves whether the fabric is stable.
```

### Boundary

Do not treat this as a production RoCE tuning guide yet.

The current goal is concept clarity and documentation. Real RoCEv2 validation would require hardware switch ASIC behavior, NIC counters, queue telemetry, PFC/ECN counters, and realistic workload traffic.
