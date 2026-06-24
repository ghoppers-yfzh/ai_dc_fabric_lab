# AI Fabric Requirements Notes

## Purpose

This note starts connecting the completed fabric labs to AI infrastructure networking.

The completed labs already cover useful data center fabric foundations:

- routed leaf-spine
- eBGP underlay
- loopback reachability
- ECMP
- EVPN/VXLAN overlay
- SONiC operational model
- validation and troubleshooting

AI fabric networking builds on these ideas, but adds stricter requirements around bandwidth, latency, loss, congestion, and operational visibility.

---

## 1. What Is Different About AI Fabric Networking

Traditional data center networks often support mixed application traffic:

- web
- storage
- database
- backup
- management
- customer workloads

AI training and GPU cluster traffic is different because it can create large, synchronized east-west flows between many servers at the same time.

Common patterns:

- GPU-to-GPU communication
- all-reduce operations
- distributed training synchronization
- storage reads for training data
- checkpoint writes
- inference traffic between service tiers

The network is not just a background service. It can directly affect job completion time and GPU utilization.

---

## 2. Why Leaf-Spine Still Matters

The leaf-spine model remains relevant because AI clusters need predictable east-west bandwidth.

A good fabric should provide:

- consistent path length
- predictable failure domains
- ECMP or other multipath behavior
- clear operational validation
- scalable port growth
- simple routing in the underlay

The completed FRR and SONiC underlay labs are useful because they prove the basic fabric logic:

```text
spine-leaf links up
eBGP sessions established
loopbacks advertised
routes learned
remote loopbacks reachable
```

That same validation mindset applies to larger fabrics.

---

## 3. What EVPN/VXLAN Does and Does Not Solve

EVPN/VXLAN helps with:

- workload segmentation
- L2 extension over L3 underlay
- distributed gateway design
- tenant or workload separation
- BGP-based control plane learning

It does not directly solve:

- RDMA performance
- packet loss sensitivity
- congestion management
- buffer pressure
- pause behavior
- incast
- GPU job performance

This is why the project should treat EVPN/VXLAN as a modern fabric foundation, not as the whole AI networking story.

---

## 4. Why Loss Matters More for RDMA

RoCEv2 carries RDMA traffic over Ethernet and IP.

RDMA is designed for efficient memory-to-memory communication with low latency, high throughput, and reduced CPU overhead. This makes the network fabric more important than in many traditional TCP-based environments.

Traditional TCP applications can usually tolerate some packet loss because TCP detects loss, retransmits, and reduces its sending rate. RoCEv2/RDMA traffic is more sensitive to loss and congestion. If the fabric drops packets or creates congestion hot spots, GPU communication can slow down and distributed training jobs may take longer to complete.

This is why AI Ethernet fabrics often discuss:

- PFC
- ECN
- DCQCN
- congestion control
- buffer management
- telemetry
- lossless or near-lossless behavior

These mechanisms should be understood as a congestion-control system rather than as isolated features:

```text
ECN      = early congestion warning
DCQCN    = sender-side rate control
PFC      = last-resort per-priority pause
Buffer   = space for queues and pause headroom
Telemetry = visibility into whether the fabric is stable
```

A detailed explanation is documented in:

```text
docs/08-rocev2-lossless-ethernet-notes.md
```

The current virtual labs can help validate BGP, EVPN/VXLAN, ECMP, and operational workflow, but they cannot fully test physical ASIC buffer behavior, PFC pause behavior, ECN thresholds, DCQCN rate control, NIC-level RoCE counters, or real GPU collective traffic.

---

## 5. Scale-Up vs Scale-Out

A simple model:

```text
scale-up  = communication inside a server or rack-scale system
scale-out = communication between servers across the network fabric
```

Examples:

| Area | Common technologies |
|---|---|
| Scale-up | NVLink, NVSwitch, PCIe |
| Scale-out | Ethernet/RoCE, InfiniBand, leaf-spine fabric |

The local labs mostly model scale-out network foundations.

They do not model GPU-local scale-up fabrics.

---

## 6. What Should Be Monitored in an AI Fabric

A normal fabric validation checks:

- interfaces up/down
- BGP neighbors
- routes
- packet loss
- latency
- reachability

An AI fabric needs those plus deeper congestion visibility:

- interface errors
- drops
- queue depth
- no-drop queue occupancy
- ECN-marked packets
- PFC pause frames per priority
- buffer utilization and headroom usage
- link utilization
- flow distribution and ECMP imbalance
- CNP sent/received where visible
- retransmissions or timeout events where visible
- job-level impact if available

This is why future labs or notes should include monitoring and telemetry even if the local lab cannot generate real RDMA traffic.

---

## 7. What the Current Labs Can Honestly Prove

The current labs can prove:

- basic fabric design understanding
- eBGP underlay behavior
- EVPN/VXLAN control-plane and data-plane concepts
- SONiC operational familiarity
- troubleshooting discipline
- validation workflow

The current labs cannot prove:

- real ASIC forwarding behavior
- line-rate performance
- RDMA performance
- PFC behavior
- ECN/DCQCN tuning
- GPU workload behavior
- production SONiC readiness

This limitation should be stated clearly. It makes the project more credible, not weaker.

---

## 8. Suggested Reading Topics

Study these next, in this order:

```text
1. AI training traffic patterns
2. RDMA basics
3. RoCEv2 basics
4. PFC and why it is risky
5. ECN and DCQCN
6. InfiniBand vs Ethernet tradeoffs
7. NVIDIA Spectrum-X positioning
8. telemetry for congestion and packet loss
```

Do not start with vendor tuning knobs. Start with the problem each technology is trying to solve.

---

## 9. Key Takeaways

- AI fabric networking builds on data center fabric fundamentals.
- Leaf-spine, eBGP, loopbacks, and validation remain relevant.
- EVPN/VXLAN is useful but does not solve RDMA congestion by itself.
- RoCEv2 makes packet loss and congestion management much more important.
- ECN, DCQCN, PFC, buffer management, and telemetry form a congestion-control system for RoCEv2 Ethernet fabrics.
- Some AI fabric topics should be documented honestly even when they cannot be fully reproduced in a local virtual lab.
