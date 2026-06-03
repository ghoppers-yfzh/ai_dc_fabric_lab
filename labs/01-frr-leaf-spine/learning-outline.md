# Phase 1 Learning Outline — FRR + Containerlab Leaf-Spine Fabric

## 1. Goal

Phase 1 builds the first real data center fabric lab in this repository.

The goal is to create a reproducible 2-spine / 4-leaf / 4-host leaf-spine fabric using Containerlab and FRRouting.

This phase is not a full AI GPU cluster simulation.

It does not test real:

- RoCEv2
- RDMA performance
- PFC
- ECN
- DCQCN
- GPU workload behavior

Those topics come later.

The purpose of this phase is to build the data center fabric foundation that later AI infrastructure topics depend on.

---

## 2. Why This Phase Matters

AI data center networking still depends on strong data center networking fundamentals.

Before discussing RoCEv2, GPU cluster traffic, lossless Ethernet, or NVIDIA Spectrum-X, the engineer should be comfortable with:

- leaf-spine / Clos topology
- eBGP underlay
- loopback reachability
- ECMP
- failure domains
- validation commands
- reproducible lab documentation

This phase connects directly to existing data center networking experience while preparing for AI/GPU infrastructure topics.

---

## 3. Target Topology

The intended Phase 1 topology is:

```text
          spine1          spine2
          /  |  \        /  |  \
         /   |   \      /   |   \
      leaf1 leaf2 leaf3 leaf4
        |     |     |     |
      host1 host2 host3 host4
```

Device roles:

| Role | Count | Purpose |
|---|---:|---|
| Spine | 2 | Fabric core / transit layer |
| Leaf | 4 | Server-facing fabric edge |
| Host | 4 | Linux test endpoints |

Main routing model:

- eBGP between every spine and every leaf
- loopbacks advertised through BGP
- ECMP across spines
- hosts connected to leaves for future overlay and reachability testing

---

## 4. Learning-to-Lab Mapping

| Module | Learning Topic | Lab Manual Stage | Main Artifact |
|---|---|---|---|
| Module 1 | Lab platform basics | Stage 0 — Platform validation | `labs/00-platform-validation/outputs/` |
| Module 2 | Leaf-spine / Clos foundation | Stage 1 — Topology design | `topology.clab.yml` |
| Module 3 | IP and ASN planning | Stage 2 — Addressing and ASN plan | `ip-plan.md`, `asn-plan.md` |
| Module 4 | FRRouting basics | Stage 3 — FRR basic checks | `outputs/frr-basic-checks.md` |
| Module 5 | One eBGP pair | Stage 4 — Configure `spine1 <-> leaf1` manually | `outputs/spine1-leaf1-bgp.md` |
| Module 6 | Full eBGP underlay | Stage 5 — Configure all spine-leaf BGP sessions | `configs/`, `outputs/bgp-summary-all.txt` |
| Module 7 | Loopback reachability and ECMP | Stage 6 — Route and ECMP validation | `outputs/loopback-ping-tests.txt`, `outputs/ecmp-checks.txt` |
| Module 8 | Failure testing | Stage 7 — Link/spine/leaf failure | `failure-tests.md`, `failure-tests/` |
| Module 9 | EVPN/VXLAN design | Stage 8 — Overlay design only | `evpn-vxlan-plan.md`, `docs/04-evpn-vxlan-design.md` |
| Module 10 | Automation readiness | Stage 9 — Automation after manual validation | Future `ansible/`, `scripts/`, `validation/` |

---

## 5. Module 1 — Lab Platform Basics

### What to Learn

- Containerlab topology files
- node kinds
- container images
- virtual links
- endpoint naming
- `clab-*` runtime directories
- `containerlab deploy`
- `containerlab inspect`
- `containerlab destroy`
- FRR container access
- `vtysh`

### Lab Work

Use the already completed Phase 0 labs:

```text
labs/00-platform-validation/alpine-smoke-test.clab.yml
labs/00-platform-validation/frr-smoke-test.clab.yml
```

### Expected Output

```text
labs/00-platform-validation/outputs/alpine-smoke-test.md
labs/00-platform-validation/outputs/frr-smoke-test.md
```

### What You Should Be Able to Explain

- Why Phase 0 exists before the real fabric lab.
- What Containerlab creates when a topology is deployed.
- What a `clab-*` runtime directory is.
- How to access an FRR container.
- Why `vtysh` is needed.

---

## 6. Module 2 — Leaf-Spine / Clos Foundation

### What to Learn

- why modern data centers use leaf-spine topology
- why every leaf connects to every spine
- why there are usually no direct leaf-to-leaf links
- why ECMP is important
- why east-west traffic matters
- why AI/GPU clusters care about predictable bandwidth

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
- Why each leaf should connect to both spines.
- How this design creates path redundancy.
- How this design prepares for ECMP.
- Why this foundation is relevant to AI data center fabrics.

---

## 7. Module 3 — IP and ASN Planning

### What to Learn

- loopback addressing
- point-to-point addressing
- `/31` links
- host-facing addressing
- private ASN usage
- per-device ASN design
- eBGP fabric design
- why BGP is common in data center fabrics

### Lab Work

Create:

```text
labs/01-frr-leaf-spine/ip-plan.md
labs/01-frr-leaf-spine/asn-plan.md
```

The IP plan should document:

- spine loopbacks
- leaf loopbacks
- point-to-point spine-leaf links
- host-facing links or subnets
- any lab-only addressing conventions

The ASN plan should document:

- spine ASNs
- leaf ASNs
- why the lab uses eBGP
- why the lab uses per-device or per-role ASNs

### Main Artifacts

```text
labs/01-frr-leaf-spine/ip-plan.md
labs/01-frr-leaf-spine/asn-plan.md
```

### What You Should Be Able to Explain

- Why loopbacks are useful in routing labs.
- Why `/31` is commonly used for point-to-point links.
- Why eBGP can be used inside a data center fabric.
- What tradeoff exists between per-device ASN and shared ASN designs.
- How the addressing plan maps to the topology.

---

## 8. Module 4 — FRRouting Basics

### What to Learn

- what FRRouting is
- what `zebra` does
- what `bgpd` does
- what `vtysh` does
- where FRR configuration lives
- difference between Linux routing table and BGP table
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
- Why an empty BGP summary is expected before BGP configuration.

---

## 9. Module 5 — One eBGP Pair

### What to Learn

- how a BGP neighbor is established
- what local ASN and remote ASN mean
- what neighbor IP means
- how connected interfaces are used for eBGP peering
- how to verify one BGP session before scaling out

### Lab Work

Manually configure only one BGP pair first:

```text
spine1 <-> leaf1
```

Do not configure the full fabric immediately.

### Main Output

```text
labs/01-frr-leaf-spine/outputs/spine1-leaf1-bgp.md
```

### What You Should Be Able to Explain

- Why starting with one BGP pair is safer.
- What must match on both sides for BGP to come up.
- How to identify whether a BGP session is established.
- How to troubleshoot a failed BGP session.
- Why manual configuration comes before automation.

---

## 10. Module 6 — Full eBGP Underlay

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
- How underlay reachability supports future overlays.
- What a healthy `show bgp summary` looks like.

---

## 11. Module 7 — Loopback Reachability and ECMP

### What to Learn

- how to prove routing reachability
- how to test loopback-to-loopback connectivity
- how to identify ECMP routes
- how multiple equal-cost paths appear in the routing table
- why ECMP matters for AI and data center fabrics

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
- Why predictable multipath behavior is important in AI/GPU fabrics.

---

## 12. Module 8 — Failure Testing

### What to Learn

- baseline vs failure-state validation
- link failure behavior
- spine failure behavior
- leaf failure behavior
- expected vs actual results
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

- What traffic or routes should survive a single spine-link failure.
- What should happen when one spine is down.
- What should happen when one leaf is down.
- Why failure testing is important for portfolio evidence.
- How this maps to production change validation.

---

## 13. Module 9 — EVPN/VXLAN Design Before Implementation

### What to Learn

- underlay vs overlay
- VTEP
- VNI
- L2 VNI
- L3 VNI
- EVPN control plane
- why overlays are used in modern data centers
- where EVPN/VXLAN fits relative to the eBGP underlay

### Lab Work

Write the design before implementation.

Do not implement EVPN/VXLAN in Phase 1 unless the underlay is already complete and documented.

### Main Outputs

```text
labs/01-frr-leaf-spine/evpn-vxlan-plan.md
docs/04-evpn-vxlan-design.md
```

### What You Should Be Able to Explain

- What problem EVPN/VXLAN solves.
- What the underlay provides.
- What the overlay provides.
- What a VTEP is.
- What a VNI is.
- Why EVPN/VXLAN should not be started before the underlay is validated.

---

## 14. Module 10 — Automation Readiness

### What to Learn

- inventory design
- structured data
- Jinja2 templates
- Ansible playbooks
- Python validation
- source-of-truth thinking
- CI-ready checks

### Rule

Do not automate before the manual underlay works.

Automation should come after understanding.

### Future Outputs

```text
ansible/
scripts/
validation/
```

### What You Should Be Able to Explain

- What data should be stored in inventory.
- What config should be generated from templates.
- What should be validated automatically.
- How automation supports production network operations.
- How this connects to NetDevOps and AI infrastructure roles.

---

## 15. Phase 1 Success Checklist

Use this checklist to decide whether Phase 1 is complete.

- [ ] Phase 0 platform validation is complete.
- [ ] Repo skeleton exists.
- [ ] `labs/01-frr-leaf-spine/README.md` exists and explains the lab.
- [ ] Phase 1 topology is documented.
- [ ] `topology.clab.yml` exists.
- [ ] IP plan is documented.
- [ ] ASN plan is documented.
- [ ] Containerlab can deploy the 2-spine / 4-leaf / 4-host topology.
- [ ] FRR nodes start correctly.
- [ ] FRR basic checks are saved.
- [ ] One BGP pair works.
- [ ] Full eBGP underlay works.
- [ ] Remote loopbacks are reachable.
- [ ] ECMP is visible.
- [ ] Failure tests are documented.
- [ ] Selected command outputs are saved.
- [ ] EVPN/VXLAN design is written before implementation.
- [ ] You can explain each config independently.

---

## 16. What Not to Do Yet

Do not move too fast into:

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

These are important, but they should come after the FRR leaf-spine foundation is clear and validated.

---

## 17. Immediate Next Step

The next practical step is to complete the Phase 1 lab manual:

```text
labs/01-frr-leaf-spine/README.md
```

Then complete:

```text
labs/01-frr-leaf-spine/topology.clab.yml
labs/01-frr-leaf-spine/ip-plan.md
labs/01-frr-leaf-spine/asn-plan.md
labs/01-frr-leaf-spine/validation.md
labs/01-frr-leaf-spine/failure-tests.md
```

Only after these files are clear should the full topology be deployed.
