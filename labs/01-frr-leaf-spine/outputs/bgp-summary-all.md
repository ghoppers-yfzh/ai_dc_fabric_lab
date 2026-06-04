## All BGP deploied

```
$ containerlab destroy -t topology.clab.yml --cleanup
04:29:33 INFO Parsing & checking topology file=topology.clab.yml
04:29:33 INFO Parsing & checking topology file=topology.clab.yml
04:29:33 INFO Destroying lab name=frr-leaf-spine
04:29:36 INFO Removed container name=clab-frr-leaf-spine-host4
04:29:37 INFO Removed container name=clab-frr-leaf-spine-host2
04:29:37 INFO Removed container name=clab-frr-leaf-spine-leaf1
04:29:38 INFO Removed container name=clab-frr-leaf-spine-host1
04:29:38 INFO Removed container name=clab-frr-leaf-spine-spine1
04:29:40 INFO Removed container name=clab-frr-leaf-spine-spine2
04:29:40 INFO Removed container name=clab-frr-leaf-spine-leaf2
04:29:40 INFO Removed container name=clab-frr-leaf-spine-leaf3
04:29:40 INFO Removed container name=clab-frr-leaf-spine-host3
04:29:40 INFO Removed container name=clab-frr-leaf-spine-leaf4
04:29:40 INFO Removing host entries path=/etc/hosts
04:29:40 INFO Removing SSH config path=/etc/ssh/ssh_config.d/clab-frr-leaf-spine.conf
$ containerlab deploy -t topology.clab.yml 
04:29:48 INFO Containerlab started version=0.75.0
04:29:48 INFO Parsing & checking topology file=topology.clab.yml
04:29:48 INFO Creating docker network name=clab IPv4 subnet=172.20.20.0/24 IPv6 subnet=3fff:172:20:20::/64 MTU=0
04:29:48 INFO Creating lab directory path=/home/yifan/ai_dc_fabric_lab/labs/01-frr-leaf-spine/clab-frr-leaf-spine
04:29:49 INFO Creating container name=spine2
04:29:49 INFO Creating container name=leaf2
04:29:49 INFO Creating container name=host3
04:29:49 INFO Creating container name=leaf1
04:29:49 INFO Creating container name=host4
04:29:49 INFO Creating container name=leaf4
04:29:49 INFO Creating container name=leaf3
04:29:49 INFO Creating container name=spine1
04:29:49 INFO Creating container name=host2
04:29:49 INFO Creating container name=host1
04:29:53 INFO Created link: spine1:eth3 ▪┄┄▪ leaf3:eth1
04:29:53 INFO Created link: leaf3:eth3 ▪┄┄▪ host3:eth1
04:29:54 INFO Created link: spine1:eth1 ▪┄┄▪ leaf1:eth1
04:29:54 INFO Created link: leaf1:eth3 ▪┄┄▪ host1:eth1
04:29:54 INFO Created link: spine1:eth4 ▪┄┄▪ leaf4:eth1
04:29:54 INFO Created link: leaf4:eth3 ▪┄┄▪ host4:eth1
04:29:54 INFO Created link: spine2:eth1 ▪┄┄▪ leaf1:eth2
04:29:54 INFO Created link: spine2:eth3 ▪┄┄▪ leaf3:eth2
04:29:54 INFO Created link: spine1:eth2 ▪┄┄▪ leaf2:eth1
04:29:54 INFO Created link: spine2:eth4 ▪┄┄▪ leaf4:eth2
04:29:54 INFO Created link: spine2:eth2 ▪┄┄▪ leaf2:eth2
04:29:54 INFO Created link: leaf2:eth3 ▪┄┄▪ host2:eth1
04:29:54 INFO Adding host entries path=/etc/hosts
04:29:54 INFO Adding SSH config for nodes path=/etc/ssh/ssh_config.d/clab-frr-leaf-spine.conf
04:29:55 INFO containerlab version
  🎉=
  │ A newer containerlab version (0.76.0) is available!
  │ Release notes: https://containerlab.dev/rn/0.76/
  │ Run 'clab version upgrade' or see https://containerlab.dev/install/ for other installation options.
╭────────────────────────────┬──────────────────────┬─────────┬───────────────────╮
│            Name            │      Kind/Image      │  State  │   IPv4/6 Address  │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-host1  │ linux                │ running │ 172.20.20.7       │
│                            │ alpine:latest        │         │ 3fff:172:20:20::7 │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-host2  │ linux                │ running │ 172.20.20.11      │
│                            │ alpine:latest        │         │ 3fff:172:20:20::b │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-host3  │ linux                │ running │ 172.20.20.5       │
│                            │ alpine:latest        │         │ 3fff:172:20:20::5 │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-host4  │ linux                │ running │ 172.20.20.2       │
│                            │ alpine:latest        │         │ 3fff:172:20:20::2 │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-leaf1  │ linux                │ running │ 172.20.20.6       │
│                            │ frrouting/frr:latest │         │ 3fff:172:20:20::6 │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-leaf2  │ linux                │ running │ 172.20.20.10      │
│                            │ frrouting/frr:latest │         │ 3fff:172:20:20::a │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-leaf3  │ linux                │ running │ 172.20.20.4       │
│                            │ frrouting/frr:latest │         │ 3fff:172:20:20::4 │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-leaf4  │ linux                │ running │ 172.20.20.8       │
│                            │ frrouting/frr:latest │         │ 3fff:172:20:20::8 │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-spine1 │ linux                │ running │ 172.20.20.3       │
│                            │ frrouting/frr:latest │         │ 3fff:172:20:20::3 │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-spine2 │ linux                │ running │ 172.20.20.9       │
│                            │ frrouting/frr:latest │         │ 3fff:172:20:20::9 │
╰────────────────────────────┴──────────────────────┴─────────┴───────────────────╯
$ tree
.
├── asn-plan.md
├── clab-frr-leaf-spine
│   ├── ansible-inventory.yml
│   ├── authorized_keys
│   ├── nornir-simple-inventory.yml
│   └── topology-data.json
├── configs
│   ├── common
│   │   └── daemons
│   ├── leaf1
│   │   ├── bgpd.conf
│   │   └── zebra.conf
│   ├── leaf2
│   │   ├── bgpd.conf
│   │   └── zebra.conf
│   ├── leaf3
│   │   ├── bgpd.conf
│   │   └── zebra.conf
│   ├── leaf4
│   │   ├── bgpd.conf
│   │   └── zebra.conf
│   ├── spine1
│   │   ├── bgpd.conf
│   │   └── zebra.conf
│   └── spine2
│       ├── bgpd.conf
│       └── zebra.conf
├── failure-tests
├── failure-tests.md
├── ip-plan.md
├── learning-outline.md
├── outputs
│   ├── frr-basic-checks.md
│   └── spine1-leaf1-bgp.md
├── README.md
├── topology.clab.yml
└── validation.md

12 directories, 26 files
$ for n in spine1 spine2 leaf1 leaf2 leaf3 leaf4; do echo "### $n show bgp all summary ###"; docker exec clab-frr-leaf-spine-$n vtysh -c "show bgp all summary"; echo "### End ###"; done
### spine1 show bgp all summary ###
% Can't open configuration file /etc/frr/vtysh.conf due to 'No such file or directory'.

IPv4 Unicast Summary (VRF default):
BGP router identifier 10.255.0.1, local AS number 65000 vrf-id 0
BGP table version 5
RIB entries 9, using 1728 bytes of memory
Peers 4, using 2868 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.0.1        4      65101         9         8        0    0    0 00:00:10            1        5 N/A
10.0.0.3        4      65102         9         8        0    0    0 00:00:09            1        5 N/A
10.0.0.5        4      65103         9         8        0    0    0 00:00:10            1        5 N/A
10.0.0.7        4      65104         9         8        0    0    0 00:00:10            1        5 N/A

Total number of neighbors 4
### End ###
### spine2 show bgp all summary ###
% Can't open configuration file /etc/frr/vtysh.conf due to 'No such file or directory'.

IPv4 Unicast Summary (VRF default):
BGP router identifier 10.255.0.2, local AS number 65000 vrf-id 0
BGP table version 5
RIB entries 9, using 1728 bytes of memory
Peers 4, using 2868 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.0.9        4      65101         9         8        0    0    0 00:00:09            1        5 N/A
10.0.0.11       4      65102         9         8        0    0    0 00:00:09            1        5 N/A
10.0.0.13       4      65103         9         8        0    0    0 00:00:09            1        5 N/A
10.0.0.15       4      65104         9         8        0    0    0 00:00:09            1        5 N/A

Total number of neighbors 4
### End ###
### leaf1 show bgp all summary ###
% Can't open configuration file /etc/frr/vtysh.conf due to 'No such file or directory'.

IPv4 Unicast Summary (VRF default):
BGP router identifier 10.255.1.1, local AS number 65101 vrf-id 0
BGP table version 8
RIB entries 11, using 2112 bytes of memory
Peers 2, using 1434 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.0.0        4      65000         8         9        0    0    0 00:00:11            4        6 N/A
10.0.0.8        4      65000         8         9        0    0    0 00:00:10            4        6 N/A

Total number of neighbors 2
### End ###
### leaf2 show bgp all summary ###
% Can't open configuration file /etc/frr/vtysh.conf due to 'No such file or directory'.

IPv4 Unicast Summary (VRF default):
BGP router identifier 10.255.1.2, local AS number 65102 vrf-id 0
BGP table version 9
RIB entries 11, using 2112 bytes of memory
Peers 2, using 1434 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.0.2        4      65000         8         9        0    0    0 00:00:10            4        6 N/A
10.0.0.10       4      65000         8         9        0    0    0 00:00:10            4        6 N/A

Total number of neighbors 2
### End ###
### leaf3 show bgp all summary ###
% Can't open configuration file /etc/frr/vtysh.conf due to 'No such file or directory'.

IPv4 Unicast Summary (VRF default):
BGP router identifier 10.255.1.3, local AS number 65103 vrf-id 0
BGP table version 8
RIB entries 11, using 2112 bytes of memory
Peers 2, using 1434 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.0.4        4      65000         8         9        0    0    0 00:00:11            4        6 N/A
10.0.0.12       4      65000         8         9        0    0    0 00:00:10            4        6 N/A

Total number of neighbors 2
### End ###
### leaf4 show bgp all summary ###
% Can't open configuration file /etc/frr/vtysh.conf due to 'No such file or directory'.

IPv4 Unicast Summary (VRF default):
BGP router identifier 10.255.1.4, local AS number 65104 vrf-id 0
BGP table version 8
RIB entries 11, using 2112 bytes of memory
Peers 2, using 1434 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.0.6        4      65000         8         9        0    0    0 00:00:11            4        6 N/A
10.0.0.14       4      65000         8         9        0    0    0 00:00:10            4        6 N/A

Total number of neighbors 2
### End ###
$ ```