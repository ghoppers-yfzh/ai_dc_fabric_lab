# UFM HA
UFM HA ≠ SM HA

## SM failure
```
IB Fabric
   |
   +---- SM1  Master   X
   |
   +---- SM2  Standby
                ↓
             becomes Master
```
SM Standby take care of:
- topology discovery
- LID assignment
- routing calculation
- switch forwarding programming
- topology change handling

## UFM server failure
```
            Management
                |
        +-------+-------+
        |               |
    UFM Node A       UFM Node B
      Active           Standby
        X                 |
                          ↓
                       Active
```

UFM HA mental model:
```
Master appliance
+
Standby appliance
+
Pacemaker
+
DRBD
```

Pacemaker monitors UFM servers/resources, controls which node is the master

DRBD: Sync protected filesystem.

| Failure| Existing traffic| New topology/path management| UFM GUI|
| --- | --- | --- | --- |
| Master SM fails, standby SM exists | Usually continues| **Yes**, after standby takes Master role | Usually yes|
| UFM server fails, no HA| Existing forwarding may temporarily continue| **No**, if it was the only SM| **No**|
| One fabric link fails| Unaffected traffic continues; affected traffic may interrupt | **Yes**, if SM is healthy| Yes                                    |
| Both SMs unavailable| Existing programmed paths may temporarily continue| **No**| Depends on whether UFM itself is alive |

UFM GUI alive ≠ SM alive

# InfiniBand Operational Provisioning

Provisioning Process:
1. Physical
2. Host Software
3. Management
4. Fabric Initialization
5. Policy
6. Validation

## Physical
Confirm the following:
- Cable
- Optics
- HCA
- Switch
- Firmware
- Link

Use `ibstat` and `iblinkinfo` to check physical link status

## Host software
DOCA-OFED or inbox RDMA stack

Make sure the following are working fine
```
OS
 ↓
RDMA stack
 ↓
HCA driver
 ↓
HCA
```

Commands: `ibv_devinfo`, `rdma link`

## Management
Questions for the design:
- OpenSM or UFM
- Only one SM?
- Standby SM?
- UFM HA?
- External SM?

## Fabric initialization
When SM starts up
```
Discovery
   ↓
LID assignment
   ↓
Routing calculation
   ↓
Port configuration
```

Commands to validate:
- `sminfo`
- `ibnodes`
- `ibnetdiscover`

## Policy
PKey
QoS / SL / VL
Routing engine
Adaptive Routing

```
Bring fabric up
      ↓
then
      ↓
Apply desired operational policy
```

## Validation

Tools to validate
- ibstat
- sminfo
- ibnodes
- iblinkinfo
- ibnetdiscover
- ibdiagnet

And also performance for `ib_write_bw` and `ib_write_lat`


| Command| Description |
| --- | --- |
| `ibstat`        | Is the local HCA/port Normal?|
| `sminfo`        | Who is the current active SM？Is the SM reachable? |
| `ibnodes`       | Which IB nodes are discovered in Fabric？|
| `iblinkinfo`    | How is IB links / ports status?|
| `ibnetdiscover` | What is the discoverd topology?|
| `ibdiagnet`     | Is there any topology/routing/error/config problem in Fabric? |
| `ib_write_bw`   | Does RDMA bandwidth match design?|
| `ib_write_lat`  | Does RDMA latency match design?|

Provisioning Checklist:
```
1. Physical
   Cable / optics / firmware / link

2. Software
   DOCA-OFED / RDMA stack

3. SM
   UFM / OpenSM / redundancy

4. Initialize
   Discover → LID → Route → Configure

5. Policy
   PKey → QoS → Routing → AR

6. Validate
   Topology → SM → Errors → Routing → Performance
```
