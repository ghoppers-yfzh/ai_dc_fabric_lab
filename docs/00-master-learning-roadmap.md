# AI Data Center Fabric Lab — Master Learning Roadmap

## 1. Purpose

This document describes the full technical learning path for the AI Data Center Fabric Lab.


---

## 2. Final Intended Repository Structure

The repository is expected to grow toward the following structure.

This is the long-term target structure, not a requirement for the first commit.

```text
ai_dc_fabric_lab/
├── README.md
├── docs/
│   ├── 00-master-learning-roadmap.md
│   ├── 01-ai-fabric-overview.md
│   ├── 02-ai-fabric-requirements.md
│   ├── 03-rocev2-lossless-ethernet.md
│   ├── 04-evpn-vxlan-design.md
│   ├── 05-infiniband-vs-ethernet.md
│   ├── 06-monitoring-and-telemetry.md
│   └── 07-lessons-learned.md
├── labs/
│   ├── 00-platform-validation/
│   ├── 01-frr-leaf-spine/
│   ├── 02-evpn-vxlan/
│   ├── 03-sonic-containerlab/
│   └── 04-nvidia-air-cumulus-notes/
├── ansible/
├── scripts/
├── validation/
└── diagrams/
```

The structure should grow naturally as the learning reaches each stage.

Do not create empty folders or shallow documents too early unless they help clarify the current learning step.

---

## 3. How to Use `docs/` and `labs/`

The repository separates technical explanation from hands-on implementation.

```text
docs/ = technical concepts, design notes, comparisons, and cross-lab explanations
labs/ = hands-on lab work, topology files, configs, commands, validation, and test output
```

Use `docs/` when the topic is mainly about understanding or design.

Use `labs/` when the topic is mainly about building, configuring, testing, and validating.

A useful pattern is:

```text
Learn concept -> Build lab -> Validate behavior -> Save outputs -> Write notes
```

The `docs/` files should explain what was learned and why it matters.

The `labs/` files should show how the lab was built and how the behavior was verified.

---

## 4. Learning Sequence Overview

The recommended learning path is:

```text
Phase 0: Platform validation
Phase 1: FRR leaf-spine underlay
Phase 2: AI fabric concepts and requirements
Phase 3: EVPN/VXLAN overlay
Phase 4: RoCEv2 and lossless Ethernet concepts
Phase 5: SONiC lab exposure
Phase 6: NVIDIA / Cumulus / NVIDIA Air notes
Phase 7: Automation and validation
```

This order is intentional.

The project should first build a simple and explainable data center fabric foundation.  
Only after that should it move into overlays, GPU fabric requirements, lossless Ethernet, network operating systems, and automation.

---

## 5. Phase 0 — Platform Validation

### Technical Focus

Phase 0 validates that the local lab environment can run the basic tools needed for later work.

Focus areas:

- Docker
- Containerlab
- basic container networking
- virtual links
- minimal Alpine lab
- minimal FRR lab
- access to FRR containers
- basic `vtysh` checks

### Lab Directory

```text
labs/00-platform-validation/
```

### Expected Artifacts

```text
labs/00-platform-validation/README.md
labs/00-platform-validation/alpine-smoke-test.clab.yml
labs/00-platform-validation/frr-smoke-test.clab.yml
labs/00-platform-validation/outputs/alpine-smoke-test.md
labs/00-platform-validation/outputs/frr-smoke-test.md
```

### Completion Criteria

This phase is complete when:

- a minimal Alpine Containerlab topology can deploy successfully
- a minimal FRR Containerlab topology can deploy successfully
- containers can communicate over virtual links
- FRR containers can be accessed with `vtysh`
- basic validation outputs are saved

---

## 6. Phase 1 — FRR Leaf-Spine Underlay

### Technical Focus

Phase 1 builds the first real data center fabric lab.

Focus areas:

- leaf-spine / Clos topology
- 2-spine / 4-leaf / 4-host design
- point-to-point addressing
- loopback addressing
- private ASN planning
- eBGP underlay
- FRR configuration basics
- BGP session validation
- loopback route advertisement
- ECMP validation
- failure testing

This phase is not about RoCEv2, EVPN/VXLAN implementation, SONiC, or NVIDIA Cumulus yet.

It creates the routing foundation that later phases will build on.

### Lab Directory

```text
labs/01-frr-leaf-spine/
```

### Expected Artifacts

```text
labs/01-frr-leaf-spine/README.md
labs/01-frr-leaf-spine/learning-outline.md
labs/01-frr-leaf-spine/topology.clab.yml
labs/01-frr-leaf-spine/ip-plan.md
labs/01-frr-leaf-spine/asn-plan.md
labs/01-frr-leaf-spine/validation.md
labs/01-frr-leaf-spine/failure-tests.md
labs/01-frr-leaf-spine/configs/
labs/01-frr-leaf-spine/outputs/
labs/01-frr-leaf-spine/failure-tests/
```

### Completion Criteria

This phase is complete when:

- the topology is documented
- the IP plan is documented
- the ASN plan is documented
- the topology can deploy successfully
- FRR nodes start correctly
- one eBGP pair works
- all spine-leaf eBGP sessions work
- loopback routes are advertised
- remote loopbacks are reachable
- ECMP is visible
- basic failure tests are documented
- key command outputs are saved

---

## 7. Phase 2 — AI Fabric Concepts and Requirements

### Technical Focus

Phase 2 explains why AI/GPU data center networking has different requirements from traditional enterprise or hosting data center networking.

Focus areas:

- AI data center fabric overview
- GPU cluster traffic patterns
- east-west traffic
- scale-up vs scale-out networking
- high bandwidth requirements
- low latency requirements
- low packet loss requirements
- predictable multipath behavior
- congestion sensitivity
- oversubscription considerations
- failure domain thinking

This phase should connect the Phase 1 leaf-spine foundation to AI infrastructure requirements.

### Docs

```text
docs/01-ai-fabric-overview.md
docs/02-ai-fabric-requirements.md
```

### Expected Artifacts

```text
docs/01-ai-fabric-overview.md
docs/02-ai-fabric-requirements.md
```

### Completion Criteria

This phase is complete when the documents can clearly explain:

- what an AI data center fabric is
- why GPU workloads create heavy east-west traffic
- why bandwidth, latency, and packet loss matter
- how leaf-spine design supports AI fabric requirements
- which requirements are not fully testable in the local lab

---

## 8. Phase 3 — EVPN/VXLAN Overlay

### Technical Focus

Phase 3 adds overlay networking concepts on top of the underlay foundation.

Focus areas:

- underlay vs overlay
- VTEP
- VNI
- L2 VNI
- L3 VNI
- BGP EVPN control plane
- host-to-host overlay reachability
- relationship between eBGP underlay and EVPN overlay
- validation of overlay behavior

The design should be written before implementation.

### Docs

```text
docs/04-evpn-vxlan-design.md
```

### Lab Directory

```text
labs/02-evpn-vxlan/
```

### Expected Artifacts

```text
docs/04-evpn-vxlan-design.md
labs/02-evpn-vxlan/README.md
labs/02-evpn-vxlan/topology.clab.yml
labs/02-evpn-vxlan/configs/
labs/02-evpn-vxlan/outputs/
labs/02-evpn-vxlan/validation.md
```

### Completion Criteria

This phase is complete when:

- EVPN/VXLAN design is documented
- the underlay/overlay relationship is clear
- overlay lab topology can deploy
- host-to-host overlay reachability works
- validation outputs are saved
- limitations of the lab are documented

---

## 9. Phase 4 — RoCEv2 and Lossless Ethernet Concepts

### Technical Focus

Phase 4 studies the Ethernet-based GPU fabric concepts that are difficult to fully reproduce in a small virtual lab.

Focus areas:

- RDMA
- RoCEv2
- lossless Ethernet
- PFC
- ECN
- DCQCN
- congestion management
- incast
- head-of-line blocking
- buffer pressure
- pause frames
- operational risks
- monitoring requirements

This phase should be honest about what can and cannot be simulated locally.

### Docs

```text
docs/03-rocev2-lossless-ethernet.md
docs/06-monitoring-and-telemetry.md
```

### Expected Artifacts

```text
docs/03-rocev2-lossless-ethernet.md
docs/06-monitoring-and-telemetry.md
```

Optional future concept lab:

```text
labs/rocev2-concepts/
```

### Completion Criteria

This phase is complete when the documents can explain:

- what RDMA is
- what RoCEv2 is
- why packet loss is harmful for RDMA workloads
- why PFC is used
- why PFC can create operational risk
- how ECN and DCQCN relate to congestion control
- what counters and telemetry are important in an AI fabric

---

## 10. Phase 5 — SONiC Lab Exposure

### Technical Focus

Phase 5 introduces SONiC as a cloud-style network operating system.

Focus areas:

- what SONiC is
- SONiC architecture at a high level
- configuration model
- FRR inside SONiC
- basic routing behavior
- comparison with traditional network operating systems
- operational differences

### Lab Directory

```text
labs/03-sonic-containerlab/
```

### Expected Artifacts

```text
labs/03-sonic-containerlab/README.md
labs/03-sonic-containerlab/topology.clab.yml
labs/03-sonic-containerlab/sonic-notes.md
labs/03-sonic-containerlab/outputs/
labs/03-sonic-containerlab/validation.md
```

### Completion Criteria

This phase is complete when:

- a basic SONiC lab or practical notes exist
- SONiC architecture is explained
- basic configuration and validation workflow is documented
- differences from FRR-only and traditional network OS models are documented

---

## 11. Phase 6 — NVIDIA / Cumulus / NVIDIA Air Notes

### Technical Focus

Phase 6 studies the NVIDIA networking ecosystem from a network engineering point of view.

Focus areas:

- NVIDIA Ethernet switching concepts
- Cumulus Linux
- NVUE
- NVIDIA Air
- EVPN/VXLAN on Cumulus
- comparison with SONiC, FRR, and Cisco Nexus
- relationship to AI data center networking

### Lab / Notes Directory

```text
labs/04-nvidia-air-cumulus-notes/
```

### Related Docs

```text
docs/05-infiniband-vs-ethernet.md
```

### Expected Artifacts

```text
labs/04-nvidia-air-cumulus-notes/README.md
labs/04-nvidia-air-cumulus-notes/cumulus-notes.md
labs/04-nvidia-air-cumulus-notes/nvue-notes.md
labs/04-nvidia-air-cumulus-notes/evpn-vxlan-notes.md
labs/04-nvidia-air-cumulus-notes/comparison.md
docs/05-infiniband-vs-ethernet.md
```

### Completion Criteria

This phase is complete when:

- Cumulus Linux basics are documented
- NVUE basics are documented
- NVIDIA Air notes are documented
- Cumulus, SONiC, FRR, and Cisco Nexus are compared
- Ethernet and InfiniBand tradeoffs are explained at a practical level

---

## 12. Phase 7 — Automation and Validation

### Technical Focus

Phase 7 adds automation after the manual behavior is understood.

Focus areas:

- structured inventory
- data models
- Ansible
- Jinja2 templates
- generated FRR configs
- validation scripts
- pre-change checks
- post-change checks
- repeatable testing
- source-of-truth concepts
- CI-ready validation

Automation should encode understood behavior.  
It should not hide concepts that are not yet clear.

### Directories

```text
ansible/
scripts/
validation/
```

### Expected Artifacts

```text
ansible/
scripts/
validation/
```

Possible outputs:

```text
ansible/inventory.yml
ansible/templates/
ansible/playbooks/
scripts/
validation/
```

### Completion Criteria

This phase is complete when:

- selected configs can be generated from structured data
- validation checks can be run repeatedly
- command outputs can be collected or checked consistently
- automation is documented
- manual and automated workflows are clearly connected

---

## 13. Continuous Document — Lessons Learned

### Technical Focus

This document should collect lessons from all phases.

It should not be fully written at the beginning.

It should grow after each lab or major document is completed.

### Doc

```text
docs/07-lessons-learned.md
```

### Suggested Content

- what worked
- what failed
- what was misunderstood
- what was corrected
- useful commands
- design decisions
- lab limitations
- follow-up ideas

### Completion Criteria

This document is never really complete.

It should be updated gradually as the project progresses.

---

## 14. Dependency Rules

Use these dependency rules to avoid jumping ahead too early.

### Rule 1 — Validate the platform before building fabric

Do Phase 0 before Phase 1.

### Rule 2 — Build underlay before overlay

Do Phase 1 before Phase 3.

EVPN/VXLAN should not be implemented before the eBGP underlay is working.

### Rule 3 — Understand the fabric before studying lossless Ethernet deeply

Do basic leaf-spine and AI fabric requirements before deep RoCEv2/PFC/ECN/DCQCN notes.

### Rule 4 — Learn network OS differences after routing concepts are clear

Study SONiC and Cumulus after basic FRR routing and EVPN/VXLAN concepts are understood.

### Rule 5 — Automate after manual validation

Do not start automation before the manual lab behavior is understood and documented.

---

## 15. Recommended Reading / Building Order

Follow this order:

```text
1. labs/00-platform-validation/
2. labs/01-frr-leaf-spine/
3. docs/01-ai-fabric-overview.md
4. docs/02-ai-fabric-requirements.md
5. docs/04-evpn-vxlan-design.md
6. labs/02-evpn-vxlan/
7. docs/03-rocev2-lossless-ethernet.md
8. docs/06-monitoring-and-telemetry.md
9. labs/03-sonic-containerlab/
10. labs/04-nvidia-air-cumulus-notes/
11. docs/05-infiniband-vs-ethernet.md
12. ansible/
13. scripts/
14. validation/
15. docs/07-lessons-learned.md
```

`docs/07-lessons-learned.md` should be updated throughout the process, not only at the end.
