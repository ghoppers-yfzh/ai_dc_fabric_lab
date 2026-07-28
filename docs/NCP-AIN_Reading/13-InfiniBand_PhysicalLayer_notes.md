# HCA
For single port node, the node GUID == port GUID
For multi ports node, the first node GUID == port GUID, the second node GUID == port GUID +1

HCA supports transport-layer CPU offload.

```
Application posts RDMA Write WQE
              ↓
HCA reads WQE
              ↓
HCA obtains data from registered memory
              ↓
HCA creates IB packets
              ↓
HCA transmits packets through PHY
              ↓
Remote HCA writes data into remote memory
```


# Speed
Lane speed x Lane count

- EDR, single channel speed 25Gbps
- HDR, single channel speed 50Gbps
- NDR, single channel speed 100Gbps
- XDR, single channel speed 200Gbps

# Cables
DAC, copper cable, 4 channels x 4
AOC, fiber cable, 4 peers, usually MMF

DAC
|Data Rates|Form Factor|Max Reach|
|---|---|---|
|HDR|QSFP56|2m|
|EDR|QSFP28|5m|
|NDR|QSFP|4m|

AOC
|Data Rates|Form Factor|Max Reach|
|---|---|---|
|HDR|QSFP56|100m|
|EDR|QSFP28|100m|
|NDR|QSFP|300m|

Choose from DAC and AOC
```
Required speed
    ↓
Required distance
    ↓
Supported connector
    ↓
Power and thermal budget
    ↓
Cable density and airflow
    ↓
Patch-panel requirement
    ↓
Cost and replaceability
```
```
Same rack       → DAC first
Across racks    → AOC or optics
Long distance   → transceiver + fiber
```


# Link state
```
Port 1:
    State: Active
    Physical state: LinkUp
    Rate: 400
    Base lid: 123
    SM lid: 1
    Link layer: InfiniBand
```
Port state
- Disabled
- Polling
- Training
- LinkUp
- LinkErrorRecovery

## Link training
```
Detect peer
    ↓
Exchange capabilities
    ↓
Negotiate lane width and speed
    ↓
Equalization / signal adjustment
    ↓
Lane alignment
    ↓
LinkUp
```

# GUID
System Image GUID, manage multiple logical GUID as single unit

Node GUID is the uniq address on fabric for nodes such as HCA, switch, router

Port GUID is used to identify the physical port on HCA.

- Single system GUID for the chassis
- Each swtich module within the chassis is assigned a node GUID

```
Chassis
├── System Image GUID
├── Switch Module 1 → Node GUID 1
├── Switch Module 2 → Node GUID 2
├── Switch Module 3 → Node GUID 3
├── Switch Module 4 → Node GUID 4
├── Switch Module 5 → Node GUID 5
└── Switch Module 6 → Node GUID 6
```


# DOCA-OFED

Some checks
- ibportstate # check port state, logical and physical
- ibswitches # list all the switches in subnet
- ibhosts # get HCA information in the suabnet
- ibnodes # combination of ibswitches and ibhosts, global view of the fabric
- ibv_devices # list system detected RDMA devices
- ibstat # Local HCA port state, speed and GUID
- ib_devinfo # RDMA device capabilities
- iblinkinfo # show link information port by port
- ibnetdiscover # discover and represent the whole fabric topology
- perfquery # check port performance/error counters
- ibqueryerrors # summarise fabric port errors
- ibdiagnet # diagnose the fabric

TS flows
1. Check local
```
ibv_devices
ibstat
```
2. Check links
3. Check logical state
4. Check fabric discovery
```
ibswitches
ibhosts
ibnodes
```
5. Check link connection 
```
iblinkinfo
ibnetdiscover
```
6. Check error coutners
```
perfquery
ibqueryerrors
```
# Summary
```
CPU / GPU / Memory
        ↓
       HCA
  RDMA + transport offload
        ↓
      IB packet
        ↓
   PHY / SerDes
 rate + width + training
        ↓
 QSFP / OSFP connector
        ↓
 DAC / AOC / optics
        ↓
   Switch physical port
        ↓
 GUID identifies devices
 LID forwards packets
        ↓
 OFED tools monitor fabric
```
