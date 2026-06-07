]633;E;echo "# Four-Leaf EVPN BGP Summary";fbf5a41f-2d56-4ae0-adfc-bae181e9a759]633;C# Four-Leaf EVPN BGP Summary

## spine1
BGP router identifier 10.255.0.1, local AS number 65000 vrf-id 0
BGP table version 0
RIB entries 7, using 1344 bytes of memory
Peers 4, using 2868 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.0.1        4      65101         0         0        0    0    0    never       Active        0 leaf1 eth1
10.0.0.3        4      65102        19        15        0    0    0 00:01:19            2        6 leaf2 eth1
10.0.0.9        4      65103        19        15        0    0    0 00:01:20            2        6 leaf1 eth1
10.0.0.11       4      65104        19        15        0    0    0 00:01:19            2        6 leaf2 eth1

Total number of neighbors 4

## spine2
BGP router identifier 10.255.0.2, local AS number 65000 vrf-id 0
BGP table version 0
RIB entries 7, using 1344 bytes of memory
Peers 4, using 2868 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.0.5        4      65101        18        18        0    0    0 00:01:20            2        8 leaf1 eth2
10.0.0.7        4      65102        19        18        0    0    0 00:01:20            2        8 leaf2 eth2
10.0.0.13       4      65103        19        18        0    0    0 00:01:21            2        8 leaf3 eth2
10.0.0.15       4      65104        19        18        0    0    0 00:01:20            2        8 leaf4 eth2

Total number of neighbors 4

## leaf1
BGP router identifier 10.255.1.1, local AS number 65101 vrf-id 0
BGP table version 0
RIB entries 7, using 1344 bytes of memory
Peers 2, using 1434 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.0.0        4      65000       158       158        0    0    0    never         Idle        0 spine1 eth1
10.0.0.4        4      65000        18        18        0    0    0 00:01:20            6        8 spine2 eth1

Total number of neighbors 2

## leaf2
BGP router identifier 10.255.1.2, local AS number 65102 vrf-id 0
BGP table version 0
RIB entries 7, using 1344 bytes of memory
Peers 2, using 1434 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.0.2        4      65000        15        19        0    0    0 00:01:19            4        8 spine1 eth2
10.0.0.6        4      65000        18        19        0    0    0 00:01:20            6        8 spine2 eth2

Total number of neighbors 2

## leaf3
BGP router identifier 10.255.1.3, local AS number 65103 vrf-id 0
BGP table version 0
RIB entries 7, using 1344 bytes of memory
Peers 2, using 1434 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.0.8        4      65000        15        19        0    0    0 00:01:20            4        8 spine1 eth3
10.0.0.12       4      65000        18        19        0    0    0 00:01:21            6        8 spine2 eth3

Total number of neighbors 2

## leaf4
BGP router identifier 10.255.1.4, local AS number 65104 vrf-id 0
BGP table version 0
RIB entries 7, using 1344 bytes of memory
Peers 2, using 1434 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.0.10       4      65000        15        19        0    0    0 00:01:20            4        8 spine1 eth4
10.0.0.14       4      65000        18        19        0    0    0 00:01:21            6        8 spine2 eth4

Total number of neighbors 2

