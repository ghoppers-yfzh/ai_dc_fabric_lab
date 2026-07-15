# AI Data Center Fabric Lab

A practical lab project for learning AI data center networking, GPU cluster fabric concepts, data center fabric automation, and operational validation.

This repo focuses on the infrastructure layer that supports AI and GPU workloads:

- leaf-spine / Clos fabric design
- eBGP routed underlay
- EVPN/VXLAN overlay
- SONiC virtual lab workflow
- RoCEv2 and lossless Ethernet concepts
- RDMA congestion-control concepts
- automation and repeatable validation
- observability and operational readiness

## Purpose

The purpose of this repo is to build practical engineering understanding of modern data center and AI infrastructure networking.

The project follows this loop:

```text
Concept -> Lab -> Validation -> Notes -> Repeat
```

Each major topic should produce at least one concrete artifact:

- lab topology
- design note
- configuration example
- validation output
- troubleshooting note
- automation workflow
- failure test
- diagram

The repo should grow through completed labs and useful notes, not empty placeholders.

## Current Status

The project has progressed from basic Containerlab validation to SONiC underlay automation.

| Area | Status | Notes |
|---|---:|---|
| `labs/00-platform-validation` | Completed | Containerlab, Alpine, and FRR smoke tests |
| `labs/01-frr-leaf-spine` | Completed | FRR routed eBGP leaf-spine underlay with hosts, ECMP, failure testing, and validation outputs |
| `labs/02-evpn-vxlan` | Completed | EVPN/VXLAN overlay with L2VNI, L3VNI, anycast gateway, inter-subnet reachability, and validation outputs |
| `labs/03-sonic-containerlab` | Completed | SONiC VS boot, interface mapping, ConfigDB basics, and basic reachability |
| `labs/04-sonic-ebgp` | Completed | Two-node SONiC eBGP lab and runtime troubleshooting |
| `labs/05-sonic-leaf-spine-ebgp` | Completed | 2-spine / 2-leaf SONiC eBGP underlay with loopback route validation |
| `labs/06-sonic-automation` | Completed | Host-side automation for deployment, ConfigDB loading, runtime preparation, BGP loading, and underlay validation |
| `docs/08-rocev2-lossless-ethernet-notes.md` | Completed | Concept note for RoCEv2, PFC, ECN, DCQCN, buffer management, and telemetry |

## Current Focus

The current focus is moving from manual lab execution into repeatable validation and AI fabric concept depth.

Immediate focus areas:

```text
1. Keep Lab 06 clean and repeatable.
2. Use validation output as evidence.
3. Continue AI fabric reading and notes.
4. Add InfiniBand vs Ethernet and telemetry notes.
5. Explore NVIDIA Air / Cumulus Linux when ready.
```

## Repository Structure

```text
ai-dc-fabric-lab/
├── README.md
├── docs/
│   ├── 00-master-learning-roadmap.md
│   ├── 01-evpn-vxlan-design.md
│   ├── 02-sonic-containerlab-basics.md
│   ├── 03-frr-ebgp-underlay-notes.md
│   ├── 04-sonic-runtime-and-bgp-notes.md
│   ├── 05-ai-fabric-requirements-notes.md
│   ├── 06-reading-plan-lab00-to-lab06.md
│   ├── 07-lessons-learned.md
│   └── 08-rocev2-lossless-ethernet-notes.md
├── labs/
│   ├── 00-platform-validation/
│   ├── 01-frr-leaf-spine/
│   ├── 02-evpn-vxlan/
│   ├── 03-sonic-containerlab/
│   ├── 04-sonic-ebgp/
│   ├── 05-sonic-leaf-spine-ebgp/
│   └── 06-sonic-automation/
│   └── 07-sonic-validation-checks/
│   └── 08-linux-ecn-queue-marking/
│   └── 09-ai-workload-traffic-patterns/
├── diagrams/
├── scripts/
└── ansible/
```

## Lab Summaries

### Lab 00 - Platform Validation

Purpose:

```text
Prove the local platform can run small Containerlab topologies.
```

Main topics:

- Docker
- Containerlab
- management network
- simple container links
- FRR smoke testing

### Lab 01 - FRR Leaf-Spine Routed Underlay

Purpose:

```text
Build and validate a basic routed data center fabric.
```

Completed scope:

- 2 spine switches
- 4 leaf switches
- 4 Linux hosts
- FRR routing nodes
- `/31` point-to-point links
- loopback addressing
- private ASNs
- eBGP underlay
- ECMP validation
- failure testing
- host-to-host reachability
- validation outputs saved in Markdown

### Lab 02 - EVPN/VXLAN

Purpose:

```text
Show how a routed underlay can support an overlay.
```

Completed scope:

- BGP EVPN control plane
- VXLAN data plane
- VTEP loopbacks
- L2VNI
- L3VNI
- anycast gateway
- inter-subnet reachability
- EVPN route validation
- overlay data-plane validation

Key lesson:

```text
EVPN/VXLAN is a modern fabric and segmentation foundation, but it does not solve RoCEv2 congestion or lossless Ethernet behavior by itself.
```

### Lab 03 - SONiC Containerlab Basics

Purpose:

```text
Understand basic SONiC VS behavior in Containerlab.
```

Completed scope:

- SONiC VS boot
- management vs data interface
- `eth1` to `Ethernet0` mapping
- ConfigDB basics
- basic interface and reachability validation

### Lab 04 - SONiC eBGP

Purpose:

```text
Build a minimal two-node SONiC eBGP lab.
```

Main lessons:

- ConfigDB is intended configuration.
- Runtime processes must be checked separately.
- `bgpd=yes` does not prove `bgpd` is running.
- `vtysh` can open even when `bgpd` is not running.
- Linux-side veth interface state matters in SONiC VS.

### Lab 05 - SONiC Leaf-Spine eBGP

Purpose:

```text
Extend SONiC eBGP into a small leaf-spine underlay.
```

Completed scope:

- 2 spines
- 2 leaves
- eBGP sessions on all spine-leaf links
- loopback advertisement
- BGP route learning
- leaf-to-leaf loopback reachability

### Lab 06 - SONiC Underlay Validation Automation

Purpose:

```text
Automate the known-good SONiC underlay workflow.
```

Completed scope:

- deploy topology
- load ConfigDB
- prepare runtime state
- load BGP config
- validate direct peer reachability
- validate BGP sessions
- validate BGP routes
- validate loopback-to-loopback reachability
- save validation output

Workflow:

```bash
cd labs/06-sonic-automation

bash scripts/01-deploy.sh
bash scripts/02-load-configdb.sh
bash scripts/03-prepare-runtime.sh
bash scripts/04-load-bgp.sh
bash scripts/05-validation-underlay.sh
```

Main validation output:

```text
labs/06-sonic-automation/outputs/underlay-validation.md
```

Key lesson:

```text
For loopback-to-loopback validation, use the local loopback IP as the ping source:

ping -I <local-loopback-ip> <remote-loopback-ip>
```

Without an explicit source IP, Linux may choose a point-to-point link IP as the source. If the remote node does not have a return route to that link subnet, the ping can fail even when the remote loopback route exists.


## AI Fabric Learning Boundary

The current virtual labs are useful for:

- routed fabric design
- BGP underlay behavior
- EVPN/VXLAN concepts
- SONiC operational workflow
- repeatable validation

