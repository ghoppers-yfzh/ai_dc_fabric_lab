# Failure Tests — FRR Leaf-Spine Lab

## 1. Purpose

This file defines the basic failure tests for the FRR leaf-spine lab.

Failure testing should compare:

```text
baseline state -> failure action -> observed result -> recovery action -> recovered state
```

Save raw command outputs under:

```text
labs/01-frr-leaf-spine/failure-tests/
```

## 2. Baseline Capture

Before any failure test, capture baseline state.

```bash
mkdir -p labs/01-frr-leaf-spine/failure-tests

{
  echo "===== BGP summary before failure ====="
  for node in spine1 spine2 leaf1 leaf2 leaf3 leaf4; do
    echo
    echo "===== $node ====="
    docker exec clab-frr-leaf-spine-$node vtysh -c "show bgp summary"
  done

  echo
  echo "===== leaf1 BGP routes before failure ====="
  docker exec clab-frr-leaf-spine-leaf1 vtysh -c "show ip route bgp"
} | tee labs/01-frr-leaf-spine/failure-tests/00-baseline.txt
```

## 3. Test 1 — Single Spine-Leaf Link Failure

### Failure Scenario

Bring down the link from `leaf1` to `spine1`.

Based on the interface plan:

```text
leaf1 eth1 <-> spine1 eth1
```

### Failure Action

```bash
docker exec clab-frr-leaf-spine-leaf1 ip link set eth1 down
```

### Validation

```bash
{
  echo "===== leaf1 link failure: eth1 down ====="
  docker exec clab-frr-leaf-spine-leaf1 ip -br link
  echo
  echo "===== leaf1 BGP summary ====="
  docker exec clab-frr-leaf-spine-leaf1 vtysh -c "show bgp summary"
  echo
  echo "===== leaf1 BGP routes ====="
  docker exec clab-frr-leaf-spine-leaf1 vtysh -c "show ip route bgp"
} | tee labs/01-frr-leaf-spine/failure-tests/01-leaf1-spine1-link-down.txt
```

### Expected Result

- BGP session between `leaf1` and `spine1` should go down.
- BGP session between `leaf1` and `spine2` should stay up.
- `leaf1` should still have reachability through `spine2`.
- ECMP should reduce to a single path where applicable.

### Recovery Action

```bash
docker exec clab-frr-leaf-spine-leaf1 ip link set eth1 up
```

### Recovery Validation

```bash
docker exec clab-frr-leaf-spine-leaf1 vtysh -c "show bgp summary"
```

---

## 4. Test 2 — Spine Failure

### Failure Scenario

Stop `spine1`.

### Failure Action

```bash
docker stop clab-frr-leaf-spine-spine1
```

### Validation

```bash
{
  echo "===== spine1 stopped ====="
  docker ps --format 'table {{.Names}}\t{{.Status}}'
  echo
  echo "===== leaf1 BGP summary ====="
  docker exec clab-frr-leaf-spine-leaf1 vtysh -c "show bgp summary"
  echo
  echo "===== leaf2 BGP summary ====="
  docker exec clab-frr-leaf-spine-leaf2 vtysh -c "show bgp summary"
  echo
  echo "===== leaf1 BGP routes ====="
  docker exec clab-frr-leaf-spine-leaf1 vtysh -c "show ip route bgp"
} | tee labs/01-frr-leaf-spine/failure-tests/02-spine1-down.txt
```

### Expected Result

- all sessions to `spine1` should go down
- sessions to `spine2` should stay up
- leaf-to-leaf loopback reachability should still work through `spine2`
- ECMP should reduce to a single path

### Recovery Action

```bash
docker start clab-frr-leaf-spine-spine1
```

### Recovery Validation

```bash
for node in spine1 spine2 leaf1 leaf2 leaf3 leaf4; do
  echo "===== $node ====="
  docker exec clab-frr-leaf-spine-$node vtysh -c "show bgp summary"
done
```

---

## 5. Test 3 — Leaf Failure

### Failure Scenario

Stop `leaf1`.

### Failure Action

```bash
docker stop clab-frr-leaf-spine-leaf1
```

### Validation

```bash
{
  echo "===== leaf1 stopped ====="
  docker ps --format 'table {{.Names}}\t{{.Status}}'
  echo
  echo "===== spine1 BGP summary ====="
  docker exec clab-frr-leaf-spine-spine1 vtysh -c "show bgp summary"
  echo
  echo "===== spine2 BGP summary ====="
  docker exec clab-frr-leaf-spine-spine2 vtysh -c "show bgp summary"
  echo
  echo "===== leaf2 BGP routes ====="
  docker exec clab-frr-leaf-spine-leaf2 vtysh -c "show ip route bgp"
} | tee labs/01-frr-leaf-spine/failure-tests/03-leaf1-down.txt
```

### Expected Result

- sessions from both spines to `leaf1` should go down
- routes originated by `leaf1` should be withdrawn
- other leaves should continue to communicate with each other
- host or prefix reachability behind `leaf1` should be unavailable

### Recovery Action

```bash
docker start clab-frr-leaf-spine-leaf1
```

### Recovery Validation

```bash
for node in spine1 spine2 leaf1 leaf2 leaf3 leaf4; do
  echo "===== $node ====="
  docker exec clab-frr-leaf-spine-$node vtysh -c "show bgp summary"
done
```

---

## 6. Failure Test Summary Template

Use this format after each test:

```text
## Test Name

Baseline:
- ...

Failure action:
- ...

Expected result:
- ...

Actual result:
- ...

Recovery action:
- ...

Recovery result:
- ...

Notes:
- ...
```

## 7. Completion Criteria

Failure testing is complete when:

- at least one spine-leaf link failure is tested
- at least one spine failure is tested
- at least one leaf failure is tested
- before/after outputs are saved
- expected vs actual behavior is documented
- recovery behavior is documented
