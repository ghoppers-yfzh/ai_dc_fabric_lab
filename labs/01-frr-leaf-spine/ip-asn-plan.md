# IP and ASN Plan — FRR Leaf-Spine Lab

## 1. Addressing Goals

This lab uses simple IPv4 addressing so the eBGP underlay is easy to understand and troubleshoot.

Addressing blocks:

| Purpose | Prefix |
|---|---|
| Loopbacks | `10.255.0.0/24`, `10.255.1.0/24` |
| Spine-leaf point-to-point links | `10.0.0.0/24` carved into `/31`s |
| Host-facing links | `192.168.1.0/24` to `192.168.4.0/24` |

## 2. Interface Convention

| Node | Interface | Connected To |
|---|---|---|
| `spine1` | `eth1` | `leaf1 eth1` |
| `spine1` | `eth2` | `leaf2 eth1` |
| `spine1` | `eth3` | `leaf3 eth1` |
| `spine1` | `eth4` | `leaf4 eth1` |
| `spine2` | `eth1` | `leaf1 eth2` |
| `spine2` | `eth2` | `leaf2 eth2` |
| `spine2` | `eth3` | `leaf3 eth2` |
| `spine2` | `eth4` | `leaf4 eth2` |


## 3. Loopback Addresses

| Node | Loopback |
|---|---|
| `spine1` | `10.255.0.1/32` |
| `spine2` | `10.255.0.2/32` |
| `leaf1` | `10.255.1.1/32` |
| `leaf2` | `10.255.1.2/32` |
| `leaf3` | `10.255.1.3/32` |
| `leaf4` | `10.255.1.4/32` |

## 4. Spine-Leaf Point-to-Point Links

| Link | Spine Interface/IP | Leaf Interface/IP | Prefix |
|---|---|---|---|
| `spine1-leaf1` | `spine1 eth1 10.0.0.0` | `leaf1 eth1 10.0.0.1` | `10.0.0.0/31` |
| `spine1-leaf2` | `spine1 eth2 10.0.0.2` | `leaf2 eth1 10.0.0.3` | `10.0.0.2/31` |
| `spine1-leaf3` | `spine1 eth3 10.0.0.4` | `leaf3 eth1 10.0.0.5` | `10.0.0.4/31` |
| `spine1-leaf4` | `spine1 eth4 10.0.0.6` | `leaf4 eth1 10.0.0.7` | `10.0.0.6/31` |
| `spine2-leaf1` | `spine2 eth1 10.0.0.8` | `leaf1 eth2 10.0.0.9` | `10.0.0.8/31` |
| `spine2-leaf2` | `spine2 eth2 10.0.0.10` | `leaf2 eth2 10.0.0.11` | `10.0.0.10/31` |
| `spine2-leaf3` | `spine2 eth3 10.0.0.12` | `leaf3 eth2 10.0.0.13` | `10.0.0.12/31` |
| `spine2-leaf4` | `spine2 eth4 10.0.0.14` | `leaf4 eth2 10.0.0.15` | `10.0.0.14/31` |

## 5. Host-Facing Links

| Link | Leaf Interface/IP | Host Interface/IP | Host Default Gateway |
|---|---|---|---|
| `leaf1-host1` | `leaf1 eth3 192.168.1.1/24` | `host1 eth1 192.168.1.11/24` | `192.168.1.1` |
| `leaf2-host2` | `leaf2 eth3 192.168.2.1/24` | `host2 eth1 192.168.2.11/24` | `192.168.2.1` |
| `leaf3-host3` | `leaf3 eth3 192.168.3.1/24` | `host3 eth1 192.168.3.11/24` | `192.168.3.1` |
| `leaf4-host4` | `leaf4 eth3 192.168.4.1/24` | `host4 eth1 192.168.4.11/24` | `192.168.4.1` |

## 6. ASN Allocation

| Node | ASN |
|---|---:|
| `spine1` | `65000` |
| `spine2` | `65000` |
| `leaf1` | `65101` |
| `leaf2` | `65102` |
| `leaf3` | `65103` |
| `leaf4` | `65104` |

## 7. Routes to Advertise

### Loopback Prefixes

| Node | Prefix to Advertise |
|---|---|
| `spine1` | `10.255.0.1/32` |
| `spine2` | `10.255.0.2/32` |
| `leaf1` | `10.255.1.1/32` |
| `leaf2` | `10.255.1.2/32` |
| `leaf3` | `10.255.1.3/32` |
| `leaf4` | `10.255.1.4/32` |


### Host-facing Prefixes

| Node | Prefix to Advertise |
|---|---|
| `leaf1` | `192.168.1.0/24` |
| `leaf2` | `192.168.2.0/24` |
| `leaf3` | `192.168.3.0/24` |
| `leaf4` | `192.168.4.0/24` |

## 8. Notes

- `/31` is used for point-to-point spine-leaf links.
- Loopbacks are `/32` and should remain stable regardless of physical link status.
- Host-facing networks are included for later reachability and overlay testing.
