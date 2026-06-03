# Phase 1 Learning Outline — FRR + Containerlab Leaf-Spine Fabric

## 1. Goal

Phase 1 builds a reproducible data center fabric foundation using Containerlab and FRRouting.

Phase 1 is not a full AI GPU cluster simulation. It does not test real RoCEv2, PFC, ECN, DCQCN, or GPU workload performance. Those topics come later.

## 2. Learning-to-lab mapping

| Module | Learning topic | Lab manual stage | Main artifact |
|---|---|---|---|
| Module 1 | Lab platform basics | Stage 0 — Platform validation | `labs/00-platform-validation/outputs/` |
| Module 2 | Leaf-spine / Clos foundation | Stage 1 — Topology design | `labs/01-frr-leaf-spine/README.md` |
| Module 3 | IP and ASN planning | Stage 2 — Addressing and ASN plan | `ip-plan.md`, `asn-plan.md` |
| Module 4 | FRRouting basics | Stage 3 — FRR basic checks | `outputs/frr-basic-checks.md` |
| Module 5 | eBGP underlay | Stage 4/5 — One-pair and full underlay | `configs/`, `outputs/bgp-summary-all.txt` |
| Module 6 | Loopback reachability and ECMP | Stage 6 — Route and ECMP validation | `outputs/loopback-ping-tests.txt`, `outputs/ecmp-checks.txt` |
| Module 7 | Failure testing | Stage 7 — Link/spine/leaf failure | `failure-tests.md`, `outputs/failure-tests/` |
| Module 8 | EVPN/VXLAN design | Stage 8 — Overlay design only | `evpn-vxlan-plan.md`, `docs/04-evpn-vxlan-design.md` |
| Module 9 | Automation readiness | Stage 9 — Automation after manual validation | `ansible/`, `scripts/`, `validation/` |

## 3. Module details

### Module 1 — Lab platform basics

Learn Containerlab lifecycle, topology files, node kinds, container images, links, endpoints, and generated `clab-*` runtime directories.

Lab: run `labs/00-platform-validation/`.

### Module 2 — Leaf-spine / Clos foundation

Learn why every leaf connects to every spine, why ECMP matters, and why AI/GPU clusters care about east-west bandwidth.

Lab: create and review `topology.clab.yml`.

### Module 3 — IP and ASN planning

Learn loopbacks, `/31` P2P links, private ASNs, and per-device ASN eBGP fabric design.

Lab: create `ip-plan.md` and `asn-plan.md`.

### Module 4 — FRRouting basics

Learn `zebra`, `bgpd`, `vtysh`, `frr.conf`, `daemons`, Linux route table vs BGP table.

Lab: run `show version`, `show running-config`, `show ip route`, and `show bgp summary`.

### Module 5 — eBGP underlay

Learn how spine-leaf eBGP sessions are established and how loopback routes are advertised.

Lab: configure `spine1 <-> leaf1` first, then expand.

### Module 6 — Loopback reachability and ECMP

Learn how to prove reachability and path diversity.

Lab: ping remote loopbacks and check BGP routes.

### Module 7 — Failure testing

Learn baseline vs failure-state output and expected vs actual behavior.

Lab: test one link failure, one spine failure, and one leaf failure.

### Module 8 — EVPN/VXLAN design before implementation

Learn underlay vs overlay, VTEP, VNI, L2 VNI, and L3 VNI.

Lab: write the EVPN/VXLAN design before implementation.

### Module 9 — Automation readiness

Learn inventory, data model, templates, playbooks, validation scripts, and source-of-truth thinking.

Rule: automate only after the manual underlay works.

## 4. Phase 1 success checklist

- [ ] Platform validation passed.
- [ ] Repo skeleton exists.
- [ ] Phase 1 topology is documented.
- [ ] IP plan is documented.
- [ ] ASN plan is documented.
- [ ] Containerlab can deploy the 2-spine / 4-leaf / 4-host topology.
- [ ] FRR nodes start correctly.
- [ ] One BGP pair works.
- [ ] Full eBGP underlay works.
- [ ] Remote loopbacks are reachable.
- [ ] ECMP is visible.
- [ ] Failure tests are documented.
- [ ] Selected outputs are saved.
- [ ] You can explain each config without relying on Codex.
