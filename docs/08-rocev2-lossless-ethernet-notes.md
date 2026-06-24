# RoCEv2 and Lossless Ethernet Notes

## Purpose

This document explains why RoCEv2-based AI Ethernet fabrics require careful congestion control, buffer management, and telemetry.

The goal is not to configure a full production RoCE fabric in the current lab. The goal is to understand the main concepts and how they relate to AI data center networking.

Key topics:

- RoCEv2
- RDMA
- PFC
- ECN
- DCQCN
- congestion control
- buffer management
- telemetry
- lossless or near-lossless Ethernet behavior

---

## 1. Why RDMA Cares About Loss

RoCEv2 carries RDMA traffic over Ethernet and IP.

RDMA is designed for efficient memory-to-memory communication with low latency, high throughput, and reduced CPU overhead. This is useful for high-performance workloads such as AI training, HPC, and storage, but it also means the network fabric must behave more predictably.

Traditional TCP applications can usually tolerate some packet loss. TCP detects loss, retransmits, and reduces its sending rate. Performance may suffer, but the protocol is designed for lossy IP networks.

RoCEv2 traffic is more sensitive to loss and congestion. If the fabric drops packets or creates congestion hot spots, GPU communication can slow down. In distributed AI training, one slow path can delay collective communication and increase the overall training step time.

In an AI cluster, packet loss is not just a network counter. It can become a cluster efficiency problem.

---

## 2. Concept Map

The main mechanisms should be understood as a congestion-control system:

```text
PFC       = last-resort per-priority pause
ECN       = early congestion marking
DCQCN     = sender-side rate control based on congestion feedback
Buffer    = queue and headroom planning
Telemetry = visibility into queues, pause, drops, ECN, and RDMA behavior
```

A useful mental model:

```text
ECN       = yellow light
DCQCN     = sender slows down after seeing the yellow light
PFC       = emergency brake
Buffer    = braking distance
Telemetry = dashboard and sensors
```

The ideal behavior is:

```text
Queue starts building
        |
        v
ECN marks packets early
        |
        v
Receiver sends congestion notification
        |
        v
Sender reduces rate using DCQCN
        |
        v
Queue drains before PFC is needed
```

PFC should exist as protection, but it should not be the normal congestion-control method.

---

## 3. PFC: Priority Flow Control

PFC stands for Priority Flow Control.

It allows Ethernet pause behavior to apply to a specific traffic priority instead of pausing the entire link.

Traditional Ethernet pause is link-wide:

```text
Pause this link
```

PFC is per priority:

```text
Pause only this priority / traffic class
```

For RoCEv2, the RoCE traffic is usually mapped into a specific lossless or no-drop priority. If the switch queue for that priority becomes too full, the switch can send a PFC pause frame to its upstream neighbor.

Example:

```text
Switch B has a congested RoCE queue.
Switch B sends PFC pause to Switch A for the RoCE priority.
Switch A temporarily stops sending that priority.
Other traffic priorities may continue forwarding.
```

PFC helps prevent packet drops, but it has risk.

Because PFC is hop-by-hop, congestion can spread upstream. If one device pauses an upstream neighbor, that neighbor may also start buffering traffic and pause another device. This can create congestion spreading and head-of-line blocking.

For this reason, PFC should be treated as a safety mechanism, not the main congestion-control mechanism.

---

## 4. ECN: Explicit Congestion Notification

ECN stands for Explicit Congestion Notification.

ECN allows a switch to signal congestion without dropping packets.

Instead of using packet loss as the congestion signal, the switch marks packets when a queue starts building. The receiver sees the ECN-marked packet and sends congestion feedback back to the sender.

Simplified flow:

```text
Sender sends RoCEv2 traffic
        |
        v
Switch queue starts building
        |
        v
Switch marks ECN
        |
        v
Receiver receives ECN-marked packet
        |
        v
Receiver sends congestion notification
        |
        v
Sender slows down
```

ECN is different from PFC:

| Mechanism | Scope | Action | Purpose |
|---|---|---|---|
| ECN | End-to-end | Mark packets | Ask sender to slow down early |
| PFC | Hop-by-hop | Pause priority | Prevent queue overflow and loss |

In a healthy RoCEv2 fabric, ECN should normally act before PFC is required.

---

## 5. DCQCN: Data Center Quantized Congestion Notification

DCQCN stands for Data Center Quantized Congestion Notification.

DCQCN is a congestion-control mechanism commonly associated with RoCEv2 environments.

The important idea is:

```text
ECN/CNP tells the sender there is congestion.
DCQCN controls how the sender reduces and later increases its sending rate.
```

CNP means Congestion Notification Packet. In a simplified RoCEv2 congestion-control flow, the receiver sends CNPs back to the sender after receiving ECN-marked traffic.

Simplified behavior:

```text
1. Sender NIC sends RoCE traffic.
2. A switch detects congestion and marks packets with ECN.
3. Receiver receives ECN-marked packets.
4. Receiver sends a CNP back to the sender.
5. Sender NIC reduces the sending rate.
6. If congestion improves, the sender gradually increases the rate again.
```

DCQCN helps avoid relying only on PFC.

Without effective sender-side rate control, the network may repeatedly hit pause thresholds. That can cause unstable throughput, congestion spreading, and poor fairness between flows.

---

## 6. Buffer Management

Buffer management is critical in RoCEv2 fabrics.

Important concepts include:

- queue depth
- shared buffer
- headroom buffer
- ECN threshold
- PFC threshold
- no-drop queue
- lossy queue
- traffic class mapping

The relationship between ECN and PFC thresholds is important:

```text
ECN threshold < PFC threshold < actual drop point
```

This means:

```text
1. ECN should start marking before the queue becomes dangerous.
2. DCQCN should give the sender time to slow down.
3. PFC should trigger only if congestion becomes worse.
4. Packet drops should be avoided.
```

PFC also requires headroom buffer.

When a switch sends a PFC pause frame to an upstream device, traffic does not stop instantly. Some packets are already on the wire, and more packets may arrive before the upstream device reacts. The downstream switch needs enough headroom buffer to absorb these in-flight packets.

Bad buffer tuning can cause either:

```text
PFC too early  -> unnecessary pause and reduced throughput
PFC too late   -> buffer overflow and packet loss
ECN too late   -> sender slows down too late
ECN too early  -> under-utilization
```

---

## 7. Telemetry

RoCEv2 fabric problems may not appear as simple interface failures.

A fabric can have all links up, BGP established, and EVPN routes installed, while still having poor AI workload performance due to congestion, queue buildup, PFC pause, or ECN/CNP issues.

Useful telemetry areas include:

```text
Interface counters:
- bandwidth utilization
- packet drops
- CRC/FCS errors
- pause frames
- PFC pause frames per priority

Queue and buffer counters:
- queue depth
- queue drops
- no-drop queue occupancy
- shared buffer usage
- headroom buffer usage
- ECN-marked packets

RoCE/RDMA counters:
- CNP sent/received
- retransmissions
- timeout events
- sequence errors
- NIC-level congestion counters

Fabric-level indicators:
- ECMP imbalance
- hot leaf
- hot spine
- incast patterns
- all-to-all traffic pressure

Application-level indicators:
- GPU utilization
- training step time
- collective communication time
- job completion time
```

For AI infrastructure networking, telemetry must show more than basic reachability. It should help answer:

```text
Is the fabric really near-lossless?
Is congestion being detected early?
Is PFC triggering too often?
Are ECN marks being generated?
Are senders reacting properly?
Are some paths or queues becoming hot spots?
```

---

## 8. Healthy vs Unhealthy Fabric Behavior

Healthy behavior:

```text
Queue starts building
ECN marking begins
Receiver sends congestion notification
Sender slows down with DCQCN
Queue drains
PFC rarely triggers
No packet drops
Application performance remains stable
```

Unhealthy behavior:

```text
Queue builds quickly
ECN threshold is too high or ineffective
Sender does not slow down in time
PFC triggers frequently
Pause spreads upstream
Throughput becomes unstable
GPU communication slows down
Training job step time increases
```

Worst-case behavior:

```text
Buffer headroom is insufficient
PFC does not take effect in time
Packets are dropped
RDMA retransmission or timeout occurs
Application performance becomes unstable
```

---

## 9. Relationship to the Current Labs

The current virtual labs can help validate:

- leaf-spine topology
- eBGP underlay
- EVPN/VXLAN overlay
- ECMP behavior
- failure testing
- documentation and validation workflow

The current virtual labs cannot fully validate:

- ASIC buffer behavior
- PFC pause behavior
- ECN threshold behavior
- DCQCN rate control
- NIC-level RoCE counters
- real GPU collective traffic patterns

These topics should still be studied and documented because they are central to AI Ethernet fabric design.

---

## 10. What to Learn Next

Good follow-up topics:

```text
1. RDMA basics
2. RoCEv2 packet flow
3. PFC pause behavior and congestion spreading
4. ECN marking thresholds
5. CNP and DCQCN sender reaction
6. shared buffer and headroom buffer design
7. switch telemetry for congestion visibility
8. NIC-level RoCE/RDMA counters
```

Do not start with vendor tuning knobs. Start with the purpose of each mechanism and the failure mode it tries to prevent.

---

## 11. Key Takeaways

RoCEv2 aims to provide RDMA over Ethernet/IP for high-performance workloads.

Because RDMA is sensitive to packet loss and congestion, AI Ethernet fabrics require more than basic reachability. They require predictable congestion behavior, careful queue and buffer design, and strong telemetry.

The core relationship is:

```text
ECN detects congestion early.
DCQCN slows down the sender.
PFC prevents loss as a last resort.
Buffer management provides enough room for these mechanisms to work.
Telemetry proves whether the fabric is actually stable.
```

A useful summary:

```text
PFC is the emergency brake.
ECN is the early warning signal.
DCQCN is the sender-side speed control.
Buffer management defines the braking distance.
Telemetry shows whether the system is behaving correctly.
```
