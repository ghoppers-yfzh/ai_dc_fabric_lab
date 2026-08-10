# S02 Lab Validation Results

## 1. BGP Multipath

On `leaf01`:

```text
path-count       2
multipath-count  2
```

BGP had two valid equal-cost paths to:

```text
10.10.2.0/24
```

The Linux route used nexthop group `31`:

```text
id 31 group 24/27 proto zebra
```

Members:

```text
id 24 via 10.0.0.1 dev swp1 scope link proto zebra
id 27 via 10.0.0.3 dev swp2 scope link proto zebra
```

FRR confirmed both nexthops were installed:

```text
Routing entry for 10.10.2.0/24
Known via "bgp", distance 20, metric 0, best
Status: Installed

* 10.0.0.1, via swp1, weight 1
* 10.0.0.3, via swp2, weight 1
```

### Result

```text
BGP multipath = PASS
Linux ECMP nexthop group = PASS
```

---

## 2. Host Connectivity

From `host01`:

```text
PING 10.10.2.10
5 packets transmitted
5 received
0% packet loss
```

### Result

```text
Host-to-host Layer-3 connectivity = PASS
```

---

## 3. Single-Flow ECMP

The first single-flow `iperf3` test used:

```text
10.10.1.10:34768 -> 10.10.2.10:5201
```

Traffic mainly increased on `swp2`.

A later single-flow run used:

```text
10.10.1.10:34936 -> 10.10.2.10:5201
```

and traffic mainly increased on `swp1`.

### Interpretation

The destination IP and TCP destination port were unchanged, but the TCP source port changed.

Therefore the ECMP hash input changed, allowing a different path to be selected.

```text
single TCP flow
   ↓
one hash
   ↓
one ECMP member
```

### Result

```text
Single-flow ECMP behavior = PASS
Different flows can select different ECMP members = PASS
```

---

## 4. Multi-Flow ECMP

For the `iperf3 -P 8` test:

Before:

```text
swp1 TX = 1,247,830,777 bytes
swp2 TX = 2,476,032,205 bytes
```

After:

```text
swp1 TX = 1,929,497,078 bytes
swp2 TX = 2,884,381,986 bytes
```

Delta:

```text
swp1 = 681,666,301 bytes
swp2 = 408,349,781 bytes
```

Approximate distribution:

```text
swp1 ≈ 62.5%
swp2 ≈ 37.5%
```

This is consistent with an uneven flow distribution such as approximately 5:3.

### Result

```text
Multi-flow forwarding across both spines = PASS
Perfect 50/50 distribution = NOT REQUIRED
```

### Key Finding

```text
ECMP balances flows.
It does not continuously balance bytes.
```

This is why a small number of large elephant flows can still create path imbalance even when ECMP is working correctly.

---

## 5. HFT Validation

Environment:

```text
Cumulus Linux 5.16.1
```

Telemetry was enabled:

```text
state = enabled
```

A custom profile was created:

```text
profile: s02-bandwidth
sample interval: 1000 us
counters:
- rx-byte
- tx-byte
```

The HFT scheduling command returned:

```text
Job schedule successfull.
Action succeeded
```

But:

```text
nv show system telemetry hft job
No Data
```

### Result

```text
HFT NVUE configuration workflow = PASS
Real HFT ASIC data collection = NOT PROVEN
```

### Interpretation

NVIDIA Air/Cumulus VX exposes the HFT configuration model, but this virtual environment cannot be used as proof of real Spectrum ASIC high-frequency sampling or microburst detection.

---

## 6. Adaptive Routing Validation

On `leaf01`:

```bash
nv set router adaptive-routing state enabled
nv set interface swp1 router adaptive-routing state enabled
nv set interface swp2 router adaptive-routing state enabled
nv config apply
```

During apply, Cumulus warned:

```text
Traffic on the ports will be impacted as they will undergo flapping
to apply the adaptive-routing configuration

switchd needs to reload for this config change
```

Global validation:

```text
state                       enabled
link-utilization-threshold  disabled
```

Interface validation:

```text
swp1:
state                       enabled
link-utilization-threshold  70

swp2:
state                       enabled
link-utilization-threshold  70
```

### Result

```text
Adaptive Routing global configuration = PASS
Adaptive Routing on swp1/swp2 = PASS
Real ASIC congestion-aware path selection = NOT PROVEN
```

The port-flap warning is operationally important because enabling Adaptive Routing can affect the forwarding plane and should be treated as a traffic-impacting change.

---

## 7. Final Results

| Test | Result |
|---|---|
| Host connectivity | PASS |
| Two BGP paths | PASS |
| BGP multipath | PASS |
| Linux ECMP nexthop group | PASS |
| Single-flow ECMP | PASS |
| Different flows can choose different paths | PASS |
| Multi-flow uses both spines | PASS |
| Observed multi-flow split | ~62.5% / 37.5% |
| HFT configuration | PASS |
| Real HFT ASIC sampling in Air | NOT PROVEN |
| Adaptive Routing configuration | PASS |
| Real Adaptive Routing ASIC behavior in Air | NOT PROVEN |

---

## 8. Saving and Reusing Cumulus Configuration

### Save the Applied Configuration as YAML

On each Cumulus switch:

```bash
nv config save
nv config show --expand > /home/cumulus/$(hostname)-applied.yaml
```

You can also save a human-readable command version:

```bash
nv config show -o commands > /home/cumulus/$(hostname)-applied.nvset
```

### Import a Lab YAML

For a lab/partial configuration, use:

```bash
nv config patch /home/cumulus/leaf01-applied.yaml
nv config diff
nv config apply
```

Use `patch` because it merges the YAML into the current configuration.

### Restore a Complete Device Backup

The full NVUE startup configuration is:

```text
/etc/nvue.d/startup.yaml
```

To restore a complete backup:

```bash
nv config replace /home/cumulus/leaf01-startup.yaml
nv config diff
nv config apply
```

Use `replace` only with a complete backup because it replaces the whole configuration.

Recommended rule:

```text
Partial lab YAML  -> nv config patch
Full device YAML  -> nv config replace
```
