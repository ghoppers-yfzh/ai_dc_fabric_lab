# UFM
OpenSM/SM's responsbilities:
1. Discover Fabric
2. Assign LIDs
3. Calculate routes
4. Program forwarding
5. Maintain subnet

What does UFM do:
```
                UFM
                 |
     +-----------+-----------+
     |           |           |
   Control    Monitoring   Operations
     |           |           |
     SM       Telemetry     Alarm
   Routing     Counters     Health
   PKey/QoS    Topology     Reports
                           Diagnostics
```

UFM is a management system, not the fabric itself.

UFM Health ≠ Fabric Health


System Health:
- UFM Health
- UFM Logs
- UFM System Dump
- Fabric Health
- Daily Reports
- Topology Compare
- Fabric Validation
- IBDiagnet

## Topology Compare
`Master / expected topology` vs `Current topology`

It detects
- Missing Node
- Added Node
- Missing Link
- Added Link
- Changed Connectivity

UFM support compare the current topology with master topoloy or uploaded .topo file.

# Counters in UFM
## Physical / Link Integrity
- Symbol errors
- Link error recovery
- Link downed
- CRC-related errors

```
Physical layer
    ↓
Cable?
Optics?
Port?
Signal quality?
BER?
Link stability?
```

Low traffic + increasing error counter -> physical/link integrity

## Congestion - XmitWait
XmitWait: 
```
Port has data to transmit
        ↓
Wants to transmit
        ↓
No sufficient receive credits downstream
        ↓
Cannot transmit yet
        ↓
Wait
        ↓
XmitWait increases
```

XmitWait means port forwarding pending on downstream credit.

Example:
```
CRC errors       = 0
Symbol errors    = 0
Link Down        = 0

XmitWait         = HIGH
Utilization      = HIGH

Training job performance = slow


Congestion
   ↓
Hot link?
Hot rail?
Oversubscription?
Routing imbalance?
Job placement?
Adaptive routing?
```

## Utilization / Throughput
XmitData
RcvData
```
High utilization imbalance
          +
High XmitWait on certain paths
          ↓
possible path/load distribution problem
          ↓
routing / adaptive routing investigation
```

# Troubleshooting Workflow

| Observation                      | First suspicion           |
| -------------------------------- | ------------------------- |
| Symbol/CRC errors ↑              | Physical link             |
| Link flaps ↑                     | Physical/link state       |
| XmitWait ↑                       | Congestion / credit wait  |
| XmitData/RcvData ↑               | High traffic/utilization  |
| High XmitWait + high utilization | Congested path            |
| High errors + low utilization    | Physical problem          |
| Uneven utilization across paths  | Routing/load distribution |

```
Scope
  ↓
Topology
  ↓
Physical
  ↓
Congestion
  ↓
Utilization
  ↓
Routing
  ↓
Deep Dive
```

Case A
- GPU01 slow
- GPU02-64 normal
Small fault domain

Case B

All GPU nodes behind Leaf03 slow

Check:
- Leaf03
- uplinks
- rail
- routing

Case C
- Entire cluster slowed down
Possible:
- fabric-wide congestion
- SM/routing
- common bottleneck
- collective communication issue


UFM -> Where / What

CLI -> Exact state / validation

Example A:
UFM reports:
- Leaf02 / Port 23
- High error rate

CLI Check:
- iblinkinfo
- ibstat
- ibdiagnet

Example B:
UFM reports `High XmitWait`

CLI check:
- ibdiagnet
- performance testing
- routing
- topology

ibdiagnet checks:
- Topology
- Links
- Ports
- Routing
- PKeys
- SL/VL
- Counters
- Adaptive Routing
- ...

Use ibdiagnet:
```
UFM alarm
     ↓
identify affected link / node / area
     ↓
counters / topology
     ↓
need deeper validation
     ↓
ibdiagnet
```

# Summary
```
1. OpenSM manages the subnet;
   UFM operates the fabric.

2. UFM Health checks UFM itself.

3. Fabric Health checks the InfiniBand fabric.

4. Physical errors + low traffic
   → physical fault first.

5. High XmitWait
   → credit wait / downstream congestion.

6. Troubleshooting:
   Scope → Topology → Physical → Congestion
   → Utilization → Routing → ibdiagnet.
```
