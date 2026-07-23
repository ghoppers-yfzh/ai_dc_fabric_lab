# What is InfiniBand
InfiniBand is a high-speed low latency network standard used primarily in supercomputers, AI cluster.

## Architecture Layers
End to End solution
```
Upper Layer
    |
Tranport Layer
    |
Network Layer
    |
Link Layer
    |
Physical Layer
```
## Infiniband Fabric Components
InfiniBand Fabric:
Host connect to IB Switch via HCA(Host Channel Adapter)
SM(Subnet manager) works in Master-Standby mode for topology discovery, route path selection and configuration
L3 router is usded for connection between different IB subnets, and external ethernet network connection.

### IB swtiches
QM8700. 
NVIDIA Mellanox Quantum HDR, edge swtich. 
1RU, 40x 200Gb/s HDR high-speed ports

CS8500.
NVIDIA Mellanox Quantum HDR, chassis switch.
800x 200Gb/s port. Build Fat-Tree topo in one chassis.

### ConnectX InfiniBand Adapters
Network adapter for 200Gb/s

### InfiniBand to Ethernet Gateway SYstems
NVIDIA Mellanox Skyway: Gateway device, connecting EDR/HDR InfiniBand with 100G/200G Ethernet network.

### LinkX InfiniBand Cables
AOC and DAC cables for 200Gb/s HDR QSFP56

## Simplified Management
SDN
Subnet manager is a management application. 
```
Subnet Manager
      ↓
Discover IB subnet topology
      ↓
Calculate path between all nodes
      ↓
Send forwarding table to IB switch
```

### Topology discovery
SM scan the whole InfiniBand subnet, identify:
- IB switch
- HCA, the IB network adapter on host
- Connection between ports
- Up running links
- Link state and speed
From a topology map
```
GPU Server 1
     |
   Leaf 1
    /  \
Spine 1 Spine 2
    \  /
   Leaf 2
     |
GPU Server 2
```
### Allocate LID for ports
LID, local identifier

GUID is a permanent ID
LID is a local forwarding address in IB subnet

SM allocate LID for port after it is discoverd.

IB swtich forwarding is based on LID

### Calculate forwarding path
Considerations:
- Shortest path
- Multipath load balance
- Fat-Tree topo
- Hotspot avoid
- GPU cluster communication mode
- Specfied routing

Different routing engines:
- Min Hop
- Fat tree
- Up/Down
- DOR
- Dragonfly

### Send fowarding table to switch
SM will config IB swtich's LFT, Linear Forwarding Table, `Destination LID -> Output Port`

This is different with the Ethernet MAC address table which is learned from data plane. 
IB's LFT is from SM.

### Port state management
IB port state
```
Down
  ↓
Initializing
  ↓
Armed
  ↓
Active
```

SM handles:
- Discover port
- Allocate LID
- Config path
- Config parameters
- Set port to Active state

Without SM, new port stays in init state.

### SM master adn standby
One master SM at a time.
```
          Master SM
              |
    topology / routing / LFT
              |
       InfiniBand Fabric

          Standby SM
       monitor Master state
```

When SM master stop working
```
Master SM failure
      ↓
Standby SM detects master failure
      ↓
 SM election or role change
      ↓
Standby becomes new Master
      ↓
Continue manage Fabric
```


SM is like
```
Topology discovery
+ IP address / identifier assignment
+ IGP path calculation
+ Routing controller
+ Switch configuration automation
+ Fabric lifecycle management
```
## Bandwidth

|Standard|Full Name|Bandwidth|BWxChannel|
|---|---|---|---|
|SDR|Single Data Rate|10 Gb/s|2.5 Gb/s × 4|
|QDR|Quadruple Data Rate|40 Gb/s|10 Gb/s × 4|
|FDR|Fourteen Data Rate|56 Gb/s|14 Gb/s × 4|
|EDR|Enhanced Data Rate|100 Gb/s|25 Gb/s × 4|
|HDR|High Data Rate|200 Gb/s|50 Gb/s × 4|
|NDR|Next Data Rate|400 Gb/s|100 Gb/s × 4|


## Some notes

- Network Scale-out
48000 node per single subnet, IB router can join multiple subnets.

- Fabric Resiliency,
5 sec for SM to recalcuate the new path.

- NVIDIA Self-Healing Networking
- Multipath loadbalance
- Adaptive Routing, managed by Adaptive Routing Manager.
When enabled, switch's Queue manager keeps monitoring the queue, adjust the load. It can be enabled on all the switches in fabric
- SHARP（Scalable Hierarchical Aggregation and Reduction Protocol)

```
Application / PyTorch
          ↓
         NCCL
          ↓
   NCCL-SHARP Plugin
          ↓
      ConnectX HCA
          ↓
┌───────────────────────────────┐
│ InfiniBand SHARP Fabric       │
│                               │
│ GPU data ──> Leaf AN ──┐      │
│ GPU data ──> Leaf AN ──┼─> Root AN
│ GPU data ──> Leaf AN ──┘      │
│                       SUM     │
└───────────────────────────────┘
          ↓
   Result distributed
          ↓
      All GPUs
```
SHARP does reducing for GPU gradients

## InfiniBand Topologies
- Fat Tree
- Torus
- Dragonfly+
- Hypercube
- HyperX

# InfiniBand Architecture Layers
## Upper Layer
Application can use upper layer's interface for communication. Comparing with the traditional TCP/IP stack.

Upper layer protocols:
- MPI # HPC's communication
- NCCL # NVIDIA's GPU communication library
- Storage protocol on RDMA
- IP over InfiniBand # IP application can also running on IB network

## Transport Layer
HCA (Host Channel Adapter) handles data transfer on HW.
Application send message to HCA directly

## Network Layer
InfiniBand router connects different InfiniBand Subnets together.
Router forards packet based on GID (Global ID)

## Link Layer
LIDs - Local IDs

Every node in a IB subnet will be allocated a LID. It is used for communication inside of the subnet. LID is managed by Subnet manager.

Switch forwarding tables is for LID to port mapping.

A packet from a node including source LID and destination LID.

Flow Control adjust the data transfer speed between sender and receiver, this make sure the receiver has enough buffer.

## Physical Layer
DAC and AOC cable

1 HDR Link include 4 lanes, each Lane is 50Gbps, it is 200Gb/s in total