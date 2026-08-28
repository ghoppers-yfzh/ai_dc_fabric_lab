# S10 Lab — EVPN Multi-Tenancy

## Goal

Build a small EVPN/VXLAN fabric with two tenants and verify:

* VRF-based tenant isolation
* L2VNI and L3VNI usage
* EVPN Type-5 route exchange
* Symmetric inter-subnet routing
* RED and BLUE tenant separation

---

## Topology

```text id="ay99or"
                         spine01
                       /         \
                    leaf01      leaf02
                   /     \      /     \
                red01   blue01 red02   blue02
```

### Underlay

| Device  | Loopback        |   ASN |
| ------- | --------------- | ----: |
| spine01 | 10.255.0.254/32 | 65000 |
| leaf01  | 10.255.0.1/32   | 65101 |
| leaf02  | 10.255.0.2/32   | 65102 |

The underlay uses eBGP so that both leaf VTEP loopbacks are reachable.

---

## Tenant Design

| Leaf   | Tenant | VLAN | L2VNI | Subnet        | L3VNI |
| ------ | ------ | ---: | ----: | ------------- | ----: |
| leaf01 | RED    |   10 | 10010 | 10.10.10.0/24 |  4001 |
| leaf02 | RED    |   11 | 10011 | 10.10.11.0/24 |  4001 |
| leaf01 | BLUE   |   20 | 10020 | 10.20.20.0/24 |  4002 |
| leaf02 | BLUE   |   21 | 10021 | 10.20.21.0/24 |  4002 |

---

## Phase 1 — eBGP Underlay

### Purpose

Provide IP connectivity between VTEP loopback addresses.

```text id="owcfvh"
leaf01 VTEP 10.255.0.1
        ↓
      spine01
        ↓
leaf02 VTEP 10.255.0.2
```

### Validation

```bash id="9rg6ss"
show bgp ipv4 unicast summary
ping -I 10.255.0.1 10.255.0.2
```

Expected result:

```text id="8pnw5m"
BGP neighbors = Established
VTEP-to-VTEP ping = PASS
```

---

## Phase 2 — EVPN Control Plane

### Purpose

Enable the `l2vpn evpn` address family so the leaf switches can exchange EVPN routes through the spine.

The spine participates in EVPN route exchange but does not act as a VTEP.

### Validation

```bash id="g9gu6o"
show bgp l2vpn evpn summary
```

Expected result:

```text id="1iwcz0"
EVPN neighbors = Established
```

---

## Phase 3 — Tenant VRFs and VNIs

### Purpose

Create separate routing domains for RED and BLUE.

```text id="hzuro6"
VRF RED  → L3VNI 4001
VRF BLUE → L3VNI 4002
```

L2VNIs represent local Layer-2 segments:

```text id="38zzb9"
VLAN 10 → L2VNI 10010
VLAN 11 → L2VNI 10011
VLAN 20 → L2VNI 10020
VLAN 21 → L2VNI 10021
```

### Validation

```bash id="gn20ev"
nv show bridge domain br_default vlan-vni-map
ip route show vrf RED
ip route show vrf BLUE
show bgp l2vpn evpn vni
```

Expected result:

* RED and BLUE have separate routing tables.
* L2VNIs map to the correct VLANs.
* L3VNI 4001 belongs to RED.
* L3VNI 4002 belongs to BLUE.

---

## Phase 4 — EVPN Type-5 Routes

### Purpose

Advertise tenant IP prefixes through EVPN for inter-subnet routing.

```text id="pyf5hh"
10.10.11.0/24
     ↓
EVPN Type-5
     ↓
VRF RED on leaf01
```

Route Targets control which VRF imports each route.

### Validation

```bash id="njm09f"
show bgp l2vpn evpn route type prefix
ip route show vrf RED
ip route show vrf BLUE
```

Expected result:

```text id="n70yen"
VRF RED:
10.10.10.0/24 = local
10.10.11.0/24 = remote EVPN route

VRF BLUE:
10.20.20.0/24 = local
10.20.21.0/24 = remote EVPN route
```

RED must not import BLUE prefixes, and BLUE must not import RED prefixes.

---

## Phase 5 — Host Connectivity

### Host Addresses

| Host   | Address        | Gateway    |
| ------ | -------------- | ---------- |
| red01  | 10.10.10.10/24 | 10.10.10.1 |
| red02  | 10.10.11.10/24 | 10.10.11.1 |
| blue01 | 10.20.20.10/24 | 10.20.20.1 |
| blue02 | 10.20.21.10/24 | 10.20.21.1 |

### Purpose

Verify symmetric routing and tenant isolation.

### Expected Results

```text id="e05hzy"
red01  → red02   = PASS
blue01 → blue02  = PASS

red01  → blue02  = FAIL
blue01 → red02   = FAIL
```

---

## Symmetric Routing Path

Example: `red01 → red02`

```text id="ief5i2"
red01
  ↓
leaf01
  ↓
Route in VRF RED
  ↓
Encapsulate with L3VNI 4001
  ↓
VXLAN underlay
  ↓
leaf02
  ↓
L3VNI 4001 → VRF RED
  ↓
Route again
  ↓
red02
```

Both ingress and egress VTEPs perform routing.

---

## Key Takeaways

```text id="ua61wz"
VRF    = Layer-3 tenant isolation
L2VNI  = Layer-2 VXLAN segment
L3VNI  = Tenant routed overlay context
RD     = Route uniqueness
RT     = Route import/export policy
Type-5 = IP prefix route
```

The lab demonstrates that multiple tenants can share the same physical EVPN/VXLAN fabric while maintaining independent Layer-3 routing domains.
