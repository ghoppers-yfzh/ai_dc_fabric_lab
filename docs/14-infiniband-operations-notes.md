# InfiniBand Operations Notes

## Purpose

This note introduces InfiniBand operations from a data center network engineering perspective.

The goal is not to replace vendor documentation. The goal is to understand the operational model of InfiniBand well enough to compare it with Ethernet/RoCE and to discuss AI/HPC fabric design, validation, and troubleshooting.

---

## Why InfiniBand Matters for AI Infrastructure

InfiniBand is widely used in HPC and large AI training environments because it was designed for high-performance, low-latency, lossless fabric communication.

For a network engineer with an Ethernet background, InfiniBand requires a different mental model:

| Ethernet / IP Fabric | InfiniBand Fabric |
|---|---|
| MAC/IP addressing | GUID and LID addressing |
| IP routing protocols such as BGP/OSPF/IS-IS | Subnet Manager computes paths |
| VLAN/VRF segmentation | P_Key partitioning |
| Switch CLI and standard network monitoring | Fabric manager tools such as UFM plus IB tools |
| ECMP and routing policy | IB path calculation and fabric routing |
| RoCE requires Ethernet lossless design | Native lossless-style fabric behavior |

The important career skill is not memorizing every IB command. The important skill is understanding how IB fabrics are discovered, managed, segmented, monitored, and validated.

---

## Core Concepts

### HCA

HCA means Host Channel Adapter. It is the host-side InfiniBand adapter, similar in role to a NIC in Ethernet.

Common validation questions:

- Does the host see the HCA?
- Is the HCA port active?
- Which HCA maps to which workload path?
- Is the expected port speed negotiated?

Useful commands:

```bash
ibv_devices
ibv_devinfo
ibstat
ibdev2netdev
```

---

### GUID

GUID means Globally Unique Identifier.

In InfiniBand, devices and ports have GUIDs. A GUID is a stable identifier used during fabric discovery and management.

Ethernet comparison:

- GUID is not the same as an IP address.
- It is closer to a unique device or port identity.
- Operators often use GUIDs when mapping hosts, HCAs, and switch ports.

Operational value:

- helps identify the real device behind a port
- helps troubleshoot incorrect cabling or topology records
- helps correlate UFM topology with host inventory

---

### LID

LID means Local Identifier.

A LID is assigned by the Subnet Manager and is used for forwarding inside an InfiniBand subnet.

Ethernet comparison:

- LID is not manually planned like an IP address.
- It is assigned as part of fabric discovery and subnet management.
- If the Subnet Manager changes or the fabric reinitializes, LID assignments may change.

Operational value:

- helps understand fabric pathing
- appears in many IB diagnostic outputs
- useful when tracing communication paths within the fabric

---

### Subnet Manager

The Subnet Manager is one of the most important InfiniBand concepts.

It discovers the fabric, assigns LIDs, calculates paths, and maintains the subnet.

Common implementations or management models include:

- OpenSM
- vendor-integrated subnet managers
- UFM-managed environments

Ethernet comparison:

- In Ethernet, switches often run distributed routing protocols.
- In InfiniBand, the Subnet Manager has a central role in fabric discovery and path calculation.

Operational questions:

- Which system is running the active Subnet Manager?
- Is there a standby Subnet Manager?
- Has the fabric converged?
- Are all expected nodes discovered?
- Are there topology errors or port state issues?

---

### P_Key

P_Key means Partition Key.

P_Key is used for partitioning and isolation inside an InfiniBand fabric.

Ethernet comparison:

- P_Key is often compared loosely to VLANs, but it is not identical.
- It controls membership and communication within IB partitions.
- It is important for multi-tenant or multi-workload fabrics.

Operational questions:

- Which hosts belong to which partition?
- Are full and limited membership rules understood?
- Can workloads communicate only with allowed peers?
- Is the P_Key configuration consistent with the platform design?

---

### UFM

UFM is NVIDIA's fabric management platform for InfiniBand environments.

Typical operational use cases:

- fabric discovery
- topology visualization
- port health monitoring
- event and alarm management
- congestion and performance visibility
- configuration and policy support
- troubleshooting workflow

For a network engineer, UFM is similar in purpose to a network management and observability platform, but it is focused on InfiniBand fabric behavior.

Operational questions:

- Does UFM show the expected topology?
- Are all switches, HCAs, and links discovered?
- Are any links degraded or flapping?
- Are there symbol errors, link errors, or congestion events?
- Does the topology match the physical cabling plan?

---

### SHARP

SHARP means Scalable Hierarchical Aggregation and Reduction Protocol.

SHARP enables supported fabric devices to accelerate collective operations such as reductions inside the network.

Why it matters:

- AI training often uses collective operations such as AllReduce.
- Moving some aggregation work into the fabric can reduce host and network overhead for supported workloads.
- It connects networking directly to distributed training performance.

Operational note:

SHARP is a platform capability, not a generic feature that exists everywhere. It depends on supported hardware, software, firmware, and workload integration.

---

## Basic InfiniBand Validation Flow

```text
1. Confirm host HCA visibility
2. Confirm HCA link state and speed
3. Confirm switch port state
4. Confirm Subnet Manager is active
5. Confirm nodes are discovered in the fabric
6. Confirm GUID-to-host mapping
7. Confirm LID assignment
8. Confirm P_Key membership if partitioning is used
9. Run RDMA bandwidth and latency tests
10. Check fabric counters and UFM events
11. Record topology, counters, and test output
```

---

## Useful Host-Side Commands

```bash
ibv_devices
ibv_devinfo
ibstat
ibdev2netdev
ibhosts
ibswitches
iblinkinfo
ibnetdiscover
ibdiagnet
perfquery
```

Notes:

- Command availability depends on installed packages and platform.
- Some commands require privileges.
- Output should be interpreted together with the topology and Subnet Manager state.

---

## Troubleshooting Patterns

### 1. Host Cannot See the HCA

Possible areas to check:

- PCI device visibility
- driver loading
- firmware compatibility
- kernel modules
- container passthrough if running inside containers

Evidence:

```bash
lspci
lsmod | grep mlx
ibv_devices
```

---

### 2. HCA Exists but Link Is Down

Possible areas to check:

- cable or optics
- switch port state
- speed or link negotiation
- port disabled administratively
- physical topology mismatch

Evidence:

```bash
ibstat
ibdev2netdev
iblinkinfo
```

---

### 3. Nodes Are Not Discovered

Possible areas to check:

- Subnet Manager not running
- fabric not converged
- partition or policy issue
- link state issue between switches

Evidence:

```bash
ibnetdiscover
ibhosts
ibswitches
```

---

### 4. RDMA Test Fails

Possible areas to check:

- wrong HCA selected
- wrong port selected
- partition mismatch
- firewall or host policy for IPoIB-based tests
- MTU or path issue
- fabric errors

Evidence:

```bash
ib_write_bw
ib_write_lat
perfquery
```

---

### 5. Performance Is Lower Than Expected

Possible areas to check:

- link speed mismatch
- PCIe bottleneck
- NUMA locality
- GPU-to-NIC topology
- congestion
- wrong fabric path
- workload using TCP fallback instead of RDMA
- NCCL selecting the wrong interface

Evidence:

```bash
nvidia-smi topo -m
ibdev2netdev
NCCL_DEBUG=INFO
perfquery
```

---

## InfiniBand vs RoCE Operational Comparison

| Area | InfiniBand | RoCEv2 |
|---|---|---|
| Transport | Native IB fabric | RDMA over UDP/IP/Ethernet |
| Path control | Subnet Manager | Ethernet/IP routing and switching |
| Congestion model | IB fabric mechanisms and vendor features | PFC, ECN, DCQCN, QoS design |
| Segmentation | P_Key | VLAN/VRF/ACL/QoS policy |
| Tooling | IB tools, UFM | Ethernet NOS tools, NIC counters, telemetry |
| Familiarity for DC network engineers | Lower at first | Higher because it uses Ethernet/IP |
| Operational risk | Requires IB-specific knowledge | Requires careful lossless Ethernet design |

---

## What to Learn First

Recommended order:

```text
1. HCA, GUID, LID, Subnet Manager
2. Basic IB discovery commands
3. UFM role and topology view
4. P_Key partitioning model
5. RDMA bandwidth/latency tests
6. NCCL over IB path selection
7. SHARP at conceptual level
```

This order keeps the focus on operations and validation rather than deep protocol theory.

---

## Repo Artifact Ideas

Possible future files:

```text
docs/infiniband-operations-notes.md
validation/infiniband-readiness-checklist.md
validation/ufm-operations-checklist.md
outputs/ib-fabric-discovery-example.md
outputs/ib-rdma-baseline-example.md
```

---

## Summary

InfiniBand is not just faster Ethernet. It has a different operational model based on HCAs, GUIDs, LIDs, Subnet Manager discovery, P_Key partitioning, and fabric management tools.

For AI infrastructure networking work, the practical goal is to understand:

```text
how the fabric is discovered,
how paths are managed,
how hosts are identified,
how partitions are enforced,
how performance is validated,
and how failures are detected and explained.
```
