# Transport Layer
Transport layer provides end to end connection for applications.
The connection transfers over a vritual tunnel. 
When the message length is longer than MTU, Transport Layer does segmentation.

The two ends of the virtual channel is Queue Pari, QP.

## QP
Queue Pair direction:
- send
- receive

QP uses QP number to identify.

APP can access the QP usually by map the virtual RAM to QP.

Additional QP will be created by APP if required, work queue is the interface between application and fabric.

Work flow:
1. App submit work request
2. Work queueu will have a work queue element, WQE for the request
3. A completion queue element, CQE will be put in the work completion queue when Channel Adapter complete the WQE
4. The Completion queue is used by HCA to notifiy APP for the request completion.
```
Application
    │
    │ Post Work Request
    ▼
Work Request
    │
    │ Converted into queue entry
    ▼
WQE in SQ or RQ
    │
    │ HCA executes it
    ▼
Data is transferred
    │
    │ Operation finishes
    ▼
CQE placed in CQ
    │
    │ Application polls CQ
    ▼
Application knows completion status
```

## Transport Layer tasks
1. Segmentation and Reassembly
2. QP Transport service type
3. InfiniBand Partition

Segmentation and Reassembly is for the message longer than MTU

Four types of Transport servcie type:
1. Reliable Connection # commonly used
2. Unreliable Connection
3. Reliable Datagram
4. Unreliable Datagram # similar to UDP


Datagram mode suitable for multi-session on one QP. It can send to/recieve from multiple remote QP.
QP doesn't support segementation which means the packet size can not over MTU.

Connected mode means a dedicated QP, consumes more RA. QP takes care of segementation.

### Reliable and Unreliable transport
Reliable transport, QP  will validate, retransmit packet when packet is lost. Each packet has Packet Sequence Number, PSN.
When packet arrives in order, return ACK, otherwise, NAK. 
Sender has timer, if not ACK, it triggers retransmition.

## Channel Semantic：Send/Receive 
Pre-post Receive
```
Receiver:
Allocate buffer
    ↓
Register memory
    ↓
Post Receive WQE
```
Then Sender
```
Sender:
Allocate buffer
    ↓
Register memory
    ↓
Post Send WQE
```
Then the work flow
```
Sender HCA reads local buffer
    ↓
Data crosses the fabric
    ↓
Receiver HCA finds a posted Receive WQE
    ↓
Data is written into that receive buffer
```

## Memory Semantic：RDMA Read/Write

Start from sender only, No Receive WQE is required
Locate remote by Remote address and Remote rkey
```
Remote side:
Register target memory
    ↓
Share remote address + rkey

Local side:
Register source memory
    ↓
Post RDMA Write WQE
    ↓
Local HCA reads local memory
    ↓
Packet crosses the fabric
    ↓
Remote HCA validates address and rkey
    ↓
Remote HCA writes directly into remote memory
```

This is called RDMA.
```
Application memory
    ↕
HCA / RNIC
    ↕
Network
    ↕
Remote HCA / RNIC
    ↕
Remote application memory
```

Normal RDMA Write creates CQE in sender, it won't create Receive CQE in Remote.

For memory:
```
Send:
I send the message to remote QP，remote decides where to put it.

RDMA Write:
I have been authorized, I will write to this address directly.
```

# Partition
InfiniBand's logical segmenation, similar to Ethernet VLAN.

Partition defines which ports can communicate with each other. One port can be set in multiple partitions.

For example:
```
Partition A: GPU compute fabric
Partition B: Storage fabric
Partition C: Management services

ServerX belongs to Partition A + Partition B
```

## P_Key
Each IB packet carrys 16-bit P_Key it is in BTH
```
16 bits
┌───────────────┬──────────────────────────────┐
│ Membership bit│ 15-bit Partition Number      │
│ Bit 15        │ Bits 14-0                    │
└───────────────┴──────────────────────────────┘
```
P_Key tags the packet's partition.

The highest bit set member type:
```
1 = Full Member
0 = Limited Member
```

### Full Member
Full Member can communicate with Everyone in the Partition

```
Membership bit = 1
Partition number = 0x7FFF

P_Key = 0xFFFF
```

### Limited Member
Limited Member can only communicate with Full member
```
Membership bit = 0
Partition number = 0x7FFF

P_Key = 0x7FFF
```

Example:
```
                 Storage Target
                  Full Member
                   /        \
                  /          \
                 /            \
        Initiator A          Initiator B
        Limited Member       Limited Member


Initiator A → Target: Allowed
Initiator B → Target: Allowed
Initiator A → Initiator B: Denied
```

Subnet Manager will set allowed P_Key to each HCA's P_Key Table.
HCA check Packet P_Key against Local P_Key Table for send and receive. Packet will be dropped if not allowed.

```
SM defines policy
    ↓
SM programs P_Key tables
    ↓
Packets carry P_Key
    ↓
HCA enforces membership
```

# OFED perftest
Perftest checks:
- Latency
- Bandwidth
on
- Read
- Write
- Send

For command:
- ib_read_lat
- ib_read_bw
- ib_write_lat
- ib_write_bw
- ib_send_lat
- ib_send_bw

It runs in Server/client mode.

Server end: `ib_write_lat`
Client end: `ib_write_lat <server-ip-or-hostname>`

For bandwidth test
```
# Server
ib_write_bw --report_gbits

# Client
ib_write_bw --report_gbits <server-ip-or-hostname>
```

## Latency

Usually check t_typical in microseconds, µs.

Make sure other parameters are the same when comparing.

## Bandwidth

Usually check BW average

Set a good baseline
```
Known-good baseline
    ↓
Run test after a change
    ↓
Compare latency and bandwidth
    ↓
Detect regression
```

Checks before and after the change.



# Summary

Send/Receive mode
```
Receiver application
    ↓
Register receive buffer
    ↓
Post Receive WR
    ↓
Receive WQE enters RQ

Sender application
    ↓
Register send buffer
    ↓
Post Send WR
    ↓
Send WQE enters SQ
    ↓
Local HCA sends packets
    ↓
Remote HCA matches Receive WQE
    ↓
Data written to receive buffer
    ↓
CQEs generated
```

RDMA Write mode
```
Remote application
    ↓
Register target memory
    ↓
Share address + rkey

Local application
    ↓
Register source memory
    ↓
Post RDMA Write WR
    ↓
WQE enters SQ
    ↓
Local HCA reads source buffer
    ↓
Remote HCA validates address + rkey
    ↓
Data written directly into remote memory
    ↓
Local CQE generated
```
