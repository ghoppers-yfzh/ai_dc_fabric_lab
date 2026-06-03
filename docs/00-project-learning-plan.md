# Project Learning Plan — AI Data Center Fabric Lab

## 1. Positioning

This project is a practical engineering lab for learning AI infrastructure networking, GPU cluster fabric concepts, and modern data center fabric automation.

It focuses on the infrastructure layer that supports AI workloads.


## 2. Phase overview

| Phase | Focus | Main output |
|---|---|---|
| Phase 0 | Lab platform validation | Prove Docker, Containerlab, FRR containers, and virtual links work |
| Phase 1 | FRR + Containerlab leaf-spine fabric | eBGP underlay, loopbacks, ECMP, validation, failure tests |
| Phase 2 | AI fabric design notes | Explain why AI/GPU fabrics differ from traditional DC networks |
| Phase 3 | EVPN/VXLAN implementation | Overlay design and host-to-host overlay reachability |
| Phase 4 | RoCEv2 / lossless Ethernet concepts | RDMA, PFC, ECN, DCQCN, operational risks |
| Phase 5 | SONiC lab | Cloud-native NOS exposure and operational comparison |
| Phase 6 | NVIDIA / Cumulus / NVIDIA Air notes | NVIDIA networking ecosystem familiarity |
| Phase 7 | Automation and validation | Ansible/Jinja/Python validation, CI-ready checks |


## 3. Phase 0 — Lab platform validation

### Goal

Confirm that the lab host can run the tools required for future labs.

### Learn

- Docker daemon and Docker socket permissions
- Containerlab lifecycle: `deploy`, `inspect`, `destroy`
- Containerlab node naming
- Containerlab-generated `clab-*` runtime directories
- Basic Linux virtual link behavior
- FRR container access through `vtysh`

### Labs

1. Minimal Alpine two-node lab
2. Minimal FRR two-node lab

### Outputs

```text
labs/00-platform-validation/outputs/alpine-smoke-test.md
labs/00-platform-validation/outputs/frr-smoke-test.md
```

## 4. Phase 1 — FRR + Containerlab leaf-spine fabric

### Goal

Build a reproducible data center fabric foundation with 2 spines, 4 leaves, and 4 hosts.

### Lab steps

| Step | Learning topic | Lab action | Output |
|---|---|---|---|
| 1 | Topology modelling | Create `topology.clab.yml` | `containerlab-inspect-initial.txt` |
| 2 | FRR basics | Enter FRR containers and run `vtysh` | `frr-basic-checks.md` |
| 3 | One BGP pair | Configure `spine1 <-> leaf1` manually | `spine1-leaf1-bgp.md` |
| 4 | Full underlay | Configure all spine-leaf eBGP sessions | `bgp-summary-all.txt` |
| 5 | Loopback reachability | Advertise and ping loopbacks | `loopback-ping-tests.txt` |
| 6 | ECMP | Verify multiple equal-cost routes | `ecmp-checks.txt` |
| 7 | Failure testing | Link down, spine down, leaf down | `failure-tests/*.txt` |
| 8 | EVPN/VXLAN design | Write design before implementation | `evpn-vxlan-plan.md` |

## 5. Later phases

### Phase 2 — AI fabric design notes

Write:

```text
docs/01-ai-fabric-overview.md
docs/02-ai-fabric-requirements.md
docs/03-rocev2-lossless-ethernet.md
docs/05-infiniband-vs-ethernet.md
docs/06-monitoring-and-telemetry.md
```

### Phase 3 — EVPN/VXLAN overlay implementation

Build host-to-host overlay reachability using EVPN/VXLAN.

### Phase 4 — RoCEv2 and lossless Ethernet concepts

Document RDMA, RoCEv2, PFC, ECN, DCQCN, congestion behavior, and operational risks.

### Phase 5 — SONiC lab

Build exposure to SONiC and compare operational models with FRR, Cumulus, and Cisco Nexus.

### Phase 6 — NVIDIA / Cumulus / NVIDIA Air notes

Build NVIDIA networking ecosystem relevance.

### Phase 7 — Automation and validation

Add Ansible/Jinja/Python validation only after manual config is understood.

