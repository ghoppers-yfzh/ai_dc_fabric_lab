# EVPN Multi-Tenancy Key Notes

## Multi-Tenancy

* A shared physical fabric can support multiple tenants.
* **VRF provides Layer-3 tenant isolation** by maintaining separate routing tables.
* The underlay normally remains in the default VRF.
* Different tenants should not communicate unless route leaking or another explicit policy path is configured.

---

## L2VNI vs L3VNI

### L2VNI

* Maps a VLAN / Layer-2 segment into VXLAN.
* Represents a Layer-2 broadcast domain.

```text
VLAN 10
  ↓
L2VNI 10010
```

### L3VNI

* Represents a tenant VRF in symmetric inter-subnet routing.
* Provides the tenant routing context between VTEPs.
* One tenant VRF uses one L3VNI.
* L2VNI and L3VNI IDs must be different.

```text
VRF RED
  ↓
L3VNI 4001
```

### Easy Memory

```text
L2VNI = VLAN / Layer-2 segment
L3VNI = VRF / Layer-3 tenant context
```

---

## RD vs RT

### RD — Route Distinguisher

* Makes otherwise identical EVPN/VPN routes unique.
* Allows different tenants to use overlapping IP prefixes.

```text
RD = route uniqueness
```

### RT — Route Target

* Controls route membership and import/export policy.
* Determines which VRFs import or export specific EVPN routes.

```text
RT = route membership / policy
```

### Easy Memory

```text
RD = uniqueness
RT = import/export
```

---

## Symmetric Routing

In symmetric EVPN routing, **both ingress and egress VTEPs perform routing**.

```text
Host A
  ↓
Ingress VTEP
  ↓
Route in tenant VRF
  ↓
Encapsulate with L3VNI
  ↓
Underlay
  ↓
Egress VTEP
  ↓
Decapsulate
  ↓
Route again in tenant VRF
  ↓
Destination subnet
```

### Why the L3VNI Matters

The L3VNI tells the remote VTEP which tenant VRF should process the routed packet.

```text
L3VNI 4001 → VRF RED
L3VNI 4002 → VRF BLUE
```

This is important because different tenants may use overlapping IP address space.

### Routing Responsibility

```text
Ingress VTEP:
Determines which remote VTEP should receive the traffic.

Egress VTEP:
Determines which local subnet/interface should forward the traffic.
```

---

## EVPN Route Types

* **Type-2**: MAC / MAC+IP host information.
* **Type-5**: IP prefix information.

---

## Key Troubleshooting Logic

### Routes from RED appear in BLUE

Check:

* RT import/export
* VRF association
* L3VNI mapping
* Route leaking

### Same-tenant L2 works, but inter-subnet routing fails

Check:

* VRF
* L3VNI
* Anycast gateway / SVI
* EVPN Type-2 / Type-5 behavior

### VNI exists, but remote routes are not imported

Check:

* BGP EVPN adjacency
* RT
* RD / VNI context
* Route advertisement

---

## Exam Memory Table

| Concept           | Purpose                             |
| ----------------- | ----------------------------------- |
| VRF               | Layer-3 tenant isolation            |
| L2VNI             | Layer-2 VXLAN segment               |
| L3VNI             | Tenant VRF / routed overlay context |
| RD                | Makes routes unique                 |
| RT                | Controls route import/export        |
| Symmetric Routing | Both ingress and egress VTEPs route |
| EVPN Type-2       | MAC / MAC+IP route                  |
| EVPN Type-5       | IP prefix route                     |
