# AI Workload Network Validation Notes

## Purpose

This note explains how AI training and inference workloads use the network, and what a network engineer should validate before calling an AI fabric "ready".

The goal is not to become a machine learning engineer. The goal is to understand enough about NCCL, DDP, vLLM, RDMA, RoCE, InfiniBand, and GID selection to design, validate, and troubleshoot the network underneath GPU workloads.

Key topics:

- Why AI workloads create heavy east-west traffic
- What gradients are and why they need synchronization
- NCCL collective communication patterns
- Broadcast, Reduce, AllReduce, AllGather, and ReduceScatter
- DDP training traffic
- vLLM inference traffic
- RoCE / InfiniBand path selection
- `NCCL_SOCKET_IFNAME`, `NCCL_IB_HCA`, and `NCCL_IB_GID_INDEX`
- What GID means in RDMA/RoCE
- Why ping is not enough for AI workload validation

---

## 1. Why AI Workloads Matter to Network Engineers

Traditional data center networks often focus on:

- user-to-application traffic
- application-to-database traffic
- north-south ingress and egress
- service reachability
- redundancy and failover

AI training and large-scale inference add a much heavier east-west traffic pattern:

- GPU workers exchange data with other GPU workers
- training jobs repeatedly synchronize gradients
- inference services may use tensor parallelism across multiple GPUs
- model loading may create large shared-storage read traffic
- workload performance can be limited by bandwidth, latency, jitter, loss, congestion, or poor path selection

A normal application validation question might be:

```text
Can the hosts ping each other?
```

For AI infrastructure, the better question is:

```text
Can the fabric support the communication pattern required by the workload?
```

That means validating not only reachability, but also bandwidth, latency, loss, congestion behavior, path selection, and workload-level communication.

---

## 2. Basic Training Concepts

### 2.1 Model Parameters

A machine learning model contains many parameters, often called weights.

Simplified view:

```text
weight_1
weight_2
weight_3
...
weight_n
```

Training changes these weights so that the model makes better predictions.

### 2.2 Loss

Loss is a measurement of how wrong the model is.

Simplified training loop:

```text
input data
-> model prediction
-> compare prediction with expected answer
-> calculate loss
-> adjust model parameters
```

If the model predicts badly, loss is high. If the model predicts well, loss is lower.

### 2.3 Gradient

A gradient tells the training process how each parameter should be adjusted to reduce loss.

Simple way to remember it:

```text
gradient = direction and strength of parameter adjustment
```

If the model has many weights, the gradient tells the training process something like:

```text
weight_1: increase a little
weight_2: decrease a lot
weight_3: almost no change
...
```

The optimizer then updates the model parameters based on gradients.

Simplified formula:

```text
new_weight = old_weight - learning_rate * gradient
```

For this project, the important point is not the math. The important point is:

```text
Distributed training creates gradients on multiple workers, and those gradients need to be synchronized.
```

---

## 3. Why Distributed Training Needs Network Communication

In a single-node or single-GPU training job, the model calculates gradients locally and updates the model locally.

In distributed training, multiple GPUs or multiple worker nodes participate.

Example with four workers:

```text
Worker01 processes batch A -> calculates gradient g1
Worker02 processes batch B -> calculates gradient g2
Worker03 processes batch C -> calculates gradient g3
Worker04 processes batch D -> calculates gradient g4
```

These workers are training the same model. They should not update their model copies independently using different gradients. They need to combine their gradients, usually by averaging them.

Simplified example:

```text
average_gradient = (g1 + g2 + g3 + g4) / 4
```

Then all workers update their model copies using the same synchronized gradient.

This gradient synchronization is one of the main reasons AI training creates heavy east-west traffic.

---

## 4. NCCL and Collective Communication

NCCL stands for NVIDIA Collective Communications Library.

From a network engineer's point of view, NCCL is the library that helps GPU workloads perform high-performance communication between GPUs and workers.

NCCL is commonly used for collective communication patterns such as:

- Broadcast
- Reduce
- AllReduce
- AllGather
- ReduceScatter

Collective communication means multiple workers participate in a coordinated data exchange. It is different from a simple client-server request.

Assume four workers:

```text
W1
W2
W3
W4
```

Each worker has some local data:

```text
W1 = A
W2 = B
W3 = C
W4 = D
```

The following sections explain the key collective operations.

---

### 4.1 Broadcast

Broadcast means one worker sends its data to all workers.

Before:

```text
W1 = A
W2 = -
W3 = -
W4 = -
```

After Broadcast from W1:

```text
W1 = A
W2 = A
W3 = A
W4 = A
```

Network pattern:

```text
one-to-many
```

Common use cases:

- distribute initial parameters
- distribute configuration or metadata
- send the same data from one rank to all other ranks

Network engineer view:

```text
A single source sends data to multiple destinations.
```

---

### 4.2 Reduce

Reduce means multiple workers combine their data into one result.

The combine operation can be:

- sum
- average
- max
- min

Example:

```text
W1 = 10
W2 = 20
W3 = 30
W4 = 40
```

Reduce SUM:

```text
10 + 20 + 30 + 40 = 100
```

If the result is stored on W1:

```text
W1 = 100
W2 = -
W3 = -
W4 = -
```

Network pattern:

```text
many-to-one + combine
```

In training, reduce is often used conceptually to combine gradients.

---

### 4.3 AllReduce

AllReduce means:

```text
Reduce + distribute the reduced result to all workers
```

Example before AllReduce:

```text
W1 = 10
W2 = 20
W3 = 30
W4 = 40
```

Reduce SUM:

```text
10 + 20 + 30 + 40 = 100
```

After AllReduce SUM:

```text
W1 = 100
W2 = 100
W3 = 100
W4 = 100
```

If using average:

```text
100 / 4 = 25
```

After AllReduce AVG:

```text
W1 = 25
W2 = 25
W3 = 25
W4 = 25
```

DDP training commonly relies on AllReduce for gradient synchronization.

Simplified DDP gradient example:

```text
W1 gradient = g1
W2 gradient = g2
W3 gradient = g3
W4 gradient = g4
```

AllReduce average:

```text
average_gradient = (g1 + g2 + g3 + g4) / 4
```

After AllReduce, every worker has the same average gradient and can update its local model copy consistently.

Network pattern:

```text
many-to-many collective traffic
```

Network engineer view:

```text
AllReduce can generate repeated high-volume east-west traffic during the training loop.
```

---

### 4.4 AllGather

AllGather means every worker sends its data to all workers, and every worker ends up with everyone else's data.

Before:

```text
W1 = A
W2 = B
W3 = C
W4 = D
```

After AllGather:

```text
W1 = A+B+C+D
W2 = A+B+C+D
W3 = A+B+C+D
W4 = A+B+C+D
```

AllGather does not combine values into a single sum or average. It collects all pieces and keeps them.

Difference from AllReduce:

```text
AllReduce: combine A+B+C+D into one result
AllGather: collect A, B, C, D and keep all original pieces
```

Network pattern:

```text
all-to-all style data exchange
```

Network engineer view:

```text
AllGather can create broad east-west fan-out where every worker needs data from every other worker.
```

---

### 4.5 ReduceScatter

ReduceScatter means:

```text
Reduce first, then split the reduced result across workers.
```

Example:

```text
W1 = [1, 2, 3, 4]
W2 = [10, 20, 30, 40]
W3 = [100, 200, 300, 400]
W4 = [1000, 2000, 3000, 4000]
```

First reduce by position:

```text
[1+10+100+1000,
 2+20+200+2000,
 3+30+300+3000,
 4+40+400+4000]

= [1111, 2222, 3333, 4444]
```

Then scatter the result:

```text
W1 = 1111
W2 = 2222
W3 = 3333
W4 = 4444
```

ReduceScatter is useful because some optimized collective strategies can use:

```text
ReduceScatter + AllGather
```

as part of an efficient AllReduce implementation.

Network pattern:

```text
many-to-many collective traffic with partitioned results
```

Network engineer view:

```text
Not every worker receives the full reduced result immediately. The result is partitioned across workers, which can improve communication efficiency.
```

---

### 4.6 Collective Operations Summary

| Operation | Simple Meaning | Network Pattern | Result |
|---|---|---|---|
| Broadcast | One worker sends data to all workers | one-to-many | all workers get the same data |
| Reduce | Many workers combine data into one result | many-to-one | one worker gets the combined result |
| AllReduce | Reduce, then all workers receive the result | many-to-many | all workers get the same combined result |
| AllGather | All workers collect all workers' data | all-to-all style | all workers get all original data |
| ReduceScatter | Reduce, then split the result across workers | many-to-many | each worker gets one part of the reduced result |

For AI training, the most important operations to understand first are:

- AllReduce
- ReduceScatter
- AllGather

AllReduce is especially important because gradient synchronization in DDP often depends on it.

---

## 5. DDP and Network Traffic

DDP stands for Distributed Data Parallel.

In a DDP training job:

- each GPU or worker has a copy of the model
- each worker processes a different batch of data
- each worker calculates local gradients
- workers synchronize gradients after each training step
- each worker updates its local model copy using the synchronized gradients

Simplified flow:

```text
Step 1: Each worker processes a different data batch
Step 2: Each worker calculates local gradients
Step 3: NCCL AllReduce synchronizes gradients
Step 4: Each worker updates its model copy
Step 5: Repeat for the next training step
```

Network implication:

```text
DDP puts communication inside the training loop.
```

That means network issues can directly slow down training.

Important DDP network characteristics:

- repeated east-west traffic
- sensitivity to bandwidth for large gradient transfers
- sensitivity to latency and jitter for smaller collective operations
- sensitivity to packet loss and congestion
- dependency on correct GPU/RDMA interface selection
- dependency on ECMP and fabric load balancing behavior

For a network engineer, DDP does not mean you need to become a PyTorch developer.

The important relationship is:

```text
DDP uses NCCL collectives -> NCCL uses network transport -> fabric quality affects training performance
```

---

## 6. vLLM and Inference Traffic

vLLM is a high-performance inference engine for serving large language models.

A simple single-GPU inference service may look like normal API traffic:

```text
client -> API endpoint -> vLLM server
```

However, at larger scale, vLLM deployments can involve more network paths:

- external API ingress traffic
- Kubernetes Service / Ingress / LoadBalancer traffic
- Ray or KubeRay control and worker traffic
- model loading from shared storage
- multi-GPU tensor parallelism
- multi-node inference communication
- observability and logging traffic

A simplified larger inference flow:

```text
client
  -> API ingress / load balancer
  -> vLLM frontend
  -> GPU workers
  -> model storage / cache
  -> response back to client
```

From a network perspective, vLLM is important because inference is not always just simple north-south API traffic.

At scale, it may depend on:

- stable API ingress
- low-latency GPU-to-GPU or node-to-node communication
- fast model loading from storage
- correct network path selection inside Kubernetes
- reliable service discovery and control-plane communication

Network engineer view:

```text
vLLM may combine north-south API traffic, east-west GPU communication, and storage traffic.
```

For this project, the goal is not to become a vLLM application developer.

The goal is to understand what network paths vLLM may use and how to validate that the infrastructure does not become the bottleneck.

---

## 7. RoCE, InfiniBand, and NCCL Path Selection

NCCL can use different transport paths depending on the environment.

Common examples:

- TCP/socket over normal Ethernet
- RoCE over Ethernet RDMA
- InfiniBand RDMA
- GPU direct paths when supported

For AI fabric validation, it is important to confirm which path is actually being used.

A workload may appear to run, but it might be using the wrong interface or a slower path.

Common problems:

- NCCL uses the management interface instead of the high-speed fabric
- NCCL uses TCP when RDMA was expected
- NCCL selects the wrong HCA
- NCCL selects the wrong GID index
- RoCEv2 is configured, but the workload does not use it
- traffic takes a non-optimal path through the fabric

Useful NCCL variables include:

```bash
NCCL_SOCKET_IFNAME
NCCL_IB_HCA
NCCL_IB_GID_INDEX
NCCL_DEBUG
NCCL_DEBUG_SUBSYS
```

---

## 8. Important NCCL Network Environment Variables

### 8.1 `NCCL_SOCKET_IFNAME`

`NCCL_SOCKET_IFNAME` selects the Linux network interface for socket-based communication.

Example:

```bash
export NCCL_SOCKET_IFNAME=eth1
```

Meaning:

```text
Use eth1 for NCCL socket communication.
```

This is most relevant when NCCL uses TCP/socket transport.

Network engineer view:

```text
This is similar to telling the application which Linux interface to use for normal IP communication.
```

---

### 8.2 `NCCL_IB_HCA`

`NCCL_IB_HCA` selects the RDMA device, also called the HCA.

HCA means Host Channel Adapter.

Example:

```bash
export NCCL_IB_HCA=mlx5_0
```

Meaning:

```text
Use RDMA device mlx5_0.
```

On hosts with multiple NVIDIA/Mellanox NICs, this is important.

Example device layout:

```text
mlx5_0 = RoCE interface
mlx5_1 = InfiniBand interface
```

If NCCL chooses the wrong HCA, the workload may use the wrong fabric or fail to connect.

---

### 8.3 `NCCL_IB_GID_INDEX`

`NCCL_IB_GID_INDEX` selects which GID table entry to use on the RDMA device.

Example:

```bash
export NCCL_IB_HCA=mlx5_0
export NCCL_IB_GID_INDEX=3
```

Meaning:

```text
Use RDMA device mlx5_0, and use GID table index 3 for RDMA/RoCE communication.
```

Important warning:

```text
GID index 3 is not universally correct.
```

A common mistake is to copy `NCCL_IB_GID_INDEX=3` from an example without checking the actual GID table on the host.

The correct GID index depends on the NIC, driver, OS, IP address, VLAN configuration, RoCE mode, and environment.

---

## 9. What Is GID?

GID stands for Global Identifier.

In the RDMA world, a GID is a 128-bit identifier used as an RDMA endpoint identity.

Simple memory version:

```text
GID = RDMA address identity for a port/interface context
```

It is not the same thing as a normal IP address, but in RoCEv2 it is often related to IP/interface configuration.

---

### 9.1 GID Compared with Familiar Network Concepts

| Concept | Meaning |
|---|---|
| Interface | physical or logical network interface |
| IP address | Layer 3 address used for IP communication |
| VLAN | Layer 2 segmentation / tag |
| VRF | separate routing table / routing context |
| GID | RDMA endpoint identifier used by the RDMA stack |

Best simplified analogy:

```text
GID is closest to an RDMA endpoint address identity.
```

But it is not exactly the same as IP, VLAN, or VRF.

---

### 9.2 GID, GUID, and LID

In InfiniBand and RDMA terminology, you may see several similar terms.

| Term | Simplified Meaning |
|---|---|
| GUID | globally unique hardware identifier, like a device or port identity |
| LID | Local Identifier used inside an InfiniBand subnet |
| GID | Global Identifier used as an RDMA endpoint identity |

Simplified memory version:

```text
GUID = hardware identity
LID  = local IB fabric forwarding identity
GID  = global RDMA endpoint identity
```

---

### 9.3 GID Table

A Mellanox / NVIDIA ConnectX device may have a GID table.

Example conceptually:

```text
mlx5_0 port 1 GID table:

Index  GID value                         Type / Context
0      fe80::xxxx                        link-local / default
1      fe80::yyyy                        RoCE-related link-local
2      ::ffff:172.16.1.1                 IPv4-mapped / RoCE context
3      0000:0000:0000:0000:ffff:ac10:0101 RoCEv2 context for 172.16.1.1
```

This is only an example. Real output depends on the host.

`NCCL_IB_GID_INDEX` tells NCCL which row in this table to use.

Example:

```bash
export NCCL_IB_HCA=mlx5_0
export NCCL_IB_GID_INDEX=3
```

Meaning:

```text
Use RDMA device mlx5_0, and use GID table entry 3 on that device.
```

---

### 9.4 Is GID Like a VLAN?

No. GID is not a VLAN.

A VLAN is a Layer 2 segmentation mechanism and tag.

A GID is an RDMA endpoint identifier.

However, VLAN configuration may influence the GID table.

Example:

```text
eth1.100 = 172.16.100.11
eth1.200 = 172.16.200.11
```

The RDMA stack may create different GID table entries related to those interfaces or IP addresses.

So the correct relationship is:

```text
VLAN/IP/interface configuration may affect which GIDs exist.
GID selection may indirectly select an RDMA identity associated with a certain interface/IP context.
But GID is not VLAN.
```

---

### 9.5 Is GID Like a VRF?

No. GID is not a VRF.

A VRF is a separate routing table or routing context.

A GID is not a routing table and does not represent a routing domain by itself.

In complex designs, VRFs may indirectly affect which interface, source address, or route is used. But GID itself is still an RDMA endpoint identity, not a VRF.

Correct memory version:

```text
GID = RDMA endpoint identity
VRF = Layer 3 routing table isolation
VLAN = Layer 2 segmentation
```

---

### 9.6 Why Wrong GID Selection Breaks Things

If NCCL uses the wrong GID, it may select the wrong RDMA identity.

Possible symptoms:

- NCCL sees a device but RDMA communication fails
- RoCE connection cannot be established
- workload uses the wrong interface
- nodes use mismatched GID types
- traffic does not use the expected RoCEv2 path
- performance is much worse than expected

Validation should not blindly assume the correct GID index.

Useful checks include:

```bash
show_gids
ibv_devinfo
ibdev2netdev
ip addr
ip route
```

The practical question is:

```text
Which GID entry corresponds to the RoCEv2 interface/IP that this workload should use?
```

---

## 10. Network Validation Beyond Ping

Ping only proves basic IP reachability.

It does not prove:

- high bandwidth
- low latency under load
- stable east-west traffic
- RDMA readiness
- correct NCCL path selection
- correct GID selection
- correct ECMP behavior
- lossless or congestion behavior
- workload-level stability

For AI fabric validation, use layered checks.

---

### 10.1 Basic Network Checks

Examples:

```bash
ip addr
ip route
ping
traceroute
```

Questions:

- Are all expected interfaces up?
- Are IP addresses correct?
- Are routes correct?
- Are hosts reachable?
- Is traffic using the expected fabric, not the management network?

---

### 10.2 Throughput and Latency Checks

Examples:

```bash
iperf3
ping -f
qdisc counters
interface counters
```

Questions:

- What bandwidth can the path sustain?
- Does latency increase under load?
- Are there drops, errors, or retransmissions?
- Does many-to-many traffic behave differently from one-to-one traffic?

---

### 10.3 RDMA Checks

Examples:

```bash
ibv_devinfo
ibdev2netdev
show_gids
ib_write_bw
ib_write_lat
```

Questions:

- Are RDMA devices visible?
- Which Linux interface maps to which RDMA device?
- Which GID index should be used?
- Can RDMA bandwidth and latency tests run successfully?
- Is RoCEv2 or InfiniBand being used as expected?

---

### 10.4 NCCL Checks

Examples:

```bash
NCCL_DEBUG=INFO
NCCL_DEBUG_SUBSYS=INIT,NET
NCCL_SOCKET_IFNAME=eth1
NCCL_IB_HCA=mlx5_0
NCCL_IB_GID_INDEX=<correct-index>
```

Questions:

- Which network transport does NCCL use?
- Which interface does NCCL select?
- Which HCA does NCCL select?
- Which GID index does NCCL use for RoCE?
- Does NCCL fall back to a slower path?
- Do collective tests complete successfully?

---

### 10.5 Workload-Level Checks

For DDP:

- Does training start successfully?
- Do all workers join the job?
- Does gradient synchronization complete?
- Does training progress without communication errors?
- Does throughput drop under network load?

For vLLM:

- Does the API respond reliably?
- Does the service scale without startup failures?
- Does model loading create storage bottlenecks?
- Does multi-GPU or multi-node inference use the expected path?
- Does latency increase under load?

---

## 11. Example Validation Matrix

| Layer | What to Validate | Example Checks |
|---|---|---|
| Host networking | IP and route correctness | `ip addr`, `ip route`, `ping` |
| Fabric | underlay/overlay reachability | BGP, EVPN, ECMP, interface counters |
| Throughput | bandwidth and latency | `iperf3`, latency under load |
| RDMA | device and path readiness | `ibv_devinfo`, `show_gids`, `ib_write_bw` |
| NCCL | communication library path | `NCCL_DEBUG=INFO`, NCCL tests |
| DDP | training communication | gradient sync, job progress, training throughput |
| vLLM | inference communication | API latency, scaling, model loading, multi-GPU path |
| Operations | observability and troubleshooting | counters, logs, telemetry, alerts |

---

## 12. Practical Network Engineer Takeaways

A network engineer working toward AI infrastructure should understand the following:

1. AI training creates repeated east-west traffic inside the training loop.
2. Gradients are parameter adjustment directions calculated during training.
3. Distributed workers calculate gradients locally and then synchronize them.
4. NCCL provides high-performance collective communication for GPU workloads.
5. AllReduce is central to gradient synchronization in DDP training.
6. Broadcast, Reduce, AllGather, and ReduceScatter represent different multi-worker communication patterns.
7. DDP creates repeated east-west collective communication.
8. vLLM inference can involve API ingress, storage traffic, and sometimes multi-GPU or multi-node communication.
9. RoCE and InfiniBand are high-speed network paths that NCCL may use.
10. `NCCL_SOCKET_IFNAME` selects the Linux socket interface.
11. `NCCL_IB_HCA` selects the RDMA device.
12. `NCCL_IB_GID_INDEX` selects the RDMA GID table entry.
13. GID is not VLAN and not VRF; it is an RDMA endpoint identity.
14. Ping is not enough. AI fabric validation must include bandwidth, latency, RDMA, NCCL, and workload-level checks.

---

## 13. How This Fits the Lab Project

This document connects the lower-level fabric labs to AI workload requirements.

Existing and future labs can map to this model:

```text
FRR / SONiC / Cumulus fabric
-> underlay and overlay validation
-> RoCE / RDMA readiness concepts
-> NCCL communication awareness
-> DDP and vLLM workload path understanding
-> AI fabric validation matrix
```

