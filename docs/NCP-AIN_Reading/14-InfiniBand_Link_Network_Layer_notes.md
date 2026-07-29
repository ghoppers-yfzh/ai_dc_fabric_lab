# Data Link Layer
Services
- Packet management
- layer2 addressing
- QoS
- forwarding
- Flow control
- Data integraty

Payload is between packet Header and CRC
## LID
LID is link layer addressing, it is in LRH(local routing header)

LID is allocated when
- Subnet manager initilization
- Topology change deteced

Each HCA port will has one LID. Single for switch normally has one LID, each modular switch in a chassis has one LID. 

Each subnet support 48000 unicast LID and 16000 multicast LID

## QoS
QoS in LRH
- Service Level, SL # class for each group
- Virtual Lanes, VL # VL0 is standard channel, VL15 is management channel, VL1-14 is for data traffic

## LFT
Linear Forwarding Table, LFT

Switch has SL to VL mapping, different class packet get into different VL

## Switch forwarding
`ibswitches` shows all the switch nodes in subnet, it shows switch GUID and LID. For example we know a switch's LID is 10. Using `ibroute 10` to check the swtich LID to port mapping table. Port0 is the switch internal management.

## Lossless Fabric

### Credit
Receiver tells sender how many credits it has. Sender can't send more than that.

Credit works by hop, not end to end, each hop only knows the status of its next hop.

Credit is by VL on a single physicle link
```
VL0 credits: 20
VL1 credits: 0
VL2 credits: 12
VL3 credits: 8
```

QoS on VL:
```
Application traffic
        ↓
Service Level (SL)
        ↓
SL-to-VL mapping
        ↓
Virtual Lane (VL)
        ↓
Independent queue and credits
        ↓
Physical link
```

It is different with Ethernet PFC, QoS on VL is in IB link layer


## CRC
VCRC, Variant CRC # per hop CRC
```
Previous device calculates VCRC
        ↓
Packet crosses physical link
        ↓
Next device verifies VCRC
        ↓
Device may modify permitted fields
        ↓
New VCRC is calculated for next link
```

ICRC, Invariant CRC # End to end CRC

## OFED Validation
`iblinkinfo` checks all links in fabric

`ibnetdiscover` 
- Discover IB network topology, generaate a topo file
- Display nodes type, description, link state, port ID, LID and GUID, if the command is excute with file name, the output will be saved in the file.

When a packet is send from one server to the other
```
1. Application / NCCL generates data
                    ↓
2. InfiniBand transport creates packets
                    ↓
3. Source calculates ICRC
                    ↓
4. Link layer calculates VCRC
                    ↓
5. Sender checks downstream VL credits
                    ↓
6. Enough credits → transmit
   No credits     → wait in VL queue
                    ↓
7. Each switch verifies VCRC
                    ↓
8. Switch forwards and recalculates VCRC
                    ↓
9. Destination verifies VCRC and ICRC
                    ↓
10. Reliable transport checks PSN / ACK
                    ↓
11. Data is delivered or retransmitted
```



# Network Layer
Layer3 for InfiniBand. 

GID in GRH. 128 bit, similar to ipv6 address. Allocated by subnet manager, each HCA has a default GID, start with prefix FE80, same as IPv6 LLA.

## OFED validation
- `ibv_devices` shows IB  devices on the local host.
- `ibaddr` check GID and ID information



