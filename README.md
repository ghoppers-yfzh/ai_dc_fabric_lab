# AI Data Center Fabric Lab

A practical engineering portfolio for learning AI data center networking, GPU cluster fabrics, NVIDIA networking technologies, network automation, and operational validation.

This repository focuses on the infrastructure beneath AI and GPU workloads rather than machine learning model development. It connects traditional data center networking skills with the requirements of modern AI infrastructure:

- leaf-spine / Clos fabric design
- eBGP routed underlays
- EVPN/VXLAN overlays
- SONiC and Cumulus Linux
- RoCEv2, RDMA, PFC, ECN, and DCQCN
- InfiniBand architecture and operations
- NVIDIA Spectrum-X and BlueField concepts
- Python and Ansible network automation
- validation, observability, failure testing, and rollback

## Current Focus

The current learning phase uses NCP-AIN material as a structured path through NVIDIA AI infrastructure networking.

The study track has progressed through:

- Cumulus Linux fundamentals and NVUE
- Layer 2, VLAN-aware bridges, STP, bonds, LACP, and MLAG
- Layer 3, VRR/VRRP, VRF, and FRR
- data center BGP, peer groups, and BGP unnumbered
- VXLAN, EVPN, and distributed routing models
- RoCE configuration, QoS profiles, buffer pools, PFC, ECN, and packet trimming
- Ansible modules, roles, templates, Vault, and PRA-style change workflows
- BlueField DPU, SuperNIC, and DOCA concepts
- InfiniBand architecture, Subnet Manager behavior, LID-based forwarding, fabric topologies, and SHARP

The immediate focus is deepening InfiniBand operations and connecting GPU collective communication concepts—such as Reduce and AllReduce—to the network technologies that support them.

## Progress Overview

| Area | Status | Evidence |
|---|---:|---|
| FRR and Containerlab fabric foundation | Completed | Labs 00–02 |
| SONiC configuration and routed fabric | Completed | Labs 03–06 |
| Automated SONiC validation | Completed | Lab 07 |
| Linux ECN and queue-marking experiment | Completed | Lab 08 |
| AI workload traffic patterns | In progress | Lab 09 notes and workload validation docs |
| Cumulus Linux / NVUE automation | Completed | Labs 10–12 |
| RoCEv2 and AI fabric design notes | Established | Core docs 08–13 |
| NCP-AIN reading track | Active | `docs/NCP-AIN_Reading/00` through `10` |
| InfiniBand operations | Active | NCP-AIN InfiniBand notes and core doc 14 |

## Lab Index

| Lab | Status | Main Outcome |
|---|---:|---|
| [`00-platform-validation`](labs/00-platform-validation/) | Completed | Validated Docker, Containerlab, Alpine, and FRR lab execution |
| [`01-frr-leaf-spine`](labs/01-frr-leaf-spine/) | Completed | Built a 2-spine / 4-leaf routed eBGP fabric with ECMP, host reachability, and failure testing |
| [`02-evpn-vxlan`](labs/02-evpn-vxlan/) | Completed | Implemented EVPN/VXLAN with L2VNI, L3VNI, anycast gateway, and overlay validation |
| [`03-sonic-containerlab`](labs/03-sonic-containerlab/) | Completed | Explored SONiC VS boot, interface mapping, ConfigDB, and basic reachability |
| [`04-sonic-ebgp`](labs/04-sonic-ebgp/) | Completed | Built a minimal two-node SONiC eBGP lab and documented runtime troubleshooting |
| [`05-sonic-leaf-spine-ebgp`](labs/05-sonic-leaf-spine-ebgp/) | Completed | Extended SONiC eBGP into a 2-spine / 2-leaf routed underlay |
| [`06-sonic-automation`](labs/06-sonic-automation/) | Completed | Automated deployment, ConfigDB loading, runtime preparation, BGP loading, and validation |
| [`07-sonic-validation-checks`](labs/07-sonic-validation-checks/) | Completed | Added Python-based underlay checks and a generated PASS/FAIL validation summary |
| [`08-linux-ecn-queue-marking`](labs/08-linux-ecn-queue-marking/) | Completed | Demonstrated ECN-capable traffic and queue marking with Linux namespaces, `tc`, packet capture, and saved evidence |
| [`09-ai-workload-traffic-patterns`](labs/09-ai-workload-traffic-patterns/) | In progress | Building a network-engineer view of collective communication and AI workload traffic |
| [`10-Spectrum-X_Cumulus_Ansible_Basic`](labs/10-Spectrum-X_Cumulus_Ansible_Basic/) | Completed | Used Ansible and NVIDIA NVUE modules for inventory validation, configuration, verification, and rollback |
| [`11-Spectrum-X_Cumulus_Ansible_Role`](labs/11-Spectrum-X_Cumulus_Ansible_Role/) | Completed | Converted Cumulus automation into reusable roles, variables, and templates |
| [`12-Spectrum-X_Cumulus_Ansible_PRA`](labs/12-Spectrum-X_Cumulus_Ansible_PRA/) | Completed | Implemented a PRA-style DNS change workflow with preview, backup, validation, and rollback |

## NCP-AIN Learning Track

The `docs/NCP-AIN_Reading/` directory records the current NVIDIA networking study path. These files are working engineering notes rather than exam dumps: the goal is to connect each topic to configuration, operations, automation, or AI fabric design.

| Topic | Reading Note | Related Practical Evidence |
|---|---|---|
| Cumulus Linux basics | [`00-Spectrum-X_Cumulus_Basic_notes.md`](docs/NCP-AIN_Reading/00-Spectrum-X_Cumulus_Basic_notes.md) | ZTP, package management, system setup |
| NVUE | [`01-Spectrum-X_Cumulus_NVUE_notes.md`](docs/NCP-AIN_Reading/01-Spectrum-X_Cumulus_NVUE_notes.md) | NVUE configuration workflow and API concepts |
| Layer 2 | [`02-Spectrum-X_Cumulus_Layer2_notes.md`](docs/NCP-AIN_Reading/02-Spectrum-X_Cumulus_Layer2_notes.md) | VLAN-aware bridge, SVI, and STP notes |
| LAG and MLAG | [`03-Spectrum-X_Cumulus_LAG_notes.md`](docs/NCP-AIN_Reading/03-Spectrum-X_Cumulus_LAG_notes.md) | Bond, LACP, load balancing, and MLAG |
| Layer 3 | [`04-Spectrum-X_Cumulus_Layer3_notes.md`](docs/NCP-AIN_Reading/04-Spectrum-X_Cumulus_Layer3_notes.md) | VRR/VRRP, VRF, and FRR |
| BGP | [`05-Spectrum-X_Cumulus_BGP_notes.md`](docs/NCP-AIN_Reading/05-Spectrum-X_Cumulus_BGP_notes.md) | Data center BGP, peer groups, and unnumbered BGP |
| VXLAN and EVPN | [`06-Spectrum-X_Cumulus_Virtual_notes.md`](docs/NCP-AIN_Reading/06-Spectrum-X_Cumulus_Virtual_notes.md) | Centralized, asymmetric, and symmetric routing models |
| RoCE | [`07-Spectrum-X_Cumulus_RoCE_notes.md`](docs/NCP-AIN_Reading/07-Spectrum-X_Cumulus_RoCE_notes.md) | PFC, ECN, buffer pools, traffic classes, packet trimming, and validation |
| Ansible | [`08-Spectrum-X_Cumulus_Ansible_notes.md`](docs/NCP-AIN_Reading/08-Spectrum-X_Cumulus_Ansible_notes.md) | Labs 10–12: playbooks, roles, templates, Vault, and PRA |
| BlueField | [`09-BlueField_DPU_notes.md`](docs/NCP-AIN_Reading/09-BlueField_DPU_notes.md) | DPU vs SuperNIC, isolation, offload, and DOCA |
| InfiniBand | [`10-InfiniBand_Basic_notes.md`](docs/NCP-AIN_Reading/10-InfiniBand_Basic_notes.md) | HCA, SM, LID, routing, bandwidth generations, topologies, and SHARP |

## Core Documentation

### Fabric foundations

- [`00-master-learning-roadmap.md`](docs/00-master-learning-roadmap.md)
- [`01-evpn-vxlan-design.md`](docs/01-evpn-vxlan-design.md)
- [`02-sonic-containerlab-basics.md`](docs/02-sonic-containerlab-basics.md)
- [`03-frr-ebgp-underlay-notes.md`](docs/03-frr-ebgp-underlay-notes.md)
- [`04-sonic-runtime-and-bgp-notes.md`](docs/04-sonic-runtime-and-bgp-notes.md)
- [`05-ai-fabric-requirements-notes.md`](docs/05-ai-fabric-requirements-notes.md)
- [`07-lessons-learned.md`](docs/07-lessons-learned.md)

### RDMA, RoCE, and AI workload networking

- [`00-RDMA-ROCEv2-reading-notes.md`](docs/00-RDMA-ROCEv2-reading-notes.md)
- [`08-rocev2-lossless-ethernet-notes.md`](docs/08-rocev2-lossless-ethernet-notes.md)
- [`09-infiniband-vs-ethernet-notes.md`](docs/09-infiniband-vs-ethernet-notes.md)
- [`10-nvidia-spectrum-x-notes.md`](docs/10-nvidia-spectrum-x-notes.md)
- [`11-cumulus-linux-nvue-notes.md`](docs/11-cumulus-linux-nvue-notes.md)
- [`12-ai-workload-network-validation.md`](docs/12-ai-workload-network-validation.md)
- [`13-ai-fabric-validation-matrix.md`](docs/13-ai-fabric-validation-matrix.md)
- [`14-infiniband-operations-notes.md`](docs/14-infiniband-operations-notes.md)

### Diagrams

- [`ai-infra-logical-planes.md`](diagrams/ai-infra-logical-planes.md)

## Selected Engineering Outcomes

This repository currently demonstrates:

- leaf-spine and Clos design using routed point-to-point links
- eBGP underlay design, loopback advertisement, ECMP, and failure validation
- EVPN/VXLAN control-plane and data-plane validation
- practical SONiC VS troubleshooting across ConfigDB, Linux interfaces, and FRR runtime
- repeatable shell and Python validation workflows with saved Markdown evidence
- ECN packet observation and queue-marking experiments on Linux
- Cumulus Linux automation with NVUE, Ansible inventory, variables, Vault, roles, and Jinja templates
- change workflows that include preview, backup, validation, and rollback
- cross-layer AI fabric validation thinking from physical readiness through RDMA, NCCL, observability, and workload behavior
- operational study of RoCEv2, Spectrum-X, BlueField, InfiniBand, and GPU collective communication

## Repository Structure

```text
ai_dc_fabric_lab/
├── README.md
├── docs/
│   ├── 00-master-learning-roadmap.md
│   ├── 00-RDMA-ROCEv2-reading-notes.md
│   ├── 01-evpn-vxlan-design.md
│   ├── ...
│   ├── 14-infiniband-operations-notes.md
│   └── NCP-AIN_Reading/
│       ├── 00-Spectrum-X_Cumulus_Basic_notes.md
│       ├── ...
│       └── 10-InfiniBand_Basic_notes.md
├── labs/
│   ├── 00-platform-validation/
│   ├── ...
│   └── 12-Spectrum-X_Cumulus_Ansible_PRA/
├── diagrams/
│   └── ai-infra-logical-planes.md
├── ansible/
├── scripts/
└── validation/
```

## Validation Philosophy

A successful lab should prove more than configuration presence.

Validation is organized as an evidence chain:

```text
Platform
  -> Link and interface state
  -> Underlay routing
  -> Overlay and service reachability
  -> RDMA readiness
  -> RoCE congestion behavior
  -> NCCL readiness
  -> Workload-level behavior
  -> Observability
  -> Failure testing
```

The detailed model is documented in [`docs/13-ai-fabric-validation-matrix.md`](docs/13-ai-fabric-validation-matrix.md).

## Lab Boundaries

The current virtual labs can provide useful evidence for:

- topology and fabric design
- routing and EVPN control-plane behavior
- Linux and virtual NOS operational workflows
- automation structure and change safety
- repeatable validation logic
- basic ECN packet and queue behavior

They do not replace physical GPU, NIC, or switch testing for:

- real RDMA verbs and Queue Pair behavior
- HCA or SuperNIC performance
- hardware PFC, ECN, DCQCN, and buffer behavior at line rate
- InfiniBand fabric operation with a real Subnet Manager
- NCCL collective performance across GPUs
- Spectrum-X adaptive routing and hardware telemetry
- 400G or 800G throughput, latency, and congestion testing

These boundaries are documented explicitly so that the repository remains technically honest while still demonstrating transferable engineering skills.

## Next Milestones

1. Continue the InfiniBand track with deeper operational notes on collective communication, SHARP, routing, validation, and failure behavior.
2. Expand Lab 09 from reading notes into a clear AI workload traffic-pattern and network-validation artifact.
3. Connect the existing Python and Ansible work to the layered AI fabric validation matrix.
4. Add vendor-sandbox or physical-hardware evidence for RoCE and InfiniBand when suitable environments become available.
5. Continue converting important NCP-AIN topics into concise notes, configuration examples, validation checks, and interview-ready explanations.

## Suggested Reading Path

For a quick review of the project:

1. Start with the [`master learning roadmap`](docs/00-master-learning-roadmap.md).
2. Review the [`AI fabric requirements`](docs/05-ai-fabric-requirements-notes.md).
3. Follow the completed fabric labs from [`Lab 01`](labs/01-frr-leaf-spine/) through [`Lab 08`](labs/08-linux-ecn-queue-marking/).
4. Read the [`RoCEv2`](docs/08-rocev2-lossless-ethernet-notes.md), [`Spectrum-X`](docs/10-nvidia-spectrum-x-notes.md), and [`AI workload validation`](docs/12-ai-workload-network-validation.md) notes.
5. Use the [`NCP-AIN reading track`](docs/NCP-AIN_Reading/) for the current NVIDIA-focused study sequence.
6. Review the [`AI fabric validation matrix`](docs/13-ai-fabric-validation-matrix.md) and [`InfiniBand operations notes`](docs/14-infiniband-operations-notes.md).
