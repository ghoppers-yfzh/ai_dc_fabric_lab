# Validation Guide — FRR Leaf-Spine Lab

## 1. Purpose

This file defines the validation workflow for the FRR leaf-spine lab.

The goal is to save evidence that the lab works, not only to run commands interactively.

Save important outputs under:

```text
labs/01-frr-leaf-spine/outputs/
```

## 2. Deploy Validation

From the repo root:

```bash
sudo containerlab deploy -t labs/01-frr-leaf-spine/topology.clab.yml
```

Save inspect output:

```bash
sudo containerlab inspect -t labs/01-frr-leaf-spine/topology.clab.yml | tee labs/01-frr-leaf-spine/outputs/containerlab-inspect-initial.txt
```

Check containers:

```bash
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
```

Expected result:

- all spines are running
- all leaves are running
- all hosts are running

## 3. FRR Basic Checks

Check access to one FRR node:

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

Before BGP is configured, it is normal for `show bgp summary` to show no useful sessions.

Suggested output file:

```text
labs/01-frr-leaf-spine/outputs/frr-basic-checks.md
```

## 4. Interface Validation

Check Linux interfaces on a node:

```bash
docker exec clab-frr-leaf-spine-spine1 ip -br link
docker exec clab-frr-leaf-spine-leaf1 ip -br link
```

Expected result:

- `eth1` to `eth4` exist on spines
- `eth1` to `eth3` exist on leaves
- `eth1` exists on hosts

## 5. IP Address Validation

After IPs are configured, check:

```bash
docker exec clab-frr-leaf-spine-spine1 ip -br addr
docker exec clab-frr-leaf-spine-spine2 ip -br addr
docker exec clab-frr-leaf-spine-leaf1 ip -br addr
```

Expected result:

- loopback addresses exist
- point-to-point interface addresses match `ip-plan.md`
- host-facing addresses match `ip-plan.md`

## 6. One BGP Pair Validation

First validate only:

```text
spine1 <-> leaf1
```

Useful commands:

```bash
docker exec clab-frr-leaf-spine-spine1 vtysh -c "show bgp summary"
docker exec clab-frr-leaf-spine-leaf1 vtysh -c "show bgp summary"
```

Expected result:

- BGP state is `Established`
- prefix counters are visible after routes are advertised

Suggested output file:

```text
labs/01-frr-leaf-spine/outputs/spine1-leaf1-bgp.md
```

## 7. Full BGP Underlay Validation

After all spine-leaf sessions are configured:

```bash
for node in spine1 spine2 leaf1 leaf2 leaf3 leaf4; do
  echo "===== $node ====="
  docker exec clab-frr-leaf-spine-$node vtysh -c "show bgp summary"
done | tee labs/01-frr-leaf-spine/outputs/bgp-summary-all.txt
```

Expected result:

- each spine has 4 BGP neighbors
- each leaf has 2 BGP neighbors
- all BGP sessions are established

Expected session count:

```text
spine1 = 4
spine2 = 4
leaf1  = 2
leaf2  = 2
leaf3  = 2
leaf4  = 2
```

## 8. Route Validation

Check BGP routes:

```bash
docker exec clab-frr-leaf-spine-leaf1 vtysh -c "show bgp ipv4 unicast"
docker exec clab-frr-leaf-spine-leaf1 vtysh -c "show ip route bgp"
```

Expected result:

- leaf loopbacks are visible
- spine loopbacks are visible
- remote routes are learned through BGP

## 9. Loopback Reachability Tests

Example tests from `leaf1`:

```bash
docker exec clab-frr-leaf-spine-leaf1 ping -c 3 10.255.0.1
docker exec clab-frr-leaf-spine-leaf1 ping -c 3 10.255.0.2
docker exec clab-frr-leaf-spine-leaf1 ping -c 3 10.255.1.2
docker exec clab-frr-leaf-spine-leaf1 ping -c 3 10.255.1.3
docker exec clab-frr-leaf-spine-leaf1 ping -c 3 10.255.1.4
```

Save output:

```bash
{
  echo "===== leaf1 loopback ping tests ====="
  docker exec clab-frr-leaf-spine-leaf1 ping -c 3 10.255.0.1
  docker exec clab-frr-leaf-spine-leaf1 ping -c 3 10.255.0.2
  docker exec clab-frr-leaf-spine-leaf1 ping -c 3 10.255.1.2
  docker exec clab-frr-leaf-spine-leaf1 ping -c 3 10.255.1.3
  docker exec clab-frr-leaf-spine-leaf1 ping -c 3 10.255.1.4
} | tee labs/01-frr-leaf-spine/outputs/loopback-ping-tests.txt
```

## 10. ECMP Validation

Check routes to a remote leaf loopback:

```bash
docker exec clab-frr-leaf-spine-leaf1 vtysh -c "show ip route 10.255.1.2"
docker exec clab-frr-leaf-spine-leaf1 vtysh -c "show ip route bgp"
```

Expected result:

- remote leaf loopbacks should have multiple next hops when ECMP is working
- both spines should be usable paths for remote leaf routes

Save output:

```bash
{
  echo "===== leaf1 route to leaf2 loopback ====="
  docker exec clab-frr-leaf-spine-leaf1 vtysh -c "show ip route 10.255.1.2"
  echo
  echo "===== leaf1 BGP routes ====="
  docker exec clab-frr-leaf-spine-leaf1 vtysh -c "show ip route bgp"
} | tee labs/01-frr-leaf-spine/outputs/ecmp-checks.txt
```

## 11. Cleanup Validation

Destroy the lab:

```bash
sudo containerlab destroy -t labs/01-frr-leaf-spine/topology.clab.yml
```

Optional cleanup:

```bash
sudo containerlab destroy -t labs/01-frr-leaf-spine/topology.clab.yml --cleanup
```

## 12. Validation Output Checklist

Expected output files:

```text
outputs/containerlab-inspect-initial.txt
outputs/frr-basic-checks.md
outputs/spine1-leaf1-bgp.md
outputs/bgp-summary-all.txt
outputs/loopback-ping-tests.txt
outputs/ecmp-checks.txt
```
