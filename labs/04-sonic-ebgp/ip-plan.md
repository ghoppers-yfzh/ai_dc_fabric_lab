# Lab 04 IP and ASN Plan — SONiC eBGP

## Topology

```text
sonic1 Ethernet0 10.0.12.1/30  <---->  10.0.12.2/30 Ethernet0 sonic2
sonic1 Loopback0 10.255.0.1/32         sonic2 Loopback0 10.255.0.2/32
```

## Interface Mapping

In this containerlab topology:

| Containerlab Endpoint | SONiC Interface |
|---|---|
| sonic1:eth1 | Ethernet0 |
| sonic2:eth1 | Ethernet0 |

## Addressing

| Node | Interface | IP Address | Purpose |
|---|---|---|---|
| sonic1 | Ethernet0 | 10.0.12.1/30 | eBGP point-to-point link |
| sonic2 | Ethernet0 | 10.0.12.2/30 | eBGP point-to-point link |
| sonic1 | Loopback0 | 10.255.0.1/32 | Router ID and advertised test prefix |
| sonic2 | Loopback0 | 10.255.0.2/32 | Router ID and advertised test prefix |

## BGP ASN Plan

| Node | ASN | Router ID | Neighbor |
|---|---:|---|---|
| sonic1 | 65101 | 10.255.0.1 | 10.0.12.2 remote-as 65102 |
| sonic2 | 65102 | 10.255.0.2 | 10.0.12.1 remote-as 65101 |

## Expected Routing Result

| Node | Expected BGP Route |
|---|---|
| sonic1 | 10.255.0.2/32 via 10.0.12.2 |
| sonic2 | 10.255.0.1/32 via 10.0.12.1 |
