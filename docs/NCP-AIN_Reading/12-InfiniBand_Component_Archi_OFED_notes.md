# Some basic concepts
## Topology
Fat-tree, similar to traditional tree shape network. 
Torus 3D and Dragonfly+

Gateway is used for connection between IB network and Ethernet network 

Switch is used for node connection in local subnet

HCA, host channel adapter, adapter on host

Router, connection between subnets

IB low latency, 1ms

Subnet manager, automation tool for managing the local subnets

Each subnet support 48000 nodes

CPU offload and RDMA, communication without CPU, directly between RAM

# InfiniBand data packet
## InfiniBand Packet Format

| LRH | GRH | BTH | Extended Transport Header | Payload | ICRC | VCRC |
|---|---|---|---|---|---|---|
| 8 Bytes | 40 Bytes | 12 Bytes | Variable | 256–4096 Bytes | 4 Bytes | 2 Bytes |
| L2 – Link Layer | L3 – Network Layer | L4 – Transport Layer | L4 – Transport Layer | L5 – Upper Layer | Integrity Check | L2 – Link Layer |


## LRH, local route header
- source port
- destination port
- service level, SL
- VL

## GRH, global route header
GRH is required when the packet transfer cross subnets
- VCRC will be recalculated
- ICRC won't be changed

## BTH, base transport header
- OpCode, tag queue order, type
- PSN
- Partition Key

## ETH, Extended Transport Header
Based on CoS and OpCode

## CRC
- ICRC, invariant CRC, never change
- VCRC, Variant CRC, changed during transport


# IB Stream flow
--- On source node ---
1. Upler Layer Protocol create message, send to transport layer
2. Transport layer segment the message
3. Each segment is set a BTH
4. In Network layer, system will add GRH
5. In Link layer, system will add LRH, add CRC
--- On network ---
6. Packet arrives switch
7. Switch checks CRC
8. Switch checks LRH, locat the dest port, forward to the next hop
-- On destination node ---
Stip the header, reassemble the message

# InfiniBand management
Fabric's componenets
- Links
- Switches
- Routers
- HCA

Subnets is a logical domain, includes a group of ports and links, these ports has same subnet ID, controled by subnet manager.

Subnet manager is an active entity in a subnet, it discovers topology, allocate LID, calculate route, distribute LID table, monitor topo/link changes

Node, is an entity in the subnets, including switch, HCA and router. Each node runs a Subnet Manager Agent, SMA. SMA response to SM's query. When failure or state change, SMA sent traps message to SM.

The message between SM and SMA is Management Datagrams, MADs.

# InfiniBand Addressing and Forwarding
GUID, similar to MAC, it is a permanent address on the device.

LID, allocated by subnet manager, used for local forwarding inside of a subnet

GID, usded for forwarding cross subnets


| Abbreviation | Full Name | Scope | Assigned By | Primary Purpose |
|---|---|---|---|---|
| GUID | Globally Unique Identifier | Global and persistent | Hardware vendor, typically burned into the device | Identifies the physical hardware, such as a chassis, HCA, or port. |
| LID | Local Identifier | Local InfiniBand subnet | Subnet Manager (SM) | Used by InfiniBand switches to forward packets within the same subnet. |
| GID | Global Identifier | Global, including across subnets | Derived or configured | Used for addressing and routing between different InfiniBand subnets. |

## IB concept vs Ethernet concept

| Core Concept | InfiniBand (IB) | Ethernet | Key Difference and Analogy |
|---|---|---|---|
| Physical Hardware Identity | **GUID (Globally Unique Identifier)**<br>Programmed by the hardware vendor and remains permanently unchanged. | **MAC Address**<br>Programmed by the hardware vendor and normally remains unchanged. | Both act as the device's identity. In InfiniBand, however, the GUID is mainly used for identification and is not directly used for Layer 2 forwarding. |
| Layer 2 Forwarding Address<br>(Within a Subnet) | **LID (Local Identifier)**<br>Dynamically assigned by the Subnet Manager (SM).<br>InfiniBand switches forward packets based on the LID. | **MAC Address**<br>Usually serves as both the hardware identity and the forwarding address.<br>Ethernet switches forward frames based on MAC addresses. | The main difference is that Ethernet switches learn MAC addresses dynamically, while InfiniBand forwarding tables and LID mappings are centrally programmed by the SM. |
| Layer 3 Routing Address<br>(Across Subnets) | **GID (Global Identifier)**<br>A 128-bit address similar to an IPv6 address.<br>Derived from a subnet prefix and interface identifier, often related to the port GUID. | **IP Address**<br>32-bit for IPv4 or 128-bit for IPv6.<br>Used for routing between network segments. | Both provide global addressing across subnets. Routers use the GID or IP address to route traffic between different subnets. |
| Address Resolution<br>(How to Find the Destination) | **PathRecord Query**<br>The source queries the Subnet Administration service (SA) to obtain path information, including the destination LID. | **ARP / NDP**<br>The host discovers the link-layer address associated with a destination IP address. | InfiniBand uses a centralized directory-style query: “ask the administrator.” Ethernet/IP commonly uses distributed neighbor discovery: “ask the local network.” |
| Control Plane<br>(Who Controls the Network) | **SDN-Style Centralized Control**<br>The Subnet Manager has a complete view of the subnet and calculates paths for the fabric. | **Distributed Control**<br>Each switch or router independently runs protocols such as STP, OSPF, or BGP. | InfiniBand uses a centralized control model similar to SDN, while traditional Ethernet networks rely mainly on distributed protocols for path calculation and loop prevention. |


# InifiniBand OFED
OpenFabrics Enterprise Distribution, OFED. 
Opensource software development stack. Designed for RDMA and Kernel Bypass.

NVIDIA MLNX_OFED is a version for OFED.

The OFED utility suite helps administrators control, manage, and diagnose an InfiniBand fabric. Before running any OFED tool, verify that the OFED software stack is correctly installed and operational.

## OFED driver
login InfiniBand host, check if DOCA-OFED driver is installed
`sudo ofed_info -s`

Check if OFED driver service is running
`/etc/init.d/openibd status`

Check HCA hardware infomation.
`lspci | grep Mellanox`

Check if the host has been identified as network node
`ibstat`
- GUID
- LID
- Port State (Up & Active)
- Rate

Validate layer2 connectivity
`ibping -L 18` LID 18

Trace Host1(LID 13) to Host5(LID 18)
`ibtracert 13 18`


