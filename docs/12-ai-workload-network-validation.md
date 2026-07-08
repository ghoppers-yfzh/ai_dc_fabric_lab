# AI Workload Network Validation Notes

## Purpose

This note explains how common AI workloads create network requirements and how a network engineer can validate whether the fabric is ready for those workloads.

The focus is not model development. The focus is the network path used by distributed training, inference, and shared storage.

---

## Why Workload Awareness Matters

A data center fabric can look healthy from a traditional routing perspective while still being unsuitable for AI workloads.

Traditional network validation often proves:

- interfaces are up
- BGP sessions are established
- routes are installed
- hosts can ping each other
- overlay reachability works
- basic throughput is available

AI workload validation goes further. It asks whether the fabric can support sustained east-west traffic with low loss, low latency, and predictable congestion behavior.

For GPU workloads, the network is not just a transport layer. It is part of the compute pipeline. Slow or unstable GPU-to-GPU communication can reduce training throughput, cause job instability, or make distributed inference unreliable.

---

## Common AI Workload Patterns

### 1. Distributed Training

Distributed training usually spreads one training job across multiple GPUs, often across multiple hosts.

The important network pattern is east-west communication between GPU workers.

Typical characteristics:

- frequent synchronization between workers
- high bandwidth demand
- sensitivity to packet loss and congestion
- performance depends on both the network fabric and the communication library

The network engineer does not need to become a machine learning engineer, but should understand why training jobs need fast and stable GPU-to-GPU communication.

### 2. Distributed Inference

Large model inference may use multiple GPUs when one GPU cannot hold the whole model or when higher throughput is required.

Typical characteristics:

- traffic may be more request-driven than training
- tensor-parallel or pipeline-parallel inference can create GPU-to-GPU communication
- external API traffic is usually north-south
- model shard synchronization and token generation paths may still depend on east-west fabric performance

### 3. Shared Model Storage

AI platforms often need to store and load model checkpoints, datasets, and model artifacts.

Typical storage options include:

- local NVMe per node
- NFS or object storage for shared access
- NVMe-oF over RDMA for high-performance shared block storage

Storage access can create separate network requirements from GPU-to-GPU training traffic. In larger designs, it is useful to think about compute fabric, storage fabric, management network, and external service access separately.

---

## NCCL Basics from a Network Perspective

NCCL is a communication library commonly used for multi-GPU and multi-node workloads. From the network perspective, it is important because it decides which network path and transport are used for collective communication.

### Common Collective Operations

| Operation | Network Meaning | Why It Matters |
|---|---|---|
| AllReduce | All workers exchange and reduce data | Common in gradient synchronization |
| Broadcast | One worker sends data to all others | Used for parameter or state distribution |
| AllGather | All workers collect data from all others | Can create heavy all-to-all-like traffic |
| ReduceScatter | Data is reduced and distributed in chunks | Common in optimized distributed training |

The exact application logic can vary, but these operations help explain why AI fabrics need high east-west bandwidth and predictable congestion behavior.

### Ring and Tree Communication Patterns

NCCL can use different algorithms depending on message size, topology, and configuration.

- Ring-style communication is bandwidth-oriented and can create sustained traffic across many links.
- Tree-style communication can reduce latency for some cases but may concentrate traffic differently.

A network validation plan should avoid testing only one traffic pattern. It should consider different message sizes and collective operations.

---

## RoCE and InfiniBand in the AI Stack

### RoCEv2

RoCEv2 carries RDMA over UDP/IP/Ethernet.

Important network dependencies:

- correct MTU design
- consistent QoS classification
- PFC behavior for selected lossless priorities
- ECN marking under congestion
- host-side congestion control such as DCQCN
- RDMA-capable NICs and drivers
- correct GID selection on the host

RoCE is attractive because it uses Ethernet and IP, but it requires careful operational discipline.

### InfiniBand

InfiniBand is common in HPC and large AI training environments.

Important operational concepts:

- Subnet Manager
- GUID and LID addressing
- P_Key partitioning
- fabric discovery and path calculation
- UFM or other fabric management tools
- optional in-network acceleration such as SHARP on supported platforms

InfiniBand is less like traditional Ethernet operations, but it provides a purpose-built model for high-performance fabrics.

---

## NCCL Network-Related Variables

These variables are useful to recognize when reviewing AI workload deployments. Exact values depend on the host, NIC, driver, container runtime, and fabric design.

| Variable | Purpose | Network Engineer View |
|---|---|---|
| `NCCL_SOCKET_IFNAME` | Selects the socket interface | Helps avoid using the management interface by mistake |
| `NCCL_IB_HCA` | Selects RDMA HCA device | Controls whether the job uses the intended RoCE/IB adapter |
| `NCCL_IB_GID_INDEX` | Selects GID index, commonly important for RoCE | Wrong value can send traffic over the wrong GID or fail RDMA path setup |
| `NCCL_IB_DISABLE` | Enables/disables IB/RDMA transport | Useful to compare RDMA vs TCP behavior |
| `NCCL_DEBUG` | Enables NCCL logging | Useful for proving which transport/interface was selected |
| `NCCL_TOPO_DUMP_FILE` | Dumps topology information | Helps correlate GPU/NIC topology with expected data path |

The key validation point is not memorizing every variable. The key is proving that the workload is using the intended network path.

---

## What to Validate

### 1. Basic Fabric Readiness

Evidence to collect:

```bash
ip link show
ip addr show
ip route show
etstat -i
```

Network-side checks:

```bash
show interfaces status
show interfaces counters
show ip bgp summary
show ip route
```

Expected outcome:

- the intended interfaces are up
- MTU is consistent where required
- routing path is predictable
- no unexpected errors or drops are increasing

### 2. RDMA Device Readiness

Example host-side checks:

```bash
ibv_devices
ibv_devinfo
ibstat
ibdev2netdev
rdma link show
```

Expected outcome:

- RDMA devices are visible
- the RDMA device maps to the expected Linux interface
- link state is active
- the intended RoCE or IB interface is selected

### 3. RDMA Connectivity

Example tools:

```bash
ib_write_bw
ib_read_bw
ib_send_bw
ib_write_lat
```

Expected outcome:

- RDMA traffic can pass between hosts
- bandwidth and latency are within expected range for the lab or hardware
- no unexpected transport errors occur during the test

### 4. Lossless Ethernet Behavior for RoCE

Evidence to collect:

- interface pause counters
- PFC counters per priority
- ECN marking counters
- CNP counters on NICs where available
- queue drops and buffer counters

Expected outcome:

- lossless priority behavior is observable when tested
- congestion is signaled rather than converted into packet loss
- unexpected drops do not increase during RDMA tests

### 5. NCCL Path Selection

Example debugging approach:

```bash
export NCCL_DEBUG=INFO
export NCCL_SOCKET_IFNAME=<data-interface>
export NCCL_IB_HCA=<hca-name>
```

Then run a small NCCL test or application workload and review logs for selected transport and interface.

Expected outcome:

- NCCL uses the intended interface
- RDMA transport is enabled when expected
- the job does not silently fall back to the management network or TCP-only path

### 6. Workload-Level Behavior

For training or inference tests, collect:

- job completion status
- throughput
- latency where applicable
- GPU utilization
- NIC counters
- retransmits or drops
- fabric error counters
- application logs

Expected outcome:

- the workload is stable across repeated runs
- performance is reasonably consistent
- network counters do not show hidden instability

---

## Signs That the Wrong Network Path Is Being Used

Common symptoms:

- NCCL logs show an unexpected interface
- the management interface carries heavy traffic during a distributed job
- RDMA counters remain flat while the job is running
- throughput is much lower than expected
- CPU usage is unexpectedly high for communication-heavy workloads
- TCP retransmits increase during the test
- job works on one node but fails or slows down across nodes

These symptoms should trigger a path validation check before deeper application debugging.

---

## Suggested Validation Workflow

```text
1. Validate interface and routing state
2. Validate RDMA devices and NIC-to-interface mapping
3. Validate MTU and QoS assumptions
4. Run basic RDMA tests between hosts
5. Run NCCL tests with debug logging enabled
6. Confirm selected interface and transport
7. Collect network counters during the test
8. Repeat under different message sizes and collective operations
9. Record results in a standard report
10. Convert findings into a reusable validation checklist
```

---

## Repo Artifact Ideas

Possible files to add later:

```text
docs/ai-workload-network-validation.md
validation/rdma-readiness-checklist.md
validation/nccl-readiness-checklist.md
scripts/check-rdma-devices.py
scripts/check-nccl-path.sh
outputs/nccl-baseline-example.md
```

The goal is to make AI workload networking understandable and testable without making model training the center of the project.
