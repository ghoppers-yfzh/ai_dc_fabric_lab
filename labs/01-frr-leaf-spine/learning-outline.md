# Phase 1 Learning Outline — FRR + Containerlab Leaf-Spine Fabric

## 1. Goal

Phase 1 builds the first real data center fabric lab in this repository.

The goal is to create a reproducible 2-spine / 4-leaf / 4-host leaf-spine fabric using Containerlab and FRRouting.

This phase focuses on the eBGP underlay foundation:

- topology design
- IP addressing
- ASN planning
- FRR basics
- one eBGP pair
- full spine-leaf eBGP underlay
- loopback reachability
- ECMP validation
- basic failure testing

This phase does not implement EVPN/VXLAN yet.

This phase does not test real:

- RoCEv2
- RDMA performance
- PFC
- ECN
- DCQCN
- GPU workload behavior

Those topics come after the underlay foundation is working and documented.

---

## 2. Why This Phase Matters

A reliable data center fabric starts with a clean underlay.

Before studying AI/GPU-specific networking topics, the basic fabric should be easy to build, explain, validate, and troubleshoot.

This phase builds the foundation for later topics such as:

- EVPN/VXLAN overlays
- AI fabric requirements
- RoCEv2 and lossless Ethernet concepts
- SONiC
- Cumulus Linux
- automation and validation workflows

The important idea is:

```text
Stable underlay first, advanced fabric topics later.
```

---

## 3. Target Topology

The intended Phase 1 topology is:

```text
          spine1          spine2
          / | | \\        / | | \\
         /  | |  \\      /  | |  \\
      leaf1 leaf2 leaf3 leaf4
        |     |     |     |
      host1 host2 host3 host4
```

Device roles:

| Role | Count | Purpose |
|---|---:|---|
| Spine | 2 | Fabric transit layer |
| Leaf | 4 | Server-facing fabric edge |
| Host | 4 | Linux test endpoints |

Main routing model:

- eBGP between every spine and every leaf
- loopbacks advertised through BGP
- ECMP across both spines
- hosts connected to leaves for later reachability and overlay testing

Expected spine-leaf BGP sessions:

```text
spine1 <-> leaf1
spine1 <-> leaf2
spine1 <-> leaf3
spine1 <-> leaf4

spine2 <-> leaf1
spine2 <-> leaf2
spine2 <-> leaf3
spine2 <-> leaf4
```

Expected total:

```text
8 spine-leaf eBGP sessions
```

---

## 4. File Roles in This Lab

This file explains what Phase 1 is meant to teach.

The main lab instructions live in `README.md`.

| File | Role |
|---|---|
| `README.md` | Main lab manual |
| `learning-outline.md` | Learning goals and concept-to-lab mapping |
| `topology.clab.yml` | Containerlab topology |
| `ip-plan.md` | Interface, loopback, P2P, and host-facing IP plan |
| `asn-plan.md` | BGP ASN design |
| `validation.md` | Validation command guide |
| `failure-tests.md` | Failure testing plan |
| `configs/` | Saved or generated FRR configs |
| `outputs/` | Saved validation outputs |
| `failure-tests/` | Saved failure test outputs |

Use this file to understand the learning path.

Use `README.md` to perform the lab.

Use `validation.md` and `failure-tests.md` when saving proof that the lab works.

---

## 5. Learning-to-Lab Mapping

| Module | Learning Topic | Lab Stage | Main Artifact |
|---|---|---|---|
| Module 1 | Platform validation recap | Previous phase | `labs/00-platform-validation/outputs/` |
| Module 2 | Leaf-spine / Clos foundation | Topology design | `topology.clab.yml` |
| Module 3 | IP and ASN planning | Addressing and ASN design | `ip-plan.md`, `asn-plan.md` |
| Module 4 | FRRouting basics | FRR basic checks | `outputs/frr-basic-checks.md` |
| Module 5 | One eBGP pair | Configure `spine1 <-> leaf1` manually | `outputs/spine1-leaf1-bgp.md` |
| Module 6 | Full eBGP underlay | Configure all spine-leaf sessions | `configs/`, `outputs/bgp-summary-all.txt` |
| Module 7 | Loopback reachability and ECMP | Route and ECMP validation | `outputs/loopback-ping-tests.txt`, `outputs/ecmp-checks.txt` |
| Module 8 | Failure testing | Link, spine, and leaf failure tests | `failure-tests.md`, `failure-tests/` |

---

## 6. Module 1 — Platform Validation Recap

### What Was Learned

The previous platform validation phase proved that the lab host can run:

- Docker
- Containerlab
- Alpine containers
- FRR containers
- virtual links
- basic container-to-container connectivity
- `vtysh` inside FRR containers

### Previous Artifacts

```text
labs/00-platform-validation/outputs/alpine-smoke-test.md
labs/00-platform-validation/outputs/frr-smoke-test.md
```

### Why It Matters for Phase 1

Phase 1 assumes the lab platform is already working.

If Phase 1 deployment fails, the first troubleshooting question should be whether the basic Containerlab and FRR behavior still works.

---

## 7. Module 2 — Leaf-Spine / Clos Foundation

### What to Learn

- why modern data centers use leaf-spine topology
- why every leaf connects to every spine
- why there are usually no direct leaf-to-leaf links
- why ECMP is important
- why east-west traffic matters
- why predictable bandwidth matters in modern data center fabrics

### Lab Work

Create and review:

```text
labs/01-frr-leaf-spine/topology.clab.yml
```

The topology should model:

- 2 spines
- 4 leaves
- 4 hosts
- spine-to-leaf links
- host-to-leaf links

### Main Artifact

```text
labs/01-frr-leaf-spine/topology.clab.yml
```

### What You Should Be Able to Explain

- What role the spine layer plays.
- What role the leaf layer plays.
- Why each leaf connects to both spines.
- Why leaf-to-leaf traffic goes through the spine layer.
- How this design creates path redundancy.
- How this design prepares for ECMP.

---

## 8. Module 3 — IP and ASN Planning

### What to Learn

- loopback addressing
- point-to-point addressing
- `/31` links
- host-facing addressing
- private ASN usage
- eBGP fabric design
- shared spine ASN vs per-device ASN design
- why BGP is commonly used in data center fabrics

### Lab Work

Create and maintain:

```text
labs/01-frr-leaf-spine/ip-plan.md
labs/01-frr-leaf-spine/asn-plan.md
```

The IP plan should document:

- spine loopbacks
- leaf loopbacks
- point-to-point spine-leaf links
- host-facing links
- interface naming

The ASN plan should document:

- spine ASN design
- leaf ASN design
- expected BGP sessions
- route advertisement plan

### Main Artifacts

```text
labs/01-frr-leaf-spine/ip-plan.md
labs/01-frr-leaf-spine/asn-plan.md
```

### What You Should Be Able to Explain

- Why loopbacks are useful in routing labs.
- Why `/31` is commonly used for point-to-point links.
- Why eBGP can be used inside a data center fabric.
- Why the lab starts with a simple ASN design.
- How the addressing plan maps to the topology.

---

## 9. Module 4 — FRRouting Basics

### What to Learn

- what FRRouting is
- what `zebra` does
- what `bgpd` does
- what `vtysh` does
- where FRR configuration is stored
- difference between the Linux routing table and the BGP table
- basic FRR verification commands

### Lab Work

After deploying the topology, access FRR nodes and run basic checks:

```text
show version
show running-config
show ip route
show bgp summary
```

### Main Output

```text
labs/01-frr-leaf-spine/outputs/frr-basic-checks.md
```

### What You Should Be Able to Explain

- Which FRR daemons are required for this lab.
- Why `zebra` and `bgpd` are both needed.
- What `show ip route` proves.
- What `show bgp summary` proves.
- Why BGP summary may be empty before BGP is configured.

---

## 10. Module 5 — One eBGP Pair

### What to Learn

- how a BGP neighbor is established
- what local ASN and remote ASN mean
- what neighbor IP means
- how directly connected interfaces are used for eBGP peering
- how to verify one BGP session before scaling out
- how to troubleshoot a failed BGP session

### Lab Work

Manually configure only one BGP pair first:

```text
spine1 <-> leaf1
```

Do not configure the full fabric until the first pair is understood and verified.

### Main Output

```text
labs/01-frr-leaf-spine/outputs/spine1-leaf1-bgp.md
```

### What You Should Be Able to Explain

- Why starting with one BGP pair is safer.
- What must match on both sides for BGP to come up.
- How to identify whether a BGP session is established.
- How to check the learned routes.
- What to check if the BGP session does not establish.

---

## 11. Module 6 — Full eBGP Underlay

### What to Learn

- how to scale one BGP session to the full fabric
- how every leaf peers with every spine
- how to advertise loopbacks
- how to verify all BGP sessions
- how to separate underlay routing from future overlay routing

### Lab Work

Configure all spine-leaf eBGP sessions.

Expected peerings:

```text
spine1 <-> leaf1
spine1 <-> leaf2
spine1 <-> leaf3
spine1 <-> leaf4

spine2 <-> leaf1
spine2 <-> leaf2
spine2 <-> leaf3
spine2 <-> leaf4
```

### Main Outputs

```text
labs/01-frr-leaf-spine/configs/
labs/01-frr-leaf-spine/outputs/bgp-summary-all.txt
```

### What You Should Be Able to Explain

- How many BGP sessions should exist.
- Why each leaf peers with both spines.
- How loopback routes are advertised.
- How underlay reachability supports future overlay work.
- What a healthy `show bgp summary` looks like.

---

## 12. Module 7 — Loopback Reachability and ECMP

### What to Learn

- how to prove routing reachability
- how to test loopback-to-loopback connectivity
- how to identify ECMP routes
- how multiple equal-cost paths appear in the routing table
- why ECMP matters in data center fabrics

### Lab Work

Validate that remote loopbacks are reachable.

Check routing tables for equal-cost paths.

### Main Outputs

```text
labs/01-frr-leaf-spine/outputs/loopback-ping-tests.txt
labs/01-frr-leaf-spine/outputs/ecmp-checks.txt
```

### What You Should Be Able to Explain

- Why loopback reachability is a good underlay validation test.
- How to confirm that ECMP exists.
- Why ECMP improves bandwidth and redundancy.
- What should happen to ECMP when one path fails.

---

## 13. Module 8 — Failure Testing

### What to Learn

- baseline vs failure-state validation
- link failure behavior
- spine failure behavior
- leaf failure behavior
- expected vs actual results
- recovery validation
- how to document operational behavior

### Lab Work

Test at least:

1. one spine-leaf link failure
2. one spine failure
3. one leaf failure

For each test, record:

- baseline state
- failure action
- expected result
- actual result
- recovery action
- recovery validation

### Main Outputs

```text
labs/01-frr-leaf-spine/failure-tests.md
labs/01-frr-leaf-spine/failure-tests/
```

### What You Should Be Able to Explain

- What routes should survive a single spine-link failure.
- What should happen when one spine is down.
- What should happen when one leaf is down.
- How BGP routes are withdrawn and restored.
- Why failure testing is important for operational validation.

---

## 14. Later Topics Prepared by This Lab

Phase 1 does not implement these topics, but it prepares for them.

### EVPN/VXLAN

The Phase 1 underlay prepares for:

- underlay vs overlay
- VTEP reachability
- VNI design
- BGP EVPN control plane
- host-to-host overlay reachability

These topics are handled in later EVPN/VXLAN work.

### RoCEv2 and Lossless Ethernet

The Phase 1 fabric concepts prepare for:

- predictable paths
- congestion awareness
- packet loss sensitivity
- telemetry requirements
- failure domain thinking

These topics are handled in later RoCEv2 and lossless Ethernet notes.

### SONiC and Cumulus

The Phase 1 FRR lab prepares for later network operating system comparisons.

The routing concepts should be understood before comparing FRR-only labs with SONiC or Cumulus behavior.

### Automation

The Phase 1 manual configuration and validation prepare for later automation.

Automation should be added after the manual behavior is understood.

---

## 15. Phase 1 Success Checklist

Use this checklist to decide whether Phase 1 is complete.

- [ ] Phase 0 platform validation is complete.
- [ ] `labs/01-frr-leaf-spine/README.md` explains the lab clearly.
- [ ] `topology.clab.yml` exists and deploys successfully.
- [ ] IP plan is documented.
- [ ] ASN plan is documented.
- [ ] FRR nodes start correctly.
- [ ] FRR basic checks are saved.
- [ ] One BGP pair works.
- [ ] Full eBGP underlay works.
- [ ] Remote loopbacks are reachable.
- [ ] ECMP is visible.
- [ ] Failure tests are documented.
- [ ] Selected command outputs are saved.
- [ ] You can explain the underlay design and validation results independently.

---

## 16. What Not to Do Yet

Do not move too fast into:

- EVPN/VXLAN implementation
- RoCEv2
- PFC
- ECN
- DCQCN
- SONiC
- NVIDIA Air
- Cumulus Linux
- full automation
- CI pipelines
- NetBox integration

These are important, but they should come after the FRR leaf-spine underlay is working and documented.

---

## 17. How to Use This File

Read this file before starting or continuing the Phase 1 lab.

Use it to understand:

- what the lab is trying to teach
- which file belongs to which learning step
- what should be completed before moving to later topics

During the lab:

```text
README.md           = main lab manual
ip-plan.md          = addressing reference
asn-plan.md         = BGP ASN reference
validation.md       = validation commands
failure-tests.md    = failure testing guide
outputs/            = saved validation results
failure-tests/      = saved failure test results
```

This file should not need frequent updates.

Update it only if the learning scope of Phase 1 changes.
