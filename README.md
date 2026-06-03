# AI Data Center Fabric Lab

A practical lab project for learning AI data center networking, GPU cluster fabric concepts, and data center fabric automation.

This repo focuses on the infrastructure layer that supports AI and GPU workloads: data center fabric design, eBGP underlay, EVPN/VXLAN overlay, RoCEv2 concepts, automation, validation, observability, and operational readiness.


## Purpose

The purpose of this repo is to build engineering experiance for AI infrastructure networking.

The project follows this loop:

```text
Concept -> Lab -> Validation -> Notes
```

Each major topic should produce at least one concrete artifact:

- lab topology
- design note
- configuration example
- automation workflow
- validation output
- failure test
- troubleshooting note
- diagram

## Current focus

### Phase 0 — Lab platform validation

Validate that the lab host can run Docker, Containerlab, Linux containers, FRRouting containers, and virtual links.

### Phase 1 — FRR + Containerlab Leaf-Spine Fabric

Build a reproducible 2-spine / 4-leaf / 4-host data center fabric using open tools.

Phase 1 scope:

- Containerlab topology
- FRRouting spine and leaf nodes
- Linux test hosts
- eBGP underlay
- loopback reachability
- ECMP validation
- failure testing
- EVPN/VXLAN design notes before full implementation

Phase 1 is intentionally not a full GPU or RoCE simulation. The goal is to establish a clean data center fabric foundation first.

## Repository structure

```text
ai-dc-fabric-lab/
├── README.md
├── docs/
├── labs/
│   ├── 00-platform-validation/
│   ├── 01-frr-leaf-spine/
│   ├── 02-evpn-vxlan/
│   ├── 03-sonic-containerlab/
│   └── 04-nvidia-air-cumulus-notes/
├── diagrams/
├── scripts/
└── validation/
```

## Quick start

```bash
cd labs/00-platform-validation

containerlab deploy -t alpine-smoke-test.clab.yml
containerlab inspect -t alpine-smoke-test.clab.yml
containerlab destroy -t alpine-smoke-test.clab.yml

containerlab deploy -t frr-smoke-test.clab.yml
docker exec -it clab-frr-mini-test-r1 vtysh
containerlab destroy -t frr-smoke-test.clab.yml
```
