]633;E;echo "# EVPN BGP Summary";fbf5a41f-2d56-4ae0-adfc-bae181e9a759]633;C# EVPN BGP Summary

## spine1
BGP router identifier 10.255.0.1, local AS number 65000 vrf-id 0
BGP table version 0
RIB entries 3, using 576 bytes of memory
Peers 2, using 1434 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.0.1        4      65101        15        15        0    0    0 00:04:26            2        4 leaf1 eth1
10.0.0.3        4      65102        15        15        0    0    0 00:04:26            2        4 leaf2 eth1

Total number of neighbors 2

## spine2
BGP router identifier 10.255.0.2, local AS number 65000 vrf-id 0
BGP table version 0
RIB entries 3, using 576 bytes of memory
Peers 2, using 1434 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.0.5        4      65101        15        15        0    0    0 00:04:25            2        4 leaf1 eth2
10.0.0.7        4      65102        15        15        0    0    0 00:04:26            2        4 leaf2 eth2

Total number of neighbors 2

## leaf1
BGP router identifier 10.255.1.1, local AS number 65101 vrf-id 0
BGP table version 0
RIB entries 3, using 576 bytes of memory
Peers 2, using 1434 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.0.0        4      65000        15        15        0    0    0 00:04:26            2        4 spine1 eth1
10.0.0.4        4      65000        15        15        0    0    0 00:04:25            2        4 spine2 eth1

Total number of neighbors 2

## leaf2
BGP router identifier 10.255.1.2, local AS number 65102 vrf-id 0
BGP table version 0
RIB entries 3, using 576 bytes of memory
Peers 2, using 1434 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.0.2        4      65000        15        15        0    0    0 00:04:26            2        4 spine1 eth2
10.0.0.6        4      65000        15        15        0    0    0 00:04:26            2        4 spine2 eth2

Total number of neighbors 2

