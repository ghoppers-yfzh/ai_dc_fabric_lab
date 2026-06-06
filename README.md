# AI Data Center Fabric Lab

A practical lab project for learning AI data center networking, GPU cluster fabric concepts, and data center fabric automation.

This repo focuses on the infrastructure layer that supports AI and GPU workloads:

- data center fabric design
- eBGP underlay
- EVPN/VXLAN overlay
- RoCEv2 and lossless Ethernet concepts
- automation
- validation
- observability
- operational readiness

## Purpose

The purpose of this repo is to build practical engineering experience for AI infrastructure networking.

The project follows this loop:

```text
Concept -> Lab -> Validation -> Notes
```

Each major topic should produce at least one concrete artifact:

- lab topology
- design note
- configuration example
- validation output
- failure test
- troubleshooting note
- automation workflow
- diagram

## Current Status

The first routed fabric baseline has been completed.

| Area | Status | Notes |
|---|---|---|
| `labs/00-platform-validation` | Completed | Containerlab and FRR smoke tests |
| `labs/01-frr-leaf-spine` | Completed | Routed eBGP leaf-spine underlay with Linux hosts and validation outputs |
| `docs/01-evpn-vxlan-design.md` | Next | Design notes before building the EVPN/VXLAN lab |
| `labs/02-evpn-vxlan` | Planned | First overlay lab on top of a routed underlay |

## Current Focus

The current focus is moving from a validated routed underlay into EVPN/VXLAN overlay learning.

The immediate next step is:

```text
docs/01-evpn-vxlan-design.md
```

After the design note is written, the next lab will be:

```text
labs/02-evpn-vxlan/
```

The first EVPN/VXLAN lab should start small:

- 2 leaves
- 2 hosts
- one L2VNI
- same-subnet host-to-host reachability across VXLAN
- no L3VNI, VRF, or anycast gateway until the first L2VNI works

## Repository Structure

```text
ai-dc-fabric-lab/
├── README.md
├── docs/
│   ├── 00-master-learning-roadmap.md
│   └── 01-evpn-vxlan-design.md
├── labs/
│   ├── 00-platform-validation/
│   ├── 01-frr-leaf-spine/
│   └── 02-evpn-vxlan/
├── diagrams/
├── scripts/
└── validation/
```

Some directories and files are planned and will be added only when they are useful. The repo should grow through completed labs and useful notes, not empty placeholders.

## Completed Lab 01 Summary

`labs/01-frr-leaf-spine/` is the first full lab.

Completed scope:

- 2 spine switches
- 4 leaf switches
- 4 Linux hosts
- FRR-based routing nodes
- Containerlab topology
- `/31` point-to-point spine-leaf links
- loopback addressing
- private ASN allocation
- eBGP underlay
- loopback reachability validation
- ECMP validation
- basic failure testing
- L3 host-to-host reachability
- validation outputs saved in Markdown where practical

## Quick Start

Platform validation:

```bash
cd labs/00-platform-validation

sudo containerlab deploy -t alpine-smoke-test.clab.yml
sudo containerlab inspect -t alpine-smoke-test.clab.yml
sudo containerlab destroy -t alpine-smoke-test.clab.yml --cleanup

sudo containerlab deploy -t frr-smoke-test.clab.yml
docker exec -it clab-frr-mini-test-r1 vtysh
sudo containerlab destroy -t frr-smoke-test.clab.yml --cleanup
```

FRR leaf-spine lab:

```bash
cd labs/01-frr-leaf-spine

sudo containerlab deploy -t topology.clab.yml
sudo containerlab inspect -t topology.clab.yml
sudo containerlab destroy -t topology.clab.yml --cleanup
```

## Documentation Entry Points

Start with:

```text
docs/00-master-learning-roadmap.md
labs/01-frr-leaf-spine/README.md
```

Next document to write:

```text
docs/01-evpn-vxlan-design.md
```
