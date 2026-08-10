# Lab — ECMP, HFT, and Adaptive Routing

> **Platform:** NVIDIA Air  
> **Network OS:** Cumulus Linux 5.16.1  
> **Status:** Complete

## 1. What This Lab Validates

This lab validates four things:

1. eBGP installs two equal-cost paths.
2. ECMP forwards different flows across both spine paths.
3. HFT configuration can be created in Cumulus Linux, while NVIDIA Air cannot prove real Spectrum ASIC HFT sampling.
4. Adaptive Routing configuration can be enabled with NVUE, while NVIDIA Air cannot prove real congestion-aware ASIC path selection.

The intended learning path is:

```text
eBGP
  ↓
ECMP
  ↓
single-flow vs multi-flow forwarding
  ↓
path imbalance
  ↓
HFT visibility
  ↓
Adaptive Routing
```

---

## 2. Topology

```text
                    spine01
                    AS65000
                  /         \
                 /           \
              leaf01       leaf02
              AS65101      AS65102
                 \           /
                  \         /
                    spine02
                    AS65000

                  |           |
                host01      host02
             10.10.1.10   10.10.2.10
```

Links:

```text
leaf01:swp1 --- spine01:swp1
leaf01:swp2 --- spine02:swp1

leaf02:swp1 --- spine01:swp2
leaf02:swp2 --- spine02:swp2

leaf01:swp3 --- host01:eth1
leaf02:swp3 --- host02:eth1
```

---

## 3. IP Plan

| Device | Interface | IP |
|---|---|---|
| leaf01 | swp1 | `10.0.0.0/31` |
| spine01 | swp1 | `10.0.0.1/31` |
| leaf01 | swp2 | `10.0.0.2/31` |
| spine02 | swp1 | `10.0.0.3/31` |
| leaf02 | swp1 | `10.0.0.4/31` |
| spine01 | swp2 | `10.0.0.5/31` |
| leaf02 | swp2 | `10.0.0.6/31` |
| spine02 | swp2 | `10.0.0.7/31` |
| leaf01 | swp3 | `10.10.1.1/24` |
| host01 | eth1 | `10.10.1.10/24` |
| leaf02 | swp3 | `10.10.2.1/24` |
| host02 | eth1 | `10.10.2.10/24` |

ASNs:

```text
spine01 = AS65000
spine02 = AS65000
leaf01  = AS65101
leaf02  = AS65102
```

---

## 4. Validation Steps

### Step 1 — Verify Host Connectivity

From `host01`:

```bash
ping -c 5 10.10.2.10
```

Expected:

```text
0% packet loss
```

---

### Step 2 — Verify BGP Multipath

On `leaf01`:

```bash
nv show vrf default router bgp address-family ipv4-unicast route 10.10.2.0/24
```

Expected:

```text
path-count       2
multipath-count  2
```

Check the Linux route:

```bash
ip route show 10.10.2.0/24
ip nexthop show
```

Expected logical result:

```text
10.10.2.0/24
   ↓
ECMP nexthop group
   ├── 10.0.0.1 via swp1
   └── 10.0.0.3 via swp2
```

---

### Step 3 — Verify Single-Flow ECMP

On `host02`:

```bash
iperf3 -s
```

On `host01`:

```bash
iperf3 -c 10.10.2.10 -P 1 -t 20
```

Before and after the test, check:

```bash
ip -s link show swp1
ip -s link show swp2
```

Expected:

```text
One TCP flow
   ↓
one ECMP hash
   ↓
one uplink carries almost all test traffic
```

A later run can use the other uplink because the TCP source port changes.

---

### Step 4 — Verify Multi-Flow ECMP

On `host01`:

```bash
iperf3 -c 10.10.2.10 -P 8 -t 20
```

Check both uplinks again:

```bash
ip -s link show swp1
ip -s link show swp2
```

Expected:

```text
Both uplinks increase.
```

The distribution does not need to be exactly 50/50 because ECMP balances flows, not bytes.

---

### Step 5 — Configure HFT

On `leaf01`:

```bash
nv set system telemetry state enabled
nv config apply

nv set system telemetry hft profile s02-bandwidth sample-interval 1000
nv set system telemetry hft profile s02-bandwidth counter rx-byte
nv set system telemetry hft profile s02-bandwidth counter tx-byte
nv config apply

nv set system telemetry hft target local
nv config apply
```

Schedule an HFT job:

```bash
nv action schedule system telemetry hft job now now \
  duration 20 profile s02-bandwidth ports swp1,swp2
```

Check:

```bash
nv show system telemetry hft job
```

In this Air lab, the action was accepted, but no actual HFT job data was returned.

This validates the configuration workflow, not real Spectrum ASIC sampling.

---

### Step 6 — Configure Adaptive Routing

On `leaf01`:

```bash
nv set router adaptive-routing state enabled
nv set interface swp1 router adaptive-routing state enabled
nv set interface swp2 router adaptive-routing state enabled
nv config apply
```

Verify:

```bash
nv show router adaptive-routing
nv show interface swp1 router adaptive-routing
nv show interface swp2 router adaptive-routing
```

Expected configuration result:

```text
Global Adaptive Routing = enabled
swp1 Adaptive Routing   = enabled
swp2 Adaptive Routing   = enabled
```

This validates the NVUE configuration workflow. NVIDIA Air does not prove real Spectrum ASIC congestion-aware path selection.

---

## 5. Key Learning Points

```text
ECMP
→ hashes flows across equal-cost paths

HFT
→ observes very short traffic events / microbursts

Adaptive Routing
→ dynamically prefers healthier eligible paths

ECN/DCQCN
→ controls congestion reaction / sender rate

PFC
→ hop-by-hop priority pause
```

The most important result from this lab is:

```text
Correct ECMP
does not guarantee
perfectly balanced path utilization.
```
