# Some commands

|CMD|Description|
|---|---|
|ofed_info|Check DOCA_OFED driver version|
|lspci|Check HCA type and version|
|ibstat|Show InfiniBand network node's link state|
|ibportstate <lid> <port>|Show IB network port's state|
|ibroute <lid>|Show specific IB switch's LTD|
|ibv_devices|List IB device in system (HCA)|
|ibv_devinfo|Show InfiniBand device (HCA) details|
|ibswitches|Identify switch in InfiniBand Fabric|
|ibhosts|Identify HCA in InfiniBand Fabric|
|ibnodes|Identify all the nodes in InfiniBand Fabric|
|ibnetdiscover|Show node to node connectivity|
|iblinkinfo|List all the nodes and connectivity in Fabric|
|sminfo|Identify Maseter SM in Fabric|
|ibping|Test connectivity between nodes on IB using simple ping-pong test|
|ibtracert <slid> <dlid>|Show route path between two nodes in IB Fabric|
|ibdiagnet|	Diagnose InfiniBand Fabric health status|
|ib_write_lat|Check RDMA WRITE latency between two nodes in Fabric|
|ib_read_lat|Check RDMA READ latency between two nodes in Fabric|
|ib_write_bw|Check RDMA WRITE BW between two nodes in Fabric|
|ib_read_bw|Check RDMA READ BW between two nodes in Fabric|


# ibdiagnet
ibdiagnet is part of the ibutils2 package. It is in DOCA-OFED and UFM package.
For Inbox user, it can be found in the InfiniBand management packet on NVIDIA website.

ibdiagnet uses Directed Route packet to scan the whole network, collects all the connectivity and device inforamtion.

ibdiagnet collects information from switch, HCA, router, connections, gateway. It checks and report duplicated nodes and port GUID, warn the duplicate node, check switch and HCA node description. It also validate LID allocation, duplication and report any link in init state.

ibdiagnet also reports the non-responce device and the direct route to those.
It checks numbers from different counters against threshold. It also does credit loop free check, routing check, match the current topology against the stored topology, store and validate HCA/Switch's partition, reports high BER links.

Routing check
```
Routing Engine
      ↓
calculates paths
      ↓
LFT / AR tables
      ↓
ibdiagnet
      ↓
validates paths
      ↓
checks credit loops
```

Port counters:
- Traffic counters # PortXmitPackets, PortRcvPackets # large number
- Error counters # Symbol/PHY/Receive/Error counters # keep low, no increasing
- Congestion/backpressure coutners # PortXmitWait

| Feature | Description |
|---|---|
| Fabric Discovery | Scans the InfiniBand Fabric and collects information about InfiniBand devices, including switches, HCAs, routers, aggregation nodes, and gateways. |
| Duplicated GUIDs | Checks for and reports duplicate Node GUIDs and Port GUIDs in the Fabric. |
| Duplicate Node Description | Checks for duplicate Node Descriptions on switches and HCAs and generates warnings when duplicates are found. |
| LIDs Check | Validates LID assignments and checks InfiniBand devices for duplicate LIDs. |
| Links in INIT State and Unresponsive Nodes | Reports links that remain in the INIT logical state. It also reports unresponsive devices and the Direct Routes used to reach them. |
| Counters Fetch | Retrieves various counters from InfiniBand devices, including standard and extended port counters, diagnostic counters, and physical-layer counters. |
| Error Counters Check | Checks for error counters that exceed configured thresholds between counter snapshots. |
| Routing Fetch and Checks | Retrieves and validates switch routing tables and checks whether the routing is credit-loop free. |
| Link Width and Speed Checks | Verifies that Fabric links are operating at the maximum supported link width and speed. |
| Topology Matching | Compares the current Fabric topology with a previously stored topology. |
| Partition Checks | Dumps and validates partition tables on HCAs and switches. |
| BER Test | Reports links with a high Bit Error Rate (BER). |


| File | Description |
|---|---|
| `ibdiagnet2.log` | Main ibdiagnet log file. |
| `ibdiagnet2.lst` | Fabric link list in LST format. |
| `ibdiagnet2.net_dump` | Fabric link dump containing cable mapping and FEC (Forward Error Correction) information. |
| `ibdiagnet2.sm` | List of Subnet Managers in the Fabric. |
| `ibdiagnet2.pm` | InfiniBand-compliant port counters. |
| `ibdiagnet2.fdbs` | Unicast forwarding database (FDB) tables. |
| `ibdiagnet2.ar` | Adaptive Routing tables. |
| `ibdiagnet2.nodes_info` | Node information, including firmware versions and other device details. |
| `ibdiagnet2.pkey` | P_Key partition tables. |
| `ibdiagnet2.slvl` | SL-to-VL mapping tables for Fabric switches. |
| `ibdiagnet2.ibnetdiscover` | Discovered network topology in `ibnetdiscover` format. |

-I: information
-W: Warning
# Packet Capture
tcpdump can only capture TCP/IP packet, because IB packet bypass Kernel, ibdump does the work.

`sudo ibdump -d mlx5_0 -w my-file.pcap`, capture device mlx5_0 write in to my-file.pcap


