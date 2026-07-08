# AI Fabric Validation Matrix

## Purpose

This document defines a validation matrix for AI data center fabric work.

The goal is to move from basic connectivity checks to workload-aware validation. A fabric should be validated layer by layer, from interface health to routing, overlay reachability, RDMA readiness, NCCL path selection, workload behavior, observability, and failure handling.

---

## Validation Principles

A useful validation plan should be:

- repeatable
- evidence-based
- easy to run after changes
- clear about expected results
- tied to actual workload requirements
- suitable for both lab documentation and operational runbooks

The output should not only say `PASS` or `FAIL`. It should also record why the result matters.

---

## Matrix Overview

| Layer | Area | Goal | Example Evidence |
|---|---|---|---|
| L0 | Lab/platform readiness | Prove the lab environment is stable | containerlab deploy result, container status |
| L1 | Interface and link state | Prove ports and links are up and clean | interface status, counters, MTU |
| L2 | Underlay routing | Prove routed fabric reachability | BGP summary, route table, ping between loopbacks |
| L3 | Overlay/service reachability | Prove tenant or workload networks work | EVPN routes, VXLAN reachability, host-to-host tests |
| L4 | RDMA readiness | Prove RDMA devices and paths are usable | `ibv_devinfo`, `ib_write_bw`, NIC counters |
| L5 | Lossless/congestion behavior | Prove RoCE-related congestion control works | PFC, ECN, CNP, queue counters |
| L6 | NCCL readiness | Prove AI communication libraries use the intended fabric | NCCL debug logs, benchmark output |
| L7 | Workload validation | Prove the actual application behaves correctly | DDP/vLLM job result, throughput, latency |
| L8 | Observability | Prove operators can detect and explain issues | dashboards, alerts, telemetry, logs |
| L9 | Failure testing | Prove behavior during link/node/path failure | failover tests, convergence time, impact notes |

---

## L0: Lab and Platform Readiness

### Objective

Prove the environment is reliable before debugging the fabric.

### Checks

```bash
containerlab version
docker version
docker ps
sudo clab inspect --all
```

### Expected Evidence

- lab topology can be deployed cleanly
- containers are running
- management access works
- there are no obvious host resource problems

### Output Example

```text
outputs/platform-validation-summary.md
```

---

## L1: Interface and Link State

### Objective

Prove that all required links are up and not showing unexpected physical or interface-level errors.

### Checks

Generic Linux:

```bash
ip link show
ip -s link show
etstat -i
```

Network OS examples:

```bash
show interfaces status
show interfaces counters
show lldp neighbors
```

### Expected Evidence

- expected interfaces are up
- MTU is consistent
- LLDP neighbors match the topology
- error/drop counters are not increasing unexpectedly

### Why It Matters for AI Fabric

AI workloads can amplify small link-quality problems. A normal service may tolerate minor packet loss, but RDMA and distributed GPU communication may react badly to drops, unstable links, or incorrect MTU.

---

## L2: Underlay Routing

### Objective

Prove that the routed leaf-spine fabric has stable reachability.

### Checks

```bash
show ip bgp summary
show ip route
show ipv6 route
ping <loopback-address>
traceroute <loopback-address>
```

### Expected Evidence

- all expected eBGP sessions are established
- loopbacks are reachable
- ECMP paths are present where expected
- no unexpected route selection occurs

### Automation Ideas

Possible script:

```text
scripts/check-underlay.py
```

Possible output:

```text
outputs/check-underlay-summary.md
```

---

## L3: Overlay and Service Reachability

### Objective

Prove that overlay networks or workload networks operate correctly over the underlay.

### Checks

```bash
show bgp l2vpn evpn summary
show bgp l2vpn evpn route
show vxlan interface
bridge fdb show
ping <remote-host-in-same-vni>
ping <remote-host-via-anycast-gateway>
```

### Expected Evidence

- EVPN peers are established
- Type-2/Type-3/Type-5 routes appear as expected, depending on design
- VXLAN tunnel endpoints are correct
- hosts can communicate across leaves

### Why It Matters for AI Fabric

Not every AI fabric uses EVPN/VXLAN in the same way. However, understanding overlay validation is useful for GPU cloud, multi-tenant infrastructure, and platform networking roles.

---

## L4: RDMA Readiness

### Objective

Prove that RDMA-capable devices are present, mapped correctly, and usable.

### Checks

```bash
ibv_devices
ibv_devinfo
ibstat
ibdev2netdev
rdma link show
```

### Expected Evidence

- expected HCA devices are visible
- HCA-to-interface mapping is documented
- link state is active
- the data interface is not confused with the management interface

### Output Example

```text
outputs/rdma-device-inventory.md
```

---

## L5: RoCE Lossless and Congestion Behavior

### Objective

Prove that RoCE traffic is protected and congestion is handled in a controlled way.

### Checks

Data points to collect:

- PFC counters
- ECN marking counters
- CNP counters
- queue drops
- buffer usage
- interface pause frames
- NIC driver counters

### Expected Evidence

- selected priorities are configured consistently
- PFC behavior is observable when triggered
- ECN marking occurs under congestion where expected
- unexpected drops are not increasing during RDMA tests

### Notes

This layer usually requires real hardware or hardware-supported virtual environments. In a pure virtual lab, document the design and validation method rather than pretending to prove hardware behavior.

---

## L6: NCCL Readiness

### Objective

Prove that AI communication libraries use the intended network path.

### Checks

Example environment variables to review:

```bash
NCCL_DEBUG=INFO
NCCL_SOCKET_IFNAME=<data-interface>
NCCL_IB_HCA=<hca-name>
NCCL_IB_GID_INDEX=<gid-index-for-roce>
```

Example tests:

```bash
all_reduce_perf
broadcast_perf
all_gather_perf
reduce_scatter_perf
```

### Expected Evidence

- NCCL logs show the intended interface
- the test does not use the management network accidentally
- RDMA transport is used when expected
- benchmark results are repeatable enough to compare changes

### Output Example

```text
outputs/nccl-baseline-report.md
```

---

## L7: Workload-Level Validation

### Objective

Prove that the actual workload is stable and performs within an expected range.

### Examples

Training-related:

- small distributed training job
- DDP communication health test
- repeated AllReduce loop

Inference-related:

- vLLM service startup
- OpenAI-compatible API test
- latency and throughput test
- GPU utilization and network traffic observation

Storage-related:

- model load from shared storage
- checkpoint read/write test
- storage path latency and throughput test

### Expected Evidence

- job completes successfully
- results are repeatable
- network path matches the design
- no hidden fabric counters show instability

---

## L8: Observability

### Objective

Prove that the fabric can be monitored and explained during normal and abnormal operation.

### Data Sources

- syslog
- interface counters
- BGP session state
- LLDP topology
- streaming telemetry
- SNMP where appropriate
- RDMA/NIC counters
- Kubernetes events
- workload logs
- GPU metrics

### Expected Evidence

- operators can see link, routing, and workload symptoms in one workflow
- alerts are actionable
- dashboards map to failure domains
- troubleshooting notes explain likely root causes

---

## L9: Failure Testing

### Objective

Prove what happens when part of the fabric fails.

### Example Tests

| Test | Expected Observation |
|---|---|
| Shut one leaf-spine link | ECMP path reduces, reachability remains if redundant |
| Shut one BGP session | route withdrawal and convergence are observed |
| Restart routing process | control-plane recovery is documented |
| Disable one host-facing interface | workload impact is recorded |
| Introduce MTU mismatch | symptoms are documented and detected |
| Misconfigure NCCL interface | job uses wrong path or fails predictably |

### Output Example

```text
outputs/failure-test-summary.md
```

---

## Suggested Repo Structure

```text
validation/
├── fabric-validation-matrix.md
├── rdma-readiness-checklist.md
├── nccl-readiness-checklist.md
└── workload-validation-template.md

scripts/
├── check-underlay.py
├── check-overlay.py
├── check-rdma-devices.py
└── collect-interface-counters.sh

outputs/
├── check-underlay-summary.md
├── check-overlay-summary.md
├── rdma-readiness-summary.md
└── workload-validation-summary.md
```

---

## Summary

A useful AI fabric validation plan must connect network state to workload behavior.

The practical progression is:

```text
links -> routing -> overlay -> RDMA -> congestion behavior -> NCCL path -> workload -> observability -> failure handling
```

This matrix can be used as a long-term checklist for future labs and design notes.
