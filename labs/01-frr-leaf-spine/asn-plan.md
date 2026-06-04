# ASN Plan — FRR Leaf-Spine Lab

## 1. ASN Design

This lab uses eBGP for the fabric underlay.

The initial design uses:

- one shared spine ASN
- one unique ASN per leaf

This keeps the first fabric easy to understand and helps make ECMP behavior simpler in the initial lab.

## 2. ASN Allocation

| Node | ASN |
|---|---:|
| `spine1` | `65000` |
| `spine2` | `65000` |
| `leaf1` | `65101` |
| `leaf2` | `65102` |
| `leaf3` | `65103` |
| `leaf4` | `65104` |

## 3. Expected BGP Sessions

| Spine | Leaf | Spine ASN | Leaf ASN |
|---|---|---:|---:|
| `spine1` | `leaf1` | `65000` | `65101` |
| `spine1` | `leaf2` | `65000` | `65102` |
| `spine1` | `leaf3` | `65000` | `65103` |
| `spine1` | `leaf4` | `65000` | `65104` |
| `spine2` | `leaf1` | `65000` | `65101` |
| `spine2` | `leaf2` | `65000` | `65102` |
| `spine2` | `leaf3` | `65000` | `65103` |
| `spine2` | `leaf4` | `65000` | `65104` |

Expected total:

```text
8 spine-leaf eBGP sessions
```

## 4. Why eBGP?

eBGP is commonly used in modern data center fabrics because it provides:

- simple failure domain boundaries
- clear neighbor relationships
- policy control
- no dependency on an IGP for the underlay
- easy scale-out behavior
- operationally familiar troubleshooting commands

## 5. Why Shared Spine ASN?

This lab uses the same ASN on both spines:

```text
spine ASN = 65000
```

This makes the first ECMP validation easier because routes learned through either spine have similar AS path behavior.

A later version of the lab may test per-device spine ASNs, such as:

```text
spine1 = 65001
spine2 = 65002
```

That design can require additional BGP multipath considerations.

## 6. Initial Route Advertisement Plan

Start by advertising loopbacks only.

| Node | Prefix |
|---|---|
| `spine1` | `10.255.0.1/32` |
| `spine2` | `10.255.0.2/32` |
| `leaf1` | `10.255.1.1/32` |
| `leaf2` | `10.255.1.2/32` |
| `leaf3` | `10.255.1.3/32` |
| `leaf4` | `10.255.1.4/32` |

After loopback reachability works, host-facing networks may be added.

## 7. Success Criteria

The ASN plan is working when:

- every spine-leaf BGP session is established
- each leaf can learn other leaf loopbacks through both spines
- ECMP is visible for remote loopback routes
- routes are withdrawn when a link or node fails
