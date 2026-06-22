# Lab 05 IP and ASN Plan

## Nodes

| Node | Role | ASN | Loopback0 |
|---|---|---:|---|
| spine1 | Spine | 65001 | 10.255.0.1/32 |
| spine2 | Spine | 65002 | 10.255.0.2/32 |
| leaf1 | Leaf | 65101 | 10.255.0.11/32 |
| leaf2 | Leaf | 65102 | 10.255.0.12/32 |

## Point-to-point links

| Link | Spine interface | Spine IP | Leaf interface | Leaf IP |
|---|---|---|---|---|
| spine1 - leaf1 | spine1 Ethernet0 | 10.0.11.0/31 | leaf1 Ethernet0 | 10.0.11.1/31 |
| spine2 - leaf1 | spine2 Ethernet0 | 10.0.12.0/31 | leaf1 Ethernet4 | 10.0.12.1/31 |
| spine1 - leaf2 | spine1 Ethernet4 | 10.0.21.0/31 | leaf2 Ethernet0 | 10.0.21.1/31 |
| spine2 - leaf2 | spine2 Ethernet4 | 10.0.22.0/31 | leaf2 Ethernet4 | 10.0.22.1/31 |

## Containerlab interface mapping used in this lab

| Containerlab endpoint | SONiC front-panel interface |
|---|---|
| eth1 | Ethernet0 |
| eth2 | Ethernet4 |

The lab also brings up `eth1` and `eth2` from `topology.clab.yml` because this SONiC VS image may leave the Linux-side veth interfaces down after deploy.
