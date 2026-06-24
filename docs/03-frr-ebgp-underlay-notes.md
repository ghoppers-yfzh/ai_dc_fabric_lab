# FRR eBGP Underlay Notes

## Purpose

This note captures the core learning from the FRR and SONiC eBGP underlay labs.

Related labs:

- `labs/01-frr-leaf-spine/`
- `labs/05-sonic-leaf-spine-ebgp/`

The goal is to describe the underlay design in plain engineering terms, not to repeat every command from the lab runbooks.

---

## 1. What the Underlay Is For

The underlay is the routed foundation of the data center fabric.

Its job is simple:

```text
make every fabric node loopback reachable through routed paths
```

In this project, the underlay uses:

- point-to-point links
- `/31` addressing
- loopbacks
- eBGP between directly connected nodes
- ECMP across multiple spines
- validation through BGP tables, routes, and pings

The underlay should stay boring and predictable. That is a good thing.

---

## 2. Why Leaf-Spine

A leaf-spine topology gives every leaf a consistent path to every other leaf through one or more spines.

For a small lab:

```text
leaf1 -> spine1 -> leaf2
leaf1 -> spine2 -> leaf2
```

For a larger production fabric, the same idea scales horizontally by adding spines and leaves.

The important design point is that there is no long chain of switches. Traffic should cross a predictable number of hops.

---

## 3. Why Use Routed Point-to-Point Links

A routed fabric avoids large Layer 2 failure domains in the underlay.

Using point-to-point routed links gives a few practical benefits:

- clear failure boundaries
- simple routing behavior
- no spanning tree in the fabric core
- easier ECMP
- easier troubleshooting
- no dependency on a shared underlay VLAN

In the labs, `/31` addressing is used because each point-to-point link only needs two usable addresses.

Example:

| Link | Addressing |
|---|---|
| spine1-to-leaf1 | `10.0.11.0/31` and `10.0.11.1/31` |
| spine2-to-leaf1 | `10.0.12.0/31` and `10.0.12.1/31` |

---

## 4. Why Use Loopbacks

Loopbacks are stable node identifiers.

Physical links can fail, but the node loopback should remain reachable through another path if the fabric still has an alternate route.

In the labs, loopbacks are used to prove that the underlay is doing more than only local link connectivity.

A direct interface ping proves one link works.

A loopback-to-loopback ping proves the fabric can route across the topology.

---

## 5. Why Use eBGP

eBGP is common in data center fabrics because it is explicit and easy to reason about.

Useful properties:

- every neighbor relationship is directly defined
- each node can have its own ASN
- route advertisement is controlled
- ECMP behavior is visible
- failure behavior is easy to observe
- it works well in multi-vendor environments

In the lab, spines and leaves use different ASNs.

Example:

| Node | ASN |
|---|---|
| spine1 | `65001` |
| spine2 | `65002` |
| leaf1 | `65101` |
| leaf2 | `65102` |

---

## 6. What Validation Should Prove

A routed underlay is not complete just because BGP sessions are established.

Validation should check several layers:

### Link layer

```bash
ip -br addr show
ping <direct-neighbor-ip>
```

This proves the point-to-point links work.

### BGP sessions

```bash
show ip bgp summary
```

This proves neighbors are established.

### Route learning

```bash
show ip route bgp
show ip bgp
```

This proves routes are being exchanged.

### Loopback reachability

```bash
ping -I <local-loopback> <remote-loopback>
```

This proves end-to-end routed reachability through the fabric.

### Failure behavior

Shut down or remove one path and check that traffic still works through the remaining path.

---

## 7. Lab 01 vs Lab 05

Lab 01 used raw FRR containers.

That made the routing behavior easy to see.

Lab 05 used SONiC VS.

The routing design was similar, but the operational model was different:

| Area | FRR lab | SONiC lab |
|---|---|---|
| Routing software | FRR directly | FRR inside SONiC environment |
| Interface config | Linux / FRR files | ConfigDB JSON |
| BGP daemon | controlled directly by FRR setup | may need runtime handling in SONiC VS |
| Validation | `vtysh` and Linux commands | `vtysh`, SONiC CLI, and Linux commands |
| Learning focus | protocol and topology | protocol plus NOS runtime model |

This is useful because data center engineers often need to separate design logic from platform-specific operations.

---

## 8. Key Takeaways

- The underlay should be simple.
- Loopback reachability is the real success signal.
- eBGP is a good fit for explicit fabric routing.
- Direct link reachability must be validated before BGP.
- BGP session state alone is not enough; route learning and data-plane reachability matter.
- The same underlay concept can be implemented across different NOS platforms, but the operational workflow may differ.
