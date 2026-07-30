# What does Upper Layer do
It connect the application, management software with Tranport layer.
- Upper Layer Protocols # What does the application want IB to do
- Management Services   # Who discovers/configs/manages IB fabric
- Transport Verbs       # How does the Application use HCA to send/receive/access RAM

```
Applications
├── MPI / HPC applications
├── TCP/IP applications
├── Storage applications
└── Management software
          │
          ▼
Upper Layer
├── Upper Layer Protocols
│   ├── MPI
│   ├── IPoIB
│   ├── SDP
│   ├── SRP
│   ├── iSER
│   └── NFS over RDMA
│
├── Management Services
│   ├── SMP → QP 0 → VL 15
│   └── GMP → QP 1 → VL 0 by default
│
└── Transport Verbs
    ├── Post Send
    ├── Post Receive
    ├── RDMA Write
    └── RDMA Read
          │
          ▼
HCA / InfiniBand Transport
```
# Upper Layer Protocols
It is a group of protocols for IB service

## MPI 
Message Passing Interface
## IPoIB 
IP application on IB, make IB to work on  ipv4/ipv6, IPoIB encapsulation
```
Application
    ↓
TCP / UDP
    ↓
IP
    ↓
IPoIB encapsulation
    ↓
InfiniBand transport
    ↓
InfiniBand Fabric
```

## SDP 
Sockets Direct Protocol, Normal socket application > SDP > IB
## SRP 
SCSI RDMA Protocol
```
SCSI Write command:

Initiator A memory
       │
       │  Target performs RDMA Read
       ▼
Target B
       │
       ▼
Storage
```

```
SCSI Read command:

Storage
   │
Target B
   │
   │  Target performs RDMA Write
   ▼
Initiator A memory
```

## iSER
iSCSI on RDMA

```
SCSI
  ↓
iSCSI
  ↓
iSER
  ↓
RDMA
  ↓
IB / RoCE / iWARP
```

Difference between SRP and iSER
```
SRP:
SCSI command
    ↓
SRP
    ↓
RDMA

iSER:
SCSI command
    ↓
iSCSI
    ↓
iSER
    ↓
RDMA
```

## NFS over RDMA

```
NFS
 ↓
RPC
 ↓
RPC-over-RDMA
 ↓
RDMA
```

## Summary for the protocols
```
Compute
└── MPI

Traditional IP networking
└── IPoIB

Traditional socket compatibility
└── SDP

Block storage
├── SRP  → native SCSI over RDMA
└── iSER → iSCSI over RDMA

File storage
└── NFS over RDMA
```

# management Service
- MAD
- SMP
- GMP

## MAD
Management Datagram
```
MAD
├── SMP — Subnet Management Packet
└── GMP — General Management Packet
```

SMP
```
SMP
├── Destination QP: QP 0
├── Virtual Lane: VL 15
├── Routing:
│   ├── Direct Route
│   └── LID Route
└── Flow Control without VL's Credit
```

QP 0 is reserved for Subnet management
VL15 is reserved for Subnet management 

## SMP
Direct Route, doesn't rely on LID forwarding table.
It is used for topology discover when the LID hasn't been allocated.
```
SM
 │ port 2
 ▼
Switch A
 │ port 5
 ▼
Switch B
 │ port 3
 ▼
Target Port
```

LID Route
When fabric initialization is complete
```
Discover topology
       ↓
Assign LIDs
       ↓
Calculate paths
       ↓
Program forwarding tables
```

## GMP
General Management Packet

```
GMP
├── Destination QP: QP 1
├── Handler: GSA
├── Default VL: VL 0
├── Can use: VL 0–14
└── Follows the general Credit Flow Control
```

Compare between SMP and GMP
```
SMP = QP0 + VL15 + Fabric Bootstrap
GMP = QP1 + normal VL + General Management

SMP packet:

LRH
├── VL = 15
└── Destination LID

BTH
└── Destination QP = 0

Payload
└── SMP / MAD

GMP packet:

LRH
├── VL = 0 normally
└── Destination LID

BTH
└── Destination QP = 1

Payload
└── GMP / MAD
```

# Verbs
API for using RDMA/HCA
- Create
- Register
- Modify
- Post
- Poll
- Send
- Receive
- Read
- Write

General work flow:
1. Open RDMA device
2. Allocate Protection Domain
3. Register memory
4. Create Completion Queue
5. Create Queue Pair
6. Connect QP
7. Post Work Request
8. HCA executes operation
9. Poll Completion Queue

## Channel Semantics: Send/Receive
Receiver: Here is the buffer for receiving
```
Receiver application
       │
       │ ibv_post_recv()
       ▼
Receive Queue
┌────────────────────┐
│ Receive buffer WR  │
└────────────────────┘
```
Sender: Send the data in this buffer to remote
```
Sender application
       │
       │ ibv_post_send()
       ▼
Send Queue
┌────────────────────┐
│ Send buffer WR     │
└────────────────────┘
```
Then
```
Sender SQ
   │
   │ SEND
   ▼
Receiver RQ
   │
   ▼
Receiver Buffer
```
Both sender and receiver need to prepare.

## Memory Semantics: RDMA Write and RDMA Read
Directly access the registerd RAM in remote

RDMA Write, need to know the Remote virtual address and rkey first
```
Local Memory
     │
     │ RDMA Write
     ▼
Remote Memory
```
RDMA Read, same as write, need to know the Remote virtual address and rkey first
```
Remote Memory
     │
     │ RDMA Read
     ▼
Local Memory
```
The remote side need to do the following:
```
Allocate memory
      ↓
Register memory
      ↓
Get rkey
      ↓
Share address and rkey securely
      ↓
Keep memory valid
```

# Summary
For HPC APP uses MPI, excute RDMA Write:
```
MPI Application
      │
      │ MPI collective operation
      ▼
MPI / communication library
      │
      │ uses RDMA interface
      ▼
libibverbs
      │
      │ post RDMA Write WR
      ▼
QP Send Queue
      │
      │ HCA consumes WQE
      ▼
InfiniBand Transport
      │
      ▼
IB Network / Link / Physical Layers
      │
      ▼
Remote HCA
      │
      ▼
Remote registered memory
```
For Fabric management
```
Subnet Manager
      │
      │ constructs SMP
      ▼
QP 0
      │
      ▼
VL 15
      │
      ▼
Switch / HCA management agent
```


Data / Application World
Application → ULP → Verbs → normal application QP

Management World
SM/GSA → MAD → QP0/QP1 → management traffic

For memory:
InfiniBand Upper Layer
======================

1. Upper Layer Protocols
   MPI       = HPC compute
   IPoIB     = IP over IB
   SDP       = Socket directly over IB
   SRP       = SCSI over RDMA
   iSER      = iSCSI over RDMA
   NFS-RDMA  = NFS over RDMA

2. Management Services
   SMP = QP0 + VL15
       = Subnet bootstrap and management
       = Direct Route / LID Route
       = no normal credit flow control

   GMP = QP1 + VL0 normally
       = General management
       = normal flow control

3. Transport Verbs
   Send/Recv   = Channel semantics, two-sided
   RDMA Write  = Local → Remote memory
   RDMA Read   = Remote → Local memory

4. Core path
   Application
      → ULP
      → Verbs
      → QP / WR
      → HCA
      → InfiniBand Fabric