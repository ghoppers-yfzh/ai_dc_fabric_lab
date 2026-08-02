# Fabric and subnet
Fabric includes the physical parts, links, switches, and routers.
Subnet is management and forwarding domain, a group of port and links which has same subnet ID and is managed by the same SM.

Subnet Manager:
- Discover topology
- Allocate LID
- Calculate and config swtich forwarding table
- manage the nodes in fabric
- Monitor subnet state change

Each node in the fabric needs a subnet manager agent, SMA.

SM  = Controller
SMA = Device-side agent

# Subnet discover

SM
 ↓ Switch C port 4
 ↓ Switch A port 2
 ↓ Switch D port 3
 ↓ Host 10

SM uses Subnet Management Packet, SMP to for discover which doesn't rely on LID, VL 15  is reserved for SMP.

SM sends:
- Get NodeInfo
- Get PortInfo
Switch returns:
- I'm a switch
- I have xxx ports
- My GUID is
- I have these port is in up status

The process is:
```
SM
 └── Switch C
      ├── Switch A
      │    └── Switch D
      │         └── HCA
      └── other neighbors
```

HCA is the edge for the fabric, it does not relay the discover.

## Information SM collects
Node level information:
- Node Type
- Node GUID
- Port count
- Node Description
- Node is HCA, Switch or Router

Port level information:
- Port GUID
- Physical status
- Logical status
- Link width
- Link speed
- MTU
- VL
- Current LID
- Port config capacity

SM builds a full topology in RAM:
```
Node GUID
 ├── Port 1
 │    └── connected to Switch X Port 4
 ├── Port 2
 │    └── connected to Switch Y Port 7
 └── ...
```
# GUID vs LID
GUID is a permanent ID for device and port, device vendor specific

LID is the forwarding address in subnet

# LID Allocation
Every port of the HCA can connect to the fabric, they get different LID.

Single switch get one LID.

Multi-chassis swtich gets multiple LID, one for each switch module

# Forwarding path
Min Hop
1. choose the path with least hop counts
2. choose the path with less DLID ports if the hop counts is the same

Linear Forwarding Table, LFT: Destination LID -> Ouput port

# Port config
When forwarding path caculation is complete, SM will set the parameters on ports:
1. LID
2. Link Width, how mane lane
3. Link Speed
4. MTU
5. VL and VL to QoS mapping

SL is service level, it is tag for class

VL is Virtual Lane, logical line and flow control

Port state in subnet
`Down → Init → Armed → Active`

| Physical State | Logical State | Meaning | Troubleshooting |
|---|---|---|---|
| `Polling` | `Down` | The port is searching for a peer, but no physical link has been established. | Check the cable or optical module, verify the peer port is enabled, confirm both ends support compatible link speed and width, and inspect for hardware faults. |
| `Training` | `Down` | The two endpoints are establishing synchronization and negotiating the physical link. | If the port remains in this state, check cable quality, transceiver compatibility, link speed/width negotiation, signal integrity, and the peer port status. |
| `LinkUp` | `Init` | The physical link is established, but the port has not been fully configured by the Subnet Manager. Only management and link-level control traffic can pass. | Verify that a Subnet Manager is running, confirm the port is visible to the SM, check whether a LID has been assigned, and review SM logs for discovery or configuration errors. |
| `LinkUp` | `Armed` | The port has received its configuration and is ready to become operational, but normal traffic is not yet enabled. | Check whether the SM has completed subnet activation, verify routing and LFT programming, confirm MTU and VL settings, and review SM logs for activation failures. |
| `LinkUp` | `Active` | The port is fully initialized and can transmit normal InfiniBand traffic. | If communication still fails, check the destination LID, switch LFT entries, path MTU, P_Key membership, Queue Pair state, application/RDMA configuration, and error counters. |


# Fowarding process
1. Check LID in Local Route Header
2. Check SL, check SL-VL mapping

```
DLID → LFT → Output Port
                  ↓
             SL-to-VL
                  ↓
                 VL
                  ↓
          VL Arbitration
                  ↓
              forwarding packet
```

