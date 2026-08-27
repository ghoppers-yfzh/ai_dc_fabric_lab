# IB Fabric Configuration

Configuration path
```
Physical Topology
      ↓
Subnet Manager
      ↓
Base Routing Engine
      ↓
Adaptive Routing
      ↓
PKey Partitioning
      ↓
QoS: SL → VL
      ↓
Validation
```


| Function         | Target |
| ---------------- | ------ |
| PKey             | Communication peers |
| SL               | Service level for the traffic |
| VL               | Resource/flow-control lane for the traffic |
| Routing Engine   | Routing path calculation |
| Adaptive Routing | Routing path selection |
| `ibdiagnet`      | Does Fabric running state match configuration  |


## Pkey: Logical isolation in IB
PKey controls communication membership rather than physical topology.

Under the same physical IB fabric:
```
        Switches
       /   |   \
      /    |    \
Node A   Node B   Node C
```

It can be logically sets to:
```
TRAIN
├── Node A
└── Node B

STORAGE
├── Node A
└── Node C

MGMT
└── management nodes
```

Pkey is communication membership, it does not change network topology.

Pkey table is on the pots, SM/UFM/OpenSM config and distribute partition information.

Compare with Ethernet
```
Ethernet VLAN / VRF
→ Ethernet segmentation / routing isolation

InfiniBand PKey
→ IB partition membership / communication isolation
```

## Full Membership vs Limited Membership

```
Full ↔ Full        allowed
Full ↔ Limited     allowed
Limited ↔ Limited  not allowed
```
Example: There is a partition `STORAGE`.
Member of the `STORAGE`:
- Storage Server  → Full Member
- Compute01       → Limited Member
- Compute02       → Limited Member

Connections between the members:
```
Compute01 ----> Storage     YES
Compute02 ----> Storage     YES

Compute01 ----> Compute02   NO
```

## Pkey configuration
It is not decided by HCA.

Control logic:
```
UFM / OpenSM
      ↓
Subnet Manager
      ↓
Partition configuration
      ↓
PKey tables programmed into ports
```

Operational workflow:
```
1. Define partition
2. Assign PKey
3. Select member GUIDs / node groups
4. Decide membership type
5. Apply/reload SM configuration
6. Verify port PKey tables
7. Test allowed communication
8. Test denied/isolation case
```

## Pkey Validation

3 steps:
1. Configuration
2. PKey table
3. Functional test

Validation source:
- ibdiagnet2.pkey
- SM/UFM partition view
- port PKey tables
- functional connectivity test

# QoS
SL to VL work flow:
```
Service Level (SL)
        ↓
SL-to-VL mapping
        ↓
Virtual Lane (VL)
        ↓
buffer / flow-control / transmission resources
```

SL = WHAT class of service is this?

VL = WHERE / through which link-level lane
     is it actually transmitted?


Should every SL map to a different VL? Not always.

It can be
```
SL0 management ─┐
                ├─ VL0
SL3 low-prio ───┘

SL1 storage ────── VL1

SL2 training ───── VL2
```
Or
```
SL0 → VL0
SL1 → VL1
SL2 → VL2
```

It depends on the isolation design and VL resource.

Mindset for SL/VL design:
```
SL0 = Management
SL1 = Storage
SL2 = Training

SL-VL mapping:
SL0 → VL0
SL1 → VL1
SL2 → VL2
```

# Routing Engine vs Adaptive Routing
Base Routing calculation:
```
Topology
   ↓
Routing Engine
   ↓
Calculate paths
   ↓
Program forwarding
```

- minhop
- updn
- ftree
- dfp


Adaptive Routing requires correct base routing topology.

```
multiple eligible paths
        +
current congestion/load state
        ↓
dynamic path choice
```

The config path:
```
Topology
   ↓
Choose supported routing engine
   ↓
Enable/configure appropriate AR mode
```

Compairing with QoS
```
Adaptive Routing
→ Where should traffic go?

QoS / SL / VL
→ How should traffic be treated?

Congestion control
→ How should senders/network react to congestion?
```

# Validation: ibdiagnet
`ibdiagnet`, check the following items in output

- PKeys
- SL/VL
- routing
- adaptive routing
- congestion counters


`iblinkinfo` and `ibnetdiscover` check the topology.

`ib_write_bw` and `ib_write_lat` check the performance

Validation path
```
Topology
   ↓
Policy
   ↓
Routing
   ↓
Counters
   ↓
Actual performance
```

