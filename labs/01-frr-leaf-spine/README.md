# FRR Leaf-Spine Lab

## 1. Goal

This lab builds a small reproducible data center leaf-spine fabric using Containerlab and FRRouting.

The goal is to build and validate a clean eBGP underlay before moving to EVPN/VXLAN, RoCEv2, SONiC, or NVIDIA/Cumulus topics.

Target topology:

```text
          spine1          spine2
          /  |  \        /  |  \
         /   |   \      /   |   \
      leaf1 leaf2 leaf3 leaf4
        |     |     |     |
      host1 host2 host3 host4
```

## 2. What This Lab Teaches

This lab focuses on:

- leaf-spine / Clos fabric structure
- point-to-point spine-leaf links
- loopback addressing
- private ASN planning
- eBGP underlay
- FRR basic operation
- BGP neighbor validation
- loopback route advertisement
- ECMP verification
- basic failure testing

This lab does not implement EVPN/VXLAN yet.  
This lab does not simulate RoCEv2, PFC, ECN, DCQCN, or GPU traffic.

## 3. File Map

```text
labs/01-frr-leaf-spine/
├── README.md
├── learning-outline.md
├── topology.clab.yml
├── ip-plan.md
├── asn-plan.md
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
| `ip-plan.md` | Loopback, P2P, and host-facing addressing |
| `asn-plan.md` | BGP ASN design |
| `validation.md` | Validation checklist and command guide |
| `failure-tests.md` | Failure test plan |
| `configs/` | FRR configs, added after manual validation |
| `outputs/` | Saved command outputs |
| `failure-tests/` | Saved outputs from failure scenarios |

## 4. Topology Summary

Nodes:

| Node | Role | Image |
|---|---|---|
| `spine1` | spine switch | `frrouting/frr:latest` |
| `spine2` | spine switch | `frrouting/frr:latest` |
| `leaf1` | leaf switch | `frrouting/frr:latest` |
| `leaf2` | leaf switch | `frrouting/frr:latest` |
| `leaf3` | leaf switch | `frrouting/frr:latest` |
| `leaf4` | leaf switch | `frrouting/frr:latest` |
| `host1` | Linux host | `alpine:latest` |
| `host2` | Linux host | `alpine:latest` |
| `host3` | Linux host | `alpine:latest` |
| `host4` | Linux host | `alpine:latest` |

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

## 5. Stage Plan

### Stage 1 — Review the Topology

Review:

```text
topology.clab.yml
ip-plan.md
asn-plan.md
```

Confirm:

- every leaf connects to both spines
- every leaf has one host
- interface numbering matches the IP plan
- ASN plan matches the intended BGP design

### Stage 2 — Deploy the Topology

From the repo root:

```bash
sudo containerlab deploy -t labs/01-frr-leaf-spine/topology.clab.yml
```

Save the initial inspect output:

```bash
sudo containerlab inspect -t labs/01-frr-leaf-spine/topology.clab.yml | tee labs/01-frr-leaf-spine/outputs/containerlab-inspect-initial.txt
```

### Stage 3 — Basic Node Checks

Check containers:

```bash
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
```

Check FRR access:

```bash
docker exec -it clab-frr-leaf-spine-spine1 vtysh
```

Inside `vtysh`:

```text
show version
show running-config
show ip route
show bgp summary
```

Save basic outputs under:

```text
labs/01-frr-leaf-spine/outputs/frr-basic-checks.md
```

### Stage 4 — Configure One BGP Pair First

Start with one session only:

```text
spine1 <-> leaf1
```

Do not configure the full fabric until this first session is understood and verified.

Save output to:

```text
labs/01-frr-leaf-spine/outputs/spine1-leaf1-bgp.md
```

### Stage 5 — Configure Full eBGP Underlay

After one BGP pair works, configure all spine-leaf eBGP sessions.

Expected total sessions:

```text
8 spine-leaf BGP sessions
```

Save output to:

```text
labs/01-frr-leaf-spine/outputs/bgp-summary-all.txt
```

### Stage 6 — Validate Loopback Reachability

Advertise loopbacks through BGP.

Validate remote loopback reachability from leaves and spines.

Save output to:

```text
labs/01-frr-leaf-spine/outputs/loopback-ping-tests.txt
```

### Stage 7 — Validate ECMP

Check whether routes to remote loopbacks have multiple equal-cost paths.

Save output to:

```text
labs/01-frr-leaf-spine/outputs/ecmp-checks.txt
```

### Stage 8 — Failure Testing

Run at least:

- one spine-leaf link failure
- one spine container failure
- one leaf container failure

Save test outputs under:

```text
labs/01-frr-leaf-spine/failure-tests/
```

Document results in:

```text
labs/01-frr-leaf-spine/failure-tests.md
```

## 6. Cleanup

Destroy the lab:

```bash
sudo containerlab destroy -t labs/01-frr-leaf-spine/topology.clab.yml
```

If needed, destroy and clean runtime files:

```bash
sudo containerlab destroy -t labs/01-frr-leaf-spine/topology.clab.yml --cleanup
```

## 7. Completion Criteria

This lab is complete when:

- the topology can deploy successfully
- all FRR nodes are reachable
- one BGP pair works
- all spine-leaf eBGP sessions work
- loopbacks are advertised and reachable
- ECMP is visible
- failure tests are documented
- important command outputs are saved under `outputs/`
