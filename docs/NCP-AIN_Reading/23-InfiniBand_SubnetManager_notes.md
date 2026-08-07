# Subnet Manager
Three deployment options:
- Embeded SM, runs on Managed IB switch
- OpenSM, runs on Linux Server with DOCA-OFED
- UFM, runs on dedicated management platform

SM is centralized control panel of InfiniBand Fabric.
```
SM starts
   │
   ├── Discover fabric
   │      └── Switch / HCA / Port / Link
   │
   ├── Assign LIDs
   │
   ├── Calculate topology
   │
   ├── Run routing engine
   │      ├── MinHop
   │      ├── Up/Down
   │      ├── Fat Tree
   │      └── ...
   │
   ├── Program LFT
   │
   ├── Configure fabric parameters
   │
   └── Periodically sweep fabric
           │
           └── detect link/node/topology changes
```


# In-band and Out-of-band
## In-band
SM controls the fabric
```
Server running OpenSM
        │
       HCA
        │
        ↓
      Leaf
      /  \
   Spine  Spine
      \  /
      Leaf
```
SM can do the following IB fabric management:
- discover siwitches
- assign LIDs
- calculate routes
- program LFT

## Out-of-band

```
Management Server
      │
Ethernet Network
      │
Management RJ45
      │
Managed IB Switch
```

In-band  → SM manages Fabric

OOB      → Admin manages devices


# Embeded SM
Managed IB switch vs Unmanaged switch/Externally Managed Switch

Besides IB switching ASIC, Managed IB switch also has:
```
┌─────────────────────────┐
│       Managed Switch    │
│                         │
│ Management CPU          │
│ MLNX-OS                 │
│ CLI / Web UI            │
│ Embedded SM             │
│                         │
│ InfiniBand ASIC         │
└───────────┬─────────────┘
            │
         IB ports
```
It has CPU, OS and Ethernet OOB management interface.


Externally Managed / Unmanaged IB Switch does not have management OS/CPU to run OpenSM
```
┌──────────────────────────┐
│ Externally Managed Switch│
│                          │
│ Firmware                 │
│ IB Switching ASIC        │
└────────────┬─────────────┘
             │
          IB Fabric
```



```
               IB Fabric
                   │
          ┌────────┴────────┐
          │ Managed Switch  │
          │                 │
          │ MLNX-OS         │
          │ Embedded SM ★   │
          └─────────────────┘
```
Simply approach,limits to 2048 nodes, doesn't suitable for large scale fabric


Configuration
```
Enable SM, `ib sm`
      ↓
Set SM Priority,`ib sm sm-priority <1-15>`
      ↓
Choose Routing Engine, `ib sm routing-engine ...`
```

# Server-based OpenSM
```
Linux Server
     │
DOCA-OFED
     │
OpenSM
     │
HCA
     │
     ↓
InfiniBand Fabric
```

Configuration: `/etc/opensm/opensm.conf`, includes:
- SM Priority
- Routing Engine
- Sweep interval
- QoS
- routing parameters
- ...

General log: `/var/log/messages`

OpenSM detailed log: `/var/log/opensm.log`

## OpenSM routing engine fallback

Fallback: routing_engine ftree,updn,minhop
```
Routing Engine A
       ↓ fail
Routing Engine B
       ↓ fail
Routing Engine C
       ↓ fail
MinHop
```

# UFM
```
             UFM
              │
   ┌──────────┼────────────┐
   │          │            │
 Subnet     Fabric      Monitoring
 Manager   Management
   │          │            │
 Routing    Devices      Events
 Config     Topology     Health
```

Comparing with OpenSM
```
OpenSM
≈ routing/control daemon

UFM
≈ Fabric management platform
   + SM
   + topology
   + telemetry
   + alerts
   + operations
```

# Summary
## For LAB or small IB fabric
```
64 nodes
basic Fat Tree
don't need advanced telemetry

Managed Switch
     ↓
Embedded SM
```
## Intermediat fabric
```
hundreds / larger number of nodes
more complex topology
advanced routing
AR requirements

Dedicated Servers
     │
   OpenSM
     │
IB Fabric

With dual SM
OpenSM-A
Priority 10
Master

OpenSM-B
Priority 5
Standby
```

## Large scale production AI factory

```
Large GPU cluster
24x7 production
operations team
telemetry
alerts
topology visualization
advanced routing
fault management

UFM
 │
 ├── SM
 ├── Routing
 ├── Monitoring
 ├── Events
 ├── Topology
 └── Management
```

1. Every InfiniBand subnet needs an SM.
2. SM core tasks
Discover → LID → Route → Configure → Monitor
3. SM deployment
- Managed Switch
- Server OpenSM
- UFM
4. Managed vs Unmanaged switch
```
Managed
= CPU + MLNX-OS + OOB + can host SM

Externally Managed
= no local SM hosting
```
5. Embedded SM
- simple
- no extra license
- ≤2048 nodes according to NVIDIA
- limited advanced features

6. Server OpenSM
- DOCA-OFED
- dedicated compute
- opensm.conf
- opensm.log
- advanced routing

7. UFM, `SM + Fabric Management + Monitoring`

8. Routing
```
MinHop
    = shortest path

UPDN
    = deadlock avoidance

AR_UPDN
    = Adaptive Routing + Up/Down
```

