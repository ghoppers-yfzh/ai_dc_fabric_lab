# Reading Plan for Lab 00 to Lab 06

## Purpose

This is a practical reading plan tied to the labs already completed or planned.

Do not read everything at once. Read only enough to explain the lab behavior and write useful notes.

---

## Reading Rule

For each topic, use this loop:

```text
read -> explain in your own words -> connect to a lab -> save one note or validation finding
```

Avoid passive reading.

---

## Lab 00 — Platform Validation

### Read

- Containerlab overview
- Containerlab topology file basics
- Docker container networking basics

### Learn to explain

- what Containerlab creates
- what the management network is
- how lab links differ from management access
- why `containerlab destroy --cleanup` matters

### Repo output

Already mostly complete.

Optional note:

```text
labs/00-platform-validation/README.md
```

Add a short "What this lab proves" section if it is missing.

---

## Lab 01 — FRR Leaf-Spine

### Read

- Clos / leaf-spine topology basics
- eBGP in data center fabrics
- `/31` point-to-point addressing
- ECMP basics
- FRR BGP basics

### Learn to explain

- why a routed fabric avoids STP in the core
- why loopbacks are advertised
- why ECMP appears when multiple equal paths exist
- why host reachability is a better test than BGP alone

### Repo output

Add or update:

```text
docs/03-frr-ebgp-underlay-notes.md
```

---

## Lab 02 — EVPN/VXLAN

### Read

- VXLAN basics
- EVPN basics
- VTEP
- L2VNI
- L3VNI
- anycast gateway
- EVPN route types, especially type-2 and type-3

### Learn to explain

- what belongs to the underlay
- what belongs to the overlay
- why VTEP loopback reachability must work first
- what EVPN advertises
- what VXLAN encapsulates
- why MAC learning changes when EVPN is used

### Repo output

Existing document:

```text
docs/01-evpn-vxlan-design.md
```

Optional future update:

```text
docs/01-evpn-vxlan-design.md
```

Add a "What Lab 02 actually proved" section if not already present.

---

## Lab 03 — SONiC Basics

### Read

- SONiC architecture
- SONiC ConfigDB
- Containerlab `sonic-vs`
- SONiC interface mapping

### Learn to explain

- how SONiC differs from a raw FRR container
- what ConfigDB is
- why `eth0` is management
- why `eth1` maps to `Ethernet0`
- why a virtual SONiC lab is useful but limited

### Repo output

Existing document:

```text
docs/02-sonic-containerlab-basics.md
```


---

## Lab 04 — SONiC eBGP

### Read

- FRR daemon model
- `vtysh`
- `bgpd`
- SONiC BGP / FRR integration at a high level
- Containerlab SONiC VS interface mapping

### Learn to explain

- why `vtysh` can run while `bgpd` is not running
- why `bgpd=yes` is not runtime proof
- why ARP failed when the Linux-side veth was down
- why direct ping must pass before BGP troubleshooting

### Repo output

Add:

```text
docs/04-sonic-runtime-and-bgp-notes.md
```

---

## Lab 05 — SONiC Leaf-Spine eBGP

### Read

- eBGP underlay design again, but from a SONiC perspective
- validation workflow design
- BGP route propagation across a leaf-spine topology

### Learn to explain

- what changed from Lab 04 to Lab 05
- why each node had two BGP sessions
- why leaf loopback reachability was the success test
- what was platform-specific vs design-specific

### Repo output

Update:

```text
docs/03-frr-ebgp-underlay-notes.md
docs/04-sonic-runtime-and-bgp-notes.md
```

---

## Lab 06 — SONiC Automation

Lab 06 is deferred.

Before starting it, make sure the manual SONiC workflow is documented.

### Read

- basic Bash scripting for validation
- Ansible inventory and templates
- JSON/YAML data modeling
- NetBox source-of-truth concepts

### Learn to explain

- what should be automated
- what should stay visible in configs
- why automation should not hide unknown runtime behavior
- how validation output becomes useful evidence

### Repo output later

```text
labs/06-sonic-automation/
scripts/
outputs/
validation.md
```

---

## AI Fabric Reading Track

This track should run in parallel, slowly.

### Read next

- AI training communication patterns
- RDMA basics
- RoCEv2 basics
- PFC, ECN, DCQCN
- InfiniBand vs Ethernet
- NVIDIA Spectrum-X concepts
- telemetry and congestion monitoring

### Learn to explain

- why AI workloads create heavy east-west traffic
- why packet loss matters more for RDMA
- why congestion control becomes a fabric design topic
- what the local labs can and cannot prove

### Repo output

Current notes:

```text
docs/05-ai-fabric-requirements-notes.md
docs/08-rocev2-lossless-ethernet-notes.md
```

Later add:

```text
docs/09-infiniband-vs-ethernet-notes.md
docs/10-telemetry-and-validation-notes.md
```

---

## Minimum AI Fabric Reading Output

Before moving too far into later AI fabric topics, be able to explain these without notes:

```text
1. Why RoCEv2/RDMA is more sensitive to packet loss than normal TCP traffic.
2. Why PFC should be treated as a last-resort safety brake, not the main control loop.
3. Why ECN should mark congestion before PFC is needed.
4. What DCQCN does after ECN/CNP feedback is received.
5. Why buffer headroom matters for PFC.
6. What telemetry is needed beyond interface up/down and BGP state.
7. What the virtual labs can and cannot prove about RoCEv2/lossless Ethernet.
```

Related note:

```text
docs/08-rocev2-lossless-ethernet-notes.md
```

---

## Minimum Reading Before Starting Lab 06

Before starting Lab 06, be able to explain these without notes:

```text
1. What does ConfigDB load actually do?
2. Why do we still check Linux interfaces in SONiC VS?
3. Why did direct ping fail in Lab 04?
4. Why did BGP not accept config until bgpd was running?
5. What is the correct validation order for a SONiC eBGP lab?
6. What should automation do in this project?
7. What should automation not hide?
```
