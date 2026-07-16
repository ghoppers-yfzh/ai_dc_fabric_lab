# Advantages and Working Principle of RoCE v2 in RDMA Protocol
https://www.naddod.com/blog/advantages-and-working-principle-of-roce-v2-in-rdma-protocol?utm_source=google&utm_medium=cpc&utm_campaign=23737985215&utm_content=193574847050&utm_term=&google-network=g&creative=816635304172&device=c&gclid=Cj0KCQjw39zSBhDhARIsANammDtc_kAsbFBfzhlx56-qgAutBemM7_TtYZdh-K-DzKt68UUbY3eIkKoaAsV0EALw_wcB&gad_source=1&gad_campaignid=23737985215&gbraid=0AAAAAo1cgk28Gva7RXC-cNMhwkaAOY2Rh&gclid=Cj0KCQjw39zSBhDhARIsANammDtc_kAsbFBfzhlx56-qgAutBemM7_TtYZdh-K-DzKt68UUbY3eIkKoaAsV0EALw_wcB

---

## 1. NCCL: What It Is

**NCCL** stands for **NVIDIA Collective Communications Library**

It is a software library used to move data efficiently between NVIDIA GPUs.

NCCL provides communication operations commonly required by distributed AI workloads, including:

- AllReduce
- ReduceScatter
- AllGather
- Broadcast
- Reduce
- Point-to-point Send and Receive

NCCL is not a machine learning framework. It is a communication library used by frameworks and applications that need multiple GPUs to work together.

A simple mental model is:

```text
PyTorch / AI application
        |
        | needs GPUs to exchange tensors
        v
       NCCL
        |
        | selects and executes a communication pattern
        v
NVLink / PCIe / Ethernet / InfiniBand
```

### Where NCCL Fits

NCCL is above the RDMA transport layer.

```text
AI Application / Framework
            |
           NCCL
            |
  NCCL Network Transport
            |
  RDMA libraries / Verbs
            |
           RNIC
            |
     RoCEv2 packets
            |
     Ethernet fabric
```

NCCL does not itself mean RoCEv2. Depending on the system and topology, NCCL can use technologies such as NVLink, NVSwitch, PCIe, shared memory, TCP sockets, InfiniBand, or RoCE-capable networking.

---

## 2. QP: Queue Pair

A **Queue Pair**, or **QP**, is one of the most important RDMA concepts.

A QP contains two work queues:

```text
Queue Pair
├── Send Queue
└── Receive Queue
```

The word **pair** refers to this pair of queues.

### Plain-Language Model

Think of a QP as:

> A hardware-managed RDMA communication context with an outgoing task queue and an incoming-buffer queue.

A QP is sometimes compared with a socket because both represent a communication endpoint. However, they are not identical.

```text
Socket model:
Application -> Kernel TCP/IP stack -> NIC

QP model:
Application -> Work Queue -> RNIC
```

### Send Queue

The application places outgoing RDMA operations into the Send Queue.

Examples include:

- Send
- RDMA Write
- RDMA Read
- Atomic operation

### Receive Queue

For operations that require a posted receive buffer, the application prepares buffers by posting Receive Work Requests to the Receive Queue.

This tells the RNIC:

> If an incoming Send operation arrives, this memory buffer is ready to receive it.

RDMA Write behaves differently because the sender specifies the registered remote memory destination.

### What a QP Tracks

A QP can contain or reference state such as:

- local QP number
- remote QP number
- transport type
- path information
- path MTU
- packet sequence numbers
- retry settings
- access permissions
- current QP state

For a Reliable Connected QP, the local QP is associated with a specific remote QP.

```text
Host A: QP 100  <------>  Host B: QP 200
```

### The Most Useful QP Analogy

```text
IP address       = which server?
UDP port 4791    = which protocol?
Destination QP   = which RDMA communication context inside the RNIC?
```

### Related Objects

```text
Memory Region
     |
     | provides registered buffers and access keys
     v
Work Request
     |
     | submitted to
     v
Queue Pair
     |
     | executed by
     v
RNIC
     |
     | reports completion through
     v
Completion Queue
```

#### Memory Region, MR

A registered memory area that the RNIC is allowed to access.

It includes:

- address
- length
- permissions
- local key, `lkey`
- remote key, `rkey`

```text
lkey = permission used by the local RNIC
rkey = permission presented for remote access
```

The keys are access tokens, not encryption keys.

#### Work Request, WR

A high-level task submitted by the application.

```text
Operation:       RDMA WRITE
Local buffer:    0x100000
Length:          4096 bytes
Remote address:  0x800000
Remote rkey:     0x87654321
```

#### Work Queue Element, WQE

The hardware queue representation of a submitted Work Request.

```text
Work Request -> Work Queue Element -> RNIC execution
```

#### Completion Queue, CQ

The RNIC places completion results into a Completion Queue.

```text
Application posts work
        |
        v
RNIC executes work
        |
        v
Completion Queue Entry
        |
        v
Application checks result
```

---

## 3. Do Not Mix the Software Path with the Packet Stack

### Host Execution Path

```text
Application / NCCL / Storage Software
                  |
                  v
        RDMA library / Verbs
                  |
                  v
       Memory Region + QP + CQ
                  |
                  v
           Work Request
                  |
                  v
                RNIC
```

### On-Wire Packet Stack

```text
Ethernet
  └── IPv4 / IPv6
        └── UDP destination port 4791
              └── InfiniBand transport headers
                    ├── BTH
                    ├── optional RETH / AETH / other headers
                    ├── RDMA data
                    └── ICRC
```

### Key Distinction

```text
RDMA Verbs, QP and Work Request
    = how the host asks the RNIC to do work

BTH, RETH and AETH
    = how the RNIC represents RDMA transport information in packets
```

---

## 4. RoCEv2 Packet Structure

```text
+-----------------------------+
| Ethernet Header             |
+-----------------------------+
| Optional VLAN Header        |
+-----------------------------+
| IPv4 or IPv6 Header         |
+-----------------------------+
| UDP Header                  |
+-----------------------------+
| Base Transport Header, BTH  |
+-----------------------------+
| Optional Extended Header    |
| RETH / AETH / ImmDt / ...   |
+-----------------------------+
| RDMA Data                   |
+-----------------------------+
| Padding                     |
+-----------------------------+
| ICRC                        |
+-----------------------------+
| Ethernet FCS                |
+-----------------------------+
```

From the UDP point of view:

```text
UDP Header
└── UDP Payload
    ├── BTH
    ├── optional extended transport header
    ├── RDMA data
    ├── padding
    └── ICRC
```

The RDMA transport information is not stored in the UDP header.

The UDP header contains only:

```text
Source Port
Destination Port
Length
Checksum
```

For RoCEv2, the default UDP destination port is `4791`.

---

## 5. The Most Important Memory Model

```text
Ethernet:
Which next hop?

IP:
Which host?

UDP 4791:
Which protocol?

BTH:
Which QP, which operation, and which packet sequence?

RETH:
Which remote memory address, which access key, and how many bytes?
```

> MAC finds the next hop, IP finds the host, UDP finds RoCE, BTH finds the QP, and RETH finds the remote memory.

```text
MAC  -> next hop
IP   -> destination host
UDP  -> RoCEv2
BTH  -> QP, operation and packet sequence
RETH -> remote address, rkey and length
Data -> actual bytes
ICRC -> RDMA transport integrity
FCS  -> Ethernet frame integrity
```

---

## 6. BTH: Base Transport Header

The **Base Transport Header** is the core InfiniBand transport header.

Important BTH information includes:

- Opcode
- Destination QP
- Packet Sequence Number, PSN
- Acknowledge Request
- Pad count
- other transport control fields

### Opcode

The Opcode answers:

> What RDMA transport operation is this packet performing?

Examples include:

```text
RDMA WRITE FIRST
RDMA WRITE MIDDLE
RDMA WRITE LAST
RDMA WRITE ONLY

RDMA READ REQUEST
RDMA READ RESPONSE FIRST
RDMA READ RESPONSE MIDDLE
RDMA READ RESPONSE LAST
RDMA READ RESPONSE ONLY

ACKNOWLEDGE
```

`ONLY` means that the complete message fits in one packet.

### Destination QP

The Destination QP tells the receiving RNIC which communication context should process the packet.

### Packet Sequence Number

The PSN helps the Reliable Connected transport detect ordering problems and missing packets.

```text
Expected: 100, 101, 102, 103
Received: 100, 101, 103
```

---

## 7. RETH: RDMA Extended Transport Header

The **RETH** describes a remote memory operation.

```text
RETH
├── Virtual Address
├── R_Key
└── DMA Length
```

```text
Virtual Address -> where in remote memory?
R_Key           -> is remote access permitted?
DMA Length      -> how many bytes?
```

Memory aid:

> RETH means Remote memory information.

RETH is commonly used with:

- RDMA Write first or only packet
- RDMA Read Request

---

## 8. AETH: Acknowledgement Extended Transport Header

The **AETH** carries acknowledgement or response state.

It can be associated with:

- ACK
- NAK
- Receiver Not Ready, RNR NAK
- RDMA Read Response

```text
RETH -> Remote memory
AETH -> Acknowledgement
```

---

## 9. Four Packet Patterns to Remember

### 9.1 RDMA Write

```text
Ethernet | IP | UDP | BTH | RETH | Data | ICRC
```

A Write must identify the remote destination memory, so it needs RETH.

### 9.2 RDMA Read Request

```text
Ethernet | IP | UDP | BTH | RETH | ICRC
```

A Read Request contains the remote address, key, and length, but normally not the requested application data.

### 9.3 RDMA Read Response

```text
Ethernet | IP | UDP | BTH | AETH | Data | ICRC
```

A Read Response returns the requested data and response state.

### 9.4 ACK

```text
Ethernet | IP | UDP | BTH | AETH | ICRC
```

An ACK reports acknowledgement state and does not need application data.

### Condensed Version

```text
Write:
BTH + RETH + Data

Read Request:
BTH + RETH

Read Response:
BTH + AETH + Data

ACK:
BTH + AETH
```

---

## 10. Large RDMA Write Example

```text
First packet:
BTH + RETH + first data segment

Middle packet:
BTH + next data segment

Last packet:
BTH + final data segment
```

RETH is normally required only in the first packet because it already provides the starting remote address, remote key, and total operation length.

---

## 11. What the Network Switch Usually Examines

### Ethernet

- source and destination MAC
- VLAN
- priority code point, PCP

### IP

- source and destination IP
- DSCP
- ECN
- TTL or Hop Limit

### UDP

- source port
- destination port 4791

The switch does not normally need to understand remote virtual address, rkey, destination QP, packet sequence number, or the RDMA application's meaning.

```text
Ethernet
└── IP ECN bits       <- switch marks congestion here
    └── UDP
        └── BTH       <- RNIC processes RDMA transport here
```

---

## 12. What to Remember Now

1. NCCL is a GPU communication library.
2. QP contains a Send Queue and a Receive Queue.
3. Applications submit Work Requests; RNICs execute them.
4. QP is a hardware-managed RDMA communication context.
5. RoCEv2 uses UDP/IP/Ethernet.
6. RoCEv2 normally uses UDP destination port 4791.
7. RDMA transport headers are inside the UDP payload.
8. BTH identifies the operation, destination QP, and sequence.
9. RETH identifies remote memory, access key, and length.
10. ECN marking is carried in the IP header.

```text
MAC -> IP -> UDP -> BTH -> RETH
hop    host   RoCE   QP     memory
```

```text
Write         = RETH + Data
Read Request  = RETH
Read Response = AETH + Data
ACK           = AETH
```

---

## 13. What Only Needs Familiarity for Now

These topics do not need to be memorized yet:

- every Opcode value
- exact BTH bit layout
- all QP states
- every QP transport type
- exact ACK and retry rules
- Immediate Data details
- ICRC calculation
- all RDMA CM connection steps
- every NCCL algorithm
- detailed RNIC implementation
- exact DCQCN rate-update formula

Return to these only when a lab, packet capture, configuration task, or troubleshooting case requires them.

---

## 14. Article Note: NADDOD RoCEv2 Introduction

### Article

`Advantages and Working Principle of RoCE v2 in RDMA Protocol`

### Useful Takeaways

- RoCEv2 carries RDMA transport over UDP/IP/Ethernet.
- RoCEv2 is routable.
- RNIC offload reduces CPU involvement in the fast data path.
- RDMA can reduce intermediate software copying.
- RoCE deployment requires careful congestion management.
- PFC, ECN, queue design, and operations matter.

### Corrections and Qualifications

- The CPU is not completely absent.
- Multi-queue or QP concepts were not invented by RoCEv2.
- RoCEv2 is not hardware-independent.
- Switches do not exchange QP or memory information during RDMA connection establishment.
- RDMA information is not carried in the UDP header. It is in the UDP payload.
- RoCEv2 performance does not come simply from using UDP instead of TCP.
- A more accurate explanation is registered memory, kernel bypass, RNIC offload, RDMA transport, and controlled congestion behavior.

### Main Mental Model

```text
Application decides the communication operation.
NCCL may organize GPU collective communication.
RDMA Verbs submit work.
QP holds communication work queues and state.
RNIC converts work into RoCEv2 packets.
The Ethernet fabric forwards and manages congestion.
The remote RNIC processes the RDMA transport and accesses registered memory.
```

---


## 16. Short Glossary

| Term | Meaning |
|---|---|
| NCCL | NVIDIA library for efficient communication between GPUs |
| Collective communication | One coordinated communication operation involving a group of participants |
| RDMA | Direct data movement between registered memory regions with RNIC assistance |
| RNIC | RDMA-capable network interface card |
| Verbs | API used to create RDMA resources and submit work |
| MR | Registered Memory Region accessible to the RNIC |
| QP | Queue Pair containing a Send Queue and Receive Queue |
| SQ | Send Queue |
| RQ | Receive Queue |
| WR | Work Request submitted by an application |
| WQE | Hardware work-queue representation of a Work Request |
| CQ | Completion Queue |
| CQE | Completion Queue Entry |
| BTH | Base Transport Header |
| RETH | RDMA Extended Transport Header containing remote-memory information |
| AETH | Acknowledgement Extended Transport Header |
| PSN | Packet Sequence Number |
| `lkey` | Local memory access key |
| `rkey` | Remote memory access key |
| ICRC | InfiniBand/RDMA transport integrity checksum |
| ECN | IP-layer congestion notification |
| RoCEv2 | InfiniBand RDMA transport carried over UDP/IP/Ethernet |

---


# RoCE networks for distributed AI training at scale

https://engineering.fb.com/2024/08/05/data-center-engineering/roce-network-distributed-ai-training-at-scale/

# RoCE Storage Implementation over NX-OS VXLAN Fabrics

https://www.cisco.com/c/en/us/td/docs/dcn/whitepapers/roce-storage-implementation-over-nxos-vxlan-fabrics.html

# Hands-On with RoCE: Simulation & Packet Analysis

https://blog.charlesmcchan.com/hands-on-with-roce-simulation-packet-analysis-0729816b39f8



