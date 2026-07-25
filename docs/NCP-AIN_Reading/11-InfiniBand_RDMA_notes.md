# RDMA Architecture
Remote Direct Memory Access
RDMA three stages
- Setup/Control Path
- Data Path
- Completion

## Control Path
This initial stage invloves OS and driver, for example:
- Access RDMA device
- Allocate Protection Domain
- Register RAM
- Create CQ
- Create QP
- Update QP state
- Establish connection
- Exchange remote address and rkey

This tasks takes time, but normally won't repeat for each packet

## Data Path
When connection and resource are ready, the Application will
```
Post Work Request
        ↓
RNIC read queue
        ↓
RNIC direct DMA RAM
        ↓
RNIC send/receive data
        ↓
    Completion
```
Normal data transfer doesn't need to access kernel
- Kernel bypass
- Transport Offload
- Zero Copy

Note, RDMA still need OS, it is the high-speed data transfer path bypass the OS.

## Difference between Socket and RDMA
Socket path
```
Application Buffer
        ↓
send() system call
        ↓
Kernel Socket Buffer
        ↓
TCP/IP Stack
        ↓
Device Driver
        ↓
NIC
```

RDMA path
```
Registered Application Buffer
        ↓
Post Work Request
        ↓
RNIC reads Work Queue
        ↓
RNIC directly accesses memory with DMA
        ↓
Network
        ↓
Remote RNIC directly accesses registered memory
```

## Difference between Transport offload and Kernel Bypass
Kernel Bypass, data path does not need system call
```
Application
    ↓ userspace libibverbs
Mapped RNIC Queue
    ↓
RNIC
```

Transport Offload is about who manages transport, fragment, retransmission, order control.

TCP: `Operating System TCP Stack`

RDMA RC: `RNIC Hardware`

For example, in RoCEv2, the outerlayer is UDP, but the reliabiliy is not on UDP, it is on RNIC's RDMA transport.

# One-sided communitcation and Two-sided communication
## Two-sided communication
Both ends need prepare for the transfer.
```
Receiver:
Allocate Buffer
      ↓
Post Receive WR
      ↓
Receiver Data

Sender:
Prepare Data
      ↓
Post Send WR
      ↓
Send Data
```

When data arrives
```
Incoming Data
      ↓
Remote RNIC
      ↓
Find WQE in Receive Queue 
      ↓
Write WQE pointed Buffer
      ↓
 Receive Completion
```


## One-sided communication RDMA Write
Sender directly write into registered RAM in destination
```
Local Buffer
     ↓
RDMA Write
     ↓
Network
     ↓
Remote RNIC
     ↓
Remote Registered Memory
```
Sender needs to know
- Remote Address
- Remote R_Key
- Length

Receiver doesn't need to Post Receiver or get CPU to process write.
Receiver need to register RAM and inform sender about the address and rkey.

## One-sided communication RDMA Read
RDMA Read
```
Initiator sends:
Remote Address + R_Key + Length
                   ↓
Remote RNIC reads remote memory
                   ↓
Remote RNIC returns data
                   ↓
Local RNIC writes local buffer
```

The remote CPU doesn't need：
- Call send()
- Post Receive
- Find the data and send
- Process the request

The remote RAM needs：
- Complete regiser
- Allow Remote Read
- Provide address and rkey

## Zero Copy
Zero copy means the data transfer doesn't need to pass the buffer in the middle.
```
Source Application Buffer
          ↓
        RNIC
          ↓
Destination Application Buffer
```
Data transfers from source APP buffer to the desitination buffer. There is no extra RAM copy excuted by CPU.



Step 1,2,4 is control and sync, only 3 is One-sided transfer
```
1. Receiver registers destination buffer
2. Receiver sends address + rkey
3. Sender performs RDMA Write
4. Sender notifies receiver that write is complete
```
# Understand Verbs object
Object relationship
```
RDMA Device Context
        │
        ├── Protection Domain (PD)
        │      ├── Memory Region (MR)
        │      └── Queue Pair (QP)
        │             ├── Send Queue (SQ)
        │             └── Receive Queue (RQ)
        │
        └── Completion Queue (CQ)
```
## WR: Work Request
WR is a job description APP submit to RNIC
`RNIC, please write this 4069bit to the remote address`
```
Operation: RDMA_WRITE
Local address: 0x...
Length: 4096
Local lkey: ...
Remote address: 0x...
Remote rkey: ...
```

## WQE: Work Queue Entry
After WR is submit to Send Queue, WQE is the entry in HW queue.

WR: Application layer request
WQE: Entry in HW queue

## QP: Queue pair
QP:
- Send queue
- Receiver queue

RDMA write and Read use Send queue, they do not consume remote's Receiver queue's WQE.

Receive Queue is mainly for Send/Receive

State for RC QP
1. RESET
2. INIT # local paramete is set
3. RTR  # Ready to Receive
4. RTS  # Ready to Send

## CQ: Completion Queue
When RNIC complete a job, it generate CQE in CQ
```
Completion Queue
├── CQE: WR 100 completed
├── CQE: WR 101 completed
└── CQE: Receive 200 completed
```
Application uses Polling and Event/Interrupt to read the completion result

## WC: Work Completion
The result for APP get from CQ usually shows as Work Completion:
```
WR ID
Status
Opcode
Byte Length
Immediate Data
Error Information
```
wr_id is important. APP set its tag when submit WR, it find the request and buffer based on wr_id

The full process is 
```
Application creates WR
         ↓
ibv_post_send()
         ↓
WR becomes WQE in SQ
         ↓
RNIC executes WQE
         ↓
RNIC creates CQE
         ↓
Application polls CQ
         ↓
Application receives WC
```

## Send and receive process
The receiver prepars
```
char recv_buffer[1024];

Register recv_buffer
       ↓
Create Receive WR
       ↓
Post to Receive Queue
```
The reciver WQE means: the next send message can be write in this 1024 bit buffer

Sender submit job
```
char send_buffer[] = "Hello";

Register send_buffer
       ↓
Create Send WR
       ↓
Post to Send Queue
```

RNIC:
```
Post Receive
     ↓
Post Send
     ↓
RNIC transfers
     ↓
Send Completion + Receive Completion
```
1. Read WQE from SQ
2. Read `Hello` from registered RAM
3. Create RDMA Transport Packet
4. Send to network
5. Peer RNIC find the Receive WQE
6. Write data into buffer
7. Two ends create Completion
```
Post Receive
     ↓
Post Send
     ↓
RNIC transfers
     ↓
Send Completion + Receive Completion
```

## RAM registration
Application register
- Virtual Address
- Length
- Access Permissions

lkey and rkey is generated after registration

### lkey is used for local RNIC validation
`Can the QP access this local buffer`
To describe the local data
`Local Address + Length + lkey`

### rkey is uded for remote access authorization
`Is remote authorized for Read/Write for this Memory Region`

RDMA Write carries
- Remote Virtual Address
- R_Key
- Length

The reciver RNIC checks
- Is the address in registerd scope
- Is rkey valid
- Is Remote write allowed
- Is the length valid
- Is QP/PD correct
DMA is excuted after all the checks are pass

rkey is a `Remote Memory Capability Token`, it protects the access

# Memory Pinning
Classic RDMA model
```
Registered Memory
        ↓
Pages pinned in RAM
        ↓
RNIC can safely DMA
```
# 4 different RDMA 

## Comparison of Four RDMA Operations

| Operation | Communication Model | Remote Side Must Post Receive | Requires Remote Address and `rkey` | Remote CPU Involvement per Operation | Data Direction |
|---|---|---:|---:|---|---|
| Send/Receive | Two-sided | Yes | No | Processes the receive completion | Sender → Receiver |
| RDMA Write | One-sided | No | Yes | Not involved in data movement | Local → Remote |
| RDMA Read | One-sided | No | Yes | Not involved in data movement | Remote → Local |
| Atomic | One-sided | No | Yes | Not involved in executing the operation | Modifies a small piece of remote state |


## Send/Recv
For short message
Receiver controls where the messge lands


## RDMA Write
For bulk data push.
Initiator controls where data lands
## RDMA Read
Initiator decides what to fetch
## Atomic
Fetch and Add
```
old = remote_value
remote_value = old + increment
return old
```
Compare and Swap
```
old = remote_value

if old == expected:
    remote_value = new_value

return old
```

# RC and UD
## RC: Reliable Connection
Similar to TCP but not equal
```
TCP = byte stream
RC = message-oriented RDMA transport
```

## UD: Unreliable Datagram
RC and TCP are similar on `reliablity and connection`
UD and UDP are similar on `unreliablity and no-conn`

# In RoCEv2 packet structure
```
Application creates Work Request
              ↓
Post WR to Queue Pair
              ↓
RNIC turns WR into RDMA packets
              ↓
RoCEv2 carries packets over UDP/IP/Ethernet
              ↓
Remote RNIC executes Send/Write/Read/Atomic semantics
              ↓
RNIC generates Completion
```
Network devices see `Ethernet + IP + UDP + RDMA Transport Payload`
Hosts see 
```
Send
Receive
RDMA Write
RDMA Read
Atomic
```

# Summary map
```
                    CONTROL PATH
Application
    │
    ├── Open RDMA device
    ├── Create PD / CQ / QP
    ├── Register memory → lkey / rkey
    ├── Connect QPs
    └── Exchange remote address + rkey
                         │
                         ▼
                     DATA PATH
Application creates WR
                         │
                         ▼
                 Post WR to SQ/RQ
                         │
                         ▼
                 WR becomes WQE
                         │
                         ▼
                  RNIC executes
                         │
       ┌─────────────────┼──────────────────┐
       ▼                 ▼                  ▼
    Send/Recv         RDMA Read          RDMA Write
    Two-sided         One-sided          One-sided
       │                 │                  │
       └─────────────────┼──────────────────┘
                         ▼
                RNIC generates CQE
                         │
                         ▼
                Application polls CQ
                         │
                         ▼
                 Receives WC result
```

Logical chains
```
NCCL collective communication
        ↓
RDMA operation / QP / registered memory
        ↓
RNIC produces RoCEv2 packets
        ↓
Leaf-spine Ethernet fabric
        ↓
PFC / ECN / DCQCN control congestion
        ↓
Completion latency affects GPU communication efficiency
```
