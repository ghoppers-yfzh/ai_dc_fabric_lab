# Some RoCE basics
- RDMA: Remote Direct Memory Access
- RoCE: RDMA over Converged Ethernet
- RoCEv1: Layer2
- RoCEv2: Over UDP/IP, Layer3

## PFC: Priority based Flow Control
PFC is between the switch, hop by hop, control certain stream. 
When congestion happens, switch send message to upsteam switch to pause

## ECN: Explicit Congestion Notification
ECN is end to end congestion warning.
When switch detect queue over the threshold, it tag ECN on packet. When receiver receives packet with ECN tag, it send CNP(Congestion notification packet) back to sender. 
Sender use DCQCN to reduce the speed.

# RoCE on Cumulus


Enable RoCE, by default it is lossless mode, lossless mode has both ECN and PFC enabled.


```
nv set qos roce
nv config apply
```
It can be swtiched to lossy mode, lossy mode only has ECN enabled

- Simpler network
- No PFC pause storm
- Similar to normal IP/Ethernet Fabric

```
nv set qos roce mode lossy
nv config apply
```

ECN(end to end) is like a traffic light, PFC(hop to hop) is like car break

## Buffer pool
By default ingress and egress separate lossless and lossy traffic into different buffer pool
For example
```
Lossy pool：8 MB
RoCE pool： 4 MB
```
It separate the two types of traffic, so the lossy traffic won't use RoCE's pool.

However, RoCE will only has 4MB, even the lossy pool is not fully used but RoCE pool is 100%. So it can be set in Single Shared Buffer Pool
```
nv set qos roce mode lossless-single-ipool
```
Single shared buffer pool is for ingress pool only.

Egress pool is still separated.
```
Ingress
┌──────────────────────────────┐
│ Lossy + RoCE shared pool     │
└──────────────────────────────┘

Egress
┌──────────────────────────────┐
│ Lossy/default egress pool    │
├──────────────────────────────┤
│ RoCE reserved egress pool    │
└──────────────────────────────┘
```
So it is like two types of car park.
Separated or shared

## PFC work flow:
```
RoCE packet arrives
        │
        ▼
Shared ingress buffer occupancy increases
        │
        ▼
Reaches ECN threshold
        │
        ├── Tag ECN
        │
        ▼
Keep increasing, reaches PFC/XOFF 条件
        │
        ▼
Send upstream switch PFC pause for priority 3
```


## Lossy Multi TC Profile

lossy-multi-tc is a type of RoCE QoS doesn't use PFC.
It set traffic into multiple queue, when congestion happens, it doesn't drop packet, it send a small notification packet which trigger retransmission.

### What is multi-TC
TC is traffic class

Normal lossy RoCE is simple
```
RoCE       → TC3
CNP        → TC6
Other      → TC0
```

lossy-multi-tc set different DSCP/priority traffic to different queue
```
Egress port
├── TC0 queue
├── TC1 queue
├── TC2 queue
├── TC3 queue
├── TC4 queue
├── TC5 queue
├── TC6 queue
└── TC7 queue
```

### What does packet trimming do
Normal lossy
```
RoCE packet
    ↓
Buffer is full
    ↓
Packet drop
    ↓
Receiver noticed seq loss and trigger retransmission
```

Packet trimming
```
RoCE packet
    ↓
Buffer is full
    ↓
Switch remove most of the payload
keep a short truncated packet
        ↓
udpate DSCP
        ↓
Send to dest host for retransmission
```
Some default trimming profile value
- Truncated packet：256 bytes
- Switch Priority：4
- DSCP：11
- Original traffic match：TC1、TC2、TC3

Priority 4 means it is set to a different queue, because the original queue might already be full.

Some config
Port 1-16, host facing link, switch priority 4 set DSCP to 21

Port 17-32, upstream link, switch priority 4 set DSCP to 11

```
nv set qos roce mode lossy-multi-tc
nv set system forwarding packet-trim remark dscp port-level
nv set interface swp1-16 qos remark profile lossy-multi-tc-host-group
nv set interface swp17-32 qos remark profile lossy-multi-tc-network-group
nv config apply
```
Check
```
cumulus@switch:~$ nv show qos remark
Profile                       Rewrite  Summary                              
----------------------------  -------  -------------------------------------
lossy-multi-tc-host-group              SP->PCP/DSCP mapping configuration: 4
lossy-multi-tc-network-group           SP->PCP/DSCP mapping configuration: 4
```

## Remove RoCE cofnig
```
nv unset qos roce
nv config apply
```

## Validate RoCE config

Use `nv show qos roce` to check
Following example:
- PFC is enabled on swtich priority 3
- PFC rx and tx are both enabled
- PFC cable-length, the longer cable is , the more packet on the cable, the larger headroom is required
- lossless single ipool mode
- ECN is enabled on TC0(normal) and TC3(RoCE)
- Queue buffer min-threshod is 146.48 KB, swtich starts tag ECN
- max-threshold is 1.43 MB, 100% packets get ECN tag
```
cumulus@switch:mgmt:~$ nv show qos roce
                    operational            applied
------------------  ---------------------  ---------------------
state                                      enabled
mode                lossless-single-ipool  lossless-single-ipool
pfc
  pfc-priority      3
  rx-enabled        enabled
  tx-enabled        enabled
  cable-length      100
congestion-control
  congestion-mode   ECN
  enabled-tc        0,3
  min-threshold     146.48 KB
  max-threshold     1.43 MB
  probability       100
trust
  trust-mode        pcp,dscp
lldp-app-tlv
  priority          3
  protocol-id       4791
  selector          UDP
RoCE PCP/DSCP->SP mapping configurations
===========================================
       pcp  dscp                     switch-prio
    -  ---  -----------------------  -----------
    0  0    0,1,2,3,4,5,6,7          0
    1  1    8,9,10,11,12,13,14,15    1
    2  2    16,17,18,19,20,21,22,23  2
    3  3    24,25,26,27,28,29,30,31  3
    4  4    32,33,34,35,36,37,38,39  4
    5  5    40,41,42,43,44,45,46,47  5
    6  6    48,49,50,51,52,53,54,55  6
    7  7    56,57,58,59,60,61,62,63  7
RoCE SP->TC mapping and ETS configurations
=============================================
       switch-prio  traffic-class  scheduler-weight
    -  -----------  -------------  ----------------
    0  0            0              DWRR-50%
    1  1            0              DWRR-50%
    2  2            0              DWRR-50%
    3  3            3              DWRR-50%
    4  4            0              DWRR-50%
    5  5            0              DWRR-50%
    6  6            6              strict-priority
    7  7            0              DWRR-50%
RoCE pool config
===================
       name                   mode     size  switch-priorities  traffic-class
    -  ---------------------  -------  ----  -----------------  -------------
    0  lossy-default-ingress  Dynamic  100%  0,1,2,3,4,5,6,7    -
    2  lossy-default-egress   Dynamic  100%  -                  0,6
    3  roce-reserved-egress   Dynamic  inf   -                  3
Exception List
=================
No Data
```
Another example with lossy-multi-tc enabled
- PFC is not enabled
- The TC weight is not hard restriction, it only work when multiple TC experiance congestion at the same time


```
cumulus@switch:~$ nv show qos roce
                    operational     applied
------------------  --------------  --------------
state               enabled         enabled
mode                lossy-multi-tc  lossy-multi-tc
pfc
  pfc-priority      -
congestion-control
  congestion-mode   ECN
  enabled-tc        1,2,3
  min-threshold     163.00 KB
  max-threshold     234.00 KB
  probability       5
trust
  trust-mode        pcp,dscp

RoCE PCP/DSCP->SP mapping configurations
===========================================
       pcp  dscp                                                                                       switch-prio
    -  ---  -----------------------------------------------------------------------------------------  -----------
    0  0    0,7,8,9,10,51,52,53,54,55,56,57,58,59,60,61,62,63            0
    1  1    1,2                                                                                        1
    2  2    3,4                                                                                        2
    3  3    5,6                                                                                        3
    4  4    11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40  4
    5  5    41,42,43,44,45,46,47,48,49,50                                                              5
    6  6    -                                                                                          6
    7  7    -                                                                                          7

RoCE SP->TC mapping and ETS configurations
=============================================
       switch-prio  traffic-class  scheduler-weight
    -  -----------  -------------  ----------------
    0  0            0              DWRR-4%
    1  1            1              DWRR-8%
    2  2            2              DWRR-18%
    3  3            3              DWRR-22%
    4  4            4              DWRR-22%
    5  5            5              DWRR-22%
    6  6            6              DWRR-4%
    7  7            7              DWRR-0%

RoCE pool config
===================
       name                   mode     size  switch-priorities  traffic-class
    -  ---------------------  -------  ----  -----------------  ---------------
    0  lossy-default-ingress  Dynamic  100%  0,1,2,3,4,5,6,7    -
    2  lossy-default-egress   Dynamic  100%  -                  0,1,2,3,4,5,6,7

Exception List
=================
No Data

Extended Features
====================
    Feature      Status
    -----------  -------
    packet-trim  enabled
```
Interface level check
- min-threshold is different with system level, this is possible
- interface level operational value is more close to the real HW status.
- Trust VLAN PCP and IP DSCP
```
cumulus@switch:mgmt:~$ nv show interface swp16 qos roce status
                    operational    applied  description
------------------  -------------  -------  ---------------------------------------------------
congestion-control
  congestion-mode   ecn, absolute           Congestion config mode
  enabled-tc        0,3                     Congestion config enabled Traffic Class
  max-threshold     1.43 MB                 Congestion config max-threshold
  min-threshold     153.00 KB               Congestion config min-threshold
  probability       100                  
lldp-app-tlv                             
  priority          3                    
  protocol-id       4791                 
  selector          UDP
pfc
  pfc-priority      3                       switch-prio on which PFC is enabled
  rx-enabled        yes                     PFC Rx Enabled status
  tx-enabled        yes                     PFC Tx Enabled status
trust
  trust-mode        pcp,dscp                Trust Setting on the port for packet classification
mode                lossless                Roce Mode

RoCE PCP/DSCP->SP mapping configurations
===========================================
          pcp  dscp  switch-prio
    ----  ---  ----  -----------
    cnp   6    48    6
    roce  3    26    3

RoCE SP->TC mapping and ETS configurations
=============================================
          switch-prio  traffic-class  scheduler-weight
    ----  -----------  -------------  ----------------
    cnp   6            6              strict priority
    roce  3            3              dwrr-50%

RoCE Pool Status
===================
        name                   mode     pool-id  switch-priorities  traffic-class  size      current-usage  max-usage
    --  ---------------------  -------  -------  -----------------  -------------  --------  -------------  ---------
    0   lossy-default-ingress  DYNAMIC  2        0,1,2,4,5,6,7      -              15.16 MB  0 Bytes        16.00 MB
    1   roce-reserved-ingress  DYNAMIC  3        3                  -              15.16 MB  7.30 MB        7.90 MB
    2   lossy-default-egress   DYNAMIC  13       -                  0,6            15.16 MB  0 Bytes        16.01 MB
    3   roce-reserved-egress   DYNAMIC  14       -                  3              inf       7.29 MB        13.47 MB
```
Check RoCE pool status

```
cumulus@switch:mgmt:~$ nv show interface qos-roce-status-pool-map
-------------------------------------
Interface: swp1
-------------------------------------
    name                     mode      pool-id  switch-priorities  traffic-class     size     current-usage  max-usage
-   ---------------------    --------  -------  -----------------  -------------     -------  -------------  ---------
0   lossy-default-ingress    DYNAMIC    2         0,1,2,4,5,6,7       -              14.02 MB  0              0         
1   roce-reserved-ingress    DYNAMIC    3         3                   -              14.02 MB  0              0         
2   lossy-default-egress     DYNAMIC    13        -                   0,6            14.02 MB  0              0         
3   roce-reserved-egress     DYNAMIC    14        -                   3              inf       0              0         
-------------------------------------
Interface: swp2
-------------------------------------
    name                     mode      pool-id  switch-priorities  traffic-class     size     current-usage  max-usage
-   ---------------------    --------  -------  -----------------  -------------     -------  -------------  ---------
0   lossy-default-ingress    DYNAMIC    2         0,1,2,4,5,6,7       -              14.02 MB  0              0         
1   roce-reserved-ingress    DYNAMIC    3         3                   -              14.02 MB  0              0         
2   lossy-default-egress     DYNAMIC    13        -                   0,6            14.02 MB  0              0         
3   roce-reserved-egress     DYNAMIC    14        -                   3              inf       0              0         
-------------------------------------
Interface: swp3
-------------------------------------
    name                     mode      pool-id  switch-priorities  traffic-class     size     current-usage  max-usage
-   ---------------------    --------  -------  -----------------  -------------     -------  -------------  ---------
0   lossy-default-ingress    DYNAMIC    2         0,1,2,4,5,6,7       -              14.02 MB  0              0         
1   roce-reserved-ingress    DYNAMIC    3         3                   -              14.02 MB  0              0         
2   lossy-default-egress     DYNAMIC    13        -                   0,6            14.02 MB  0              0         
3   roce-reserved-egress     DYNAMIC    14        -                   3              inf       0              0         
...
```

### For memory
- nv show qos roce
Check global QoS profile

- nv show interface ... status
Check interface ASIC Config

- nv show interface ... counters
Check operational ECN、PFC、buffer pressure and packet loss

- nv show interface ... pool-map
Check interface SP/TC to buffer pool Mapping

## Change RoCE config
Some examples
1. Improve the switch handling brust RDMA traffic, inceasing the roce-lossless pool to 60%, reduce the default pool to 40% at the same time.
```
nv set qos traffic-pool default-lossy memory-percent 40
nv set qos traffic-pool roce-lossless memory-percent 60
nv config apply
```
2. Set RoCE to priority 4, and set dedicated 60% pool
- Remove priority 4 from default 
- Set roce-lossy pool to 60%
- Set default pool to 40%
- Set roce to priority 4
- Map priority 4 to TC 3
- Set Priority 3 to TC 0 (default)
- Trust both PCP and DSCP
- Map DSCP 26 to Priority 4
```
nv set qos traffic-pool default-lossy switch-priority 0-3,5-7
nv set qos traffic-pool roce-lossy memory-percent 60
nv set qos traffic-pool default-lossy memory-percent 40
nv set qos traffic-pool roce-lossy switch-priority 4
nv set qos egress-queue-mapping default-global switch-priority 4 traffic-class 3
nv set qos egress-queue-mapping default-global switch-priority 3 traffic-class 0
nv set qos mapping default-global trust both
nv set qos mapping default-global dscp 26 switch-priority 4
nv config apply
```
3. Moving Lossless RoCE from Switch Priority 3 to Switch Priority 2
- Enable PFC on priority 2
- Map priority 2 to TC 3
- Return priority 3 to TC 0
- Trust PCP and DSCP
- Map DSCP 26 to priority 2

```
nv set qos pfc default-global switch-priority 2
nv set qos egress-queue-mapping default-global switch-priority 2 traffic-class 3
nv set qos egress-queue-mapping default-global switch-priority 3 traffic-class 0
nv set qos mapping default-global trust both
nv set qos mapping default-global dscp 26 switch-priority 2
nv config apply
```