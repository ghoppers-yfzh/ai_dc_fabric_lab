# FRR Leaf-Spine Lab

## 1. Goal

This lab builds a small reproducible data center leaf-spine fabric using Containerlab and FRRouting.

The goal is to build and validate a clean routed eBGP underlay before moving to EVPN/VXLAN, RoCEv2, SONiC, or NVIDIA/Cumulus topics.

Target topology:

```text
          spine1          spine2
          /  |  \        /  |  \
         /   |   \      /   |   \
      leaf1 leaf2 leaf3 leaf4
        |     |     |     |
      host1 host2 host3 host4
```

## 2. Status

Status: completed baseline lab.

Completed scope:

- 2 spine switches
- 4 leaf switches
- 4 Linux hosts
- point-to-point spine-leaf links
- loopback addressing
- private ASN planning
- eBGP underlay
- BGP neighbor validation
- loopback route advertisement
- ECMP verification
- basic failure testing
- L3 host-to-host reachability
- validation outputs saved under `outputs/`

This lab does not implement EVPN/VXLAN yet.

This lab does not simulate RoCEv2, PFC, ECN, DCQCN, or GPU traffic.

## 3. What This Lab Teaches

This lab focuses on:

- leaf-spine / Clos fabric structure
- routed underlay design
- point-to-point `/31` addressing
- loopback addressing
- private ASN allocation
- FRR basic operation
- eBGP underlay behavior
- route advertisement and validation
- ECMP behavior
- host attachment to a routed fabric
- basic failure testing
- saving validation evidence for a portfolio repo

## 4. File Map

```text
labs/01-frr-leaf-spine/
├── README.md
├── learning-outline.md
├── topology.clab.yml
├── ip-asn-plan.md
├── validation.md
├── failure-tests.md
├── configs/
├── outputs/
└── failure-tests/
```

File roles:

| File | Purpose |
|---|---|
| `README.md` | Main lab manual |
| `learning-outline.md` | Learning map for this phase |
| `topology.clab.yml` | Containerlab topology |
| `ip-asn-plan.md` | Loopback, point-to-point, host-facing, and ASN plan |
| `validation.md` | Validation checklist and command guide |
| `failure-tests.md` | Failure test plan and notes |
| `configs/` | FRR configuration files |
| `outputs/` | Saved validation command outputs |
| `failure-tests/` | Saved outputs from failure scenarios |

## 5. Topology Summary

Nodes:

| Node | Role | Image |
|---|---|---|
| `spine1` | spine switch | `frrouting/frr:latest` |
| `spine2` | spine switch | `frrouting/frr:latest` |
| `leaf1` | leaf switch | `frrouting/frr:latest` |
| `leaf2` | leaf switch | `frrouting/frr:latest` |
| `leaf3` | leaf switch | `frrouting/frr:latest` |
| `leaf4` | leaf switch | `frrouting/frr:latest` |
| `host1` | Linux host | Linux container |
| `host2` | Linux host | Linux container |
| `host3` | Linux host | Linux container |
| `host4` | Linux host | Linux container |

Spine-leaf links:

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

Host links:

```text
leaf1 <-> host1
leaf2 <-> host2
leaf3 <-> host3
leaf4 <-> host4
```

## 6. Addressing and ASN Plan

The detailed addressing and ASN plan is documented in:

```text
ip-asn-plan.md
```

Summary:

- loopbacks use `10.255.0.0/24` and `10.255.1.0/24`
- spine-leaf point-to-point links use `10.0.0.0/24` carved into `/31`s
- host-facing links use `192.168.1.0/24` through `192.168.4.0/24`
- spines use ASN `65000`
- leaves use ASNs `65101` through `65104`

## 7. Deploy the Lab

From the repo root:

```bash
sudo containerlab deploy -t labs/01-frr-leaf-spine/topology.clab.yml
```

Or from this lab directory:

```bash
sudo containerlab deploy -t topology.clab.yml
```

Inspect the lab:

```bash
sudo containerlab inspect -t topology.clab.yml
```

## 8. Validation Summary

The full validation workflow is documented in:

```text
validation.md
```

Completed validation areas:

- deploy validation
- FRR basic checks
- interface validation
- IP address validation
- one BGP pair validation
- full BGP underlay validation
- route validation
- loopback reachability tests
- ECMP validation
- host-to-host reachability validation
- cleanup validation

Saved outputs are stored under:

```text
outputs/
```

Markdown output files are preferred where practical.

Expected output examples:

```text
outputs/containerlab-inspect-initial.md
outputs/frr-basic-checks.md
outputs/spine1-leaf1-bgp.md
outputs/bgp-summary-all.md
outputs/loopback-ping-tests.md
outputs/ecmp-checks.md
outputs/host-reachability.md
```

## 9. Failure Testing

Failure testing is documented in:

```text
failure-tests.md
```

Saved failure-test evidence should be stored under:

```text
failure-tests/
```

This lab uses practical failure scenarios such as interface shutdown or controlled node failure. For Containerlab-managed links, interface shutdown is usually cleaner than stopping and restarting a container directly.

## 10. Cleanup

Destroy the lab:

```bash
sudo containerlab destroy -t topology.clab.yml
```

If needed, destroy and clean runtime files:

```bash
sudo containerlab destroy -t topology.clab.yml --cleanup
```

## 11. Completion Criteria

This lab is complete when:

- the topology can deploy successfully
- all FRR nodes are reachable
- all Linux hosts are reachable
- one BGP pair works
- all spine-leaf eBGP sessions work
- loopbacks are advertised and reachable
- ECMP is visible
- attached host subnets are advertised into the underlay
- host-to-host L3 reachability works across the routed fabric
- failure tests are documented
- important command outputs are saved under `outputs/`

## 12. Next Step

This lab is the routed underlay foundation.

The next step is to create:

```text
docs/01-evpn-vxlan-design.md
```

After that, create a separate overlay lab:

```text
labs/02-evpn-vxlan/
```

Do not add EVPN/VXLAN into this lab directly. Keep this lab as a clean routed underlay baseline.
