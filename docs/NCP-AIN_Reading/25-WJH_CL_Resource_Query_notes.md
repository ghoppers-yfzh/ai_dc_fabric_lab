# WJH
WJH = What Just Happened

When packet get into Spectrum ASIC, the process:
```
Packet enters ASIC
        ↓
Ingress processing
        ↓
L2 / L3 / Tunnel lookup
        ↓
ACL
        ↓
Buffer / Queue
        ↓
Egress processing
        ↓
Transmit
```

ASIC dropped the packet and WJH tells:
```
Drop group: L3
Drop reason: unresolved-neighbor
Source port: swp1
Destination IP: 10.20.30.40
Timestamp: ...
Recommended action: ...
```

Types of WJH
|WJH Group|Cause|Possible Issues|
|---|---|---|
|L1|Physical|link/cable/CRC|
|L2|Switching|MAC/VLAN|
|L3|Routing|route/neighbor/TTL/MTU|
|Tunnel|Overlay|VXLAN encap/decap|
|Buffer|Congestion|queue/buffer|
|ACL|Policy|ACL deny|

## L2 WJH
- ingress-vlan-filtering
- vlan-or-vni-lookup-failed
- vlan-tagging-mismatch

Example: `Packet enters a switch but the VLAN/VNI lookup fails.`

## L3 WJH
- ipv4-routing-table-unicast-miss
- ipv6-routing-table-unicast-miss
- unresolved-neighbor
- packet-size-is-larger-than-router-intf-mtu
- ttl-value-is-too-small
- blackhole-route
- blackhole-arp

Comparing with Nexus
```
Nexus thinking                   WJH

show ip route          →      routing-table-miss
show ip arp            →      unresolved-neighbor
MTU mismatch           →      packet-size > router MTU
TTL expired            →      ttl-value-is-too-small
Null/blackhole route   →      blackhole-route
```

### Example for unresolved-neighbor
```
Drop group: L3
Drop reason: unresolved-neighbor
Source port: swp1
Destination IP: 10.20.30.40
```
Process:
```
Packet arrives
      ↓
Destination = 10.20.30.40
      ↓
L3 routing lookup
      ↓
Route exists
      ↓
Next-hop = 192.168.1.20
      ↓
Need destination MAC for next-hop
      ↓
Neighbor/ARP unresolved
      ↓
ASIC cannot build Ethernet frame
      ↓
DROP
      ↓
WJH: unresolved-neighbor
```

### Example for packet-buffer and aggregate-buffer

Check packet drop `nv show system wjh packet-buffer`, output includes:
- Drop group
- Drop reason
- Severity
- sPort
- dPort
- Src IP
- Dst IP
- Timestamp
- Recommended action

Packet drop summary, `nv show system wjh aggregate-buffer`, output:
```
unresolved-neighbor
count = 347

MTU exceeded
count = 82
```

packet-buffer > individual events

aggregate-buffer > summarized events + count


### PCAP export
`nv action export system wjh packet-buffer`

Cumulus 5.18 writes PCAP file to `/var/run/nv-wjh/`

### WJH channel
Defines the events to be monitored
```
nv set system wjh channel forwarding trigger l2
nv set system wjh channel forwarding trigger l3
nv set system wjh channel forwarding trigger tunnel

nv set system wjh channel layer-1 trigger l1

nv set system wjh channel buffer trigger buffer

nv set system wjh channel acl1 trigger acl

nv config apply
```
Above is about:
```
WJH
├── forwarding
│   ├── L2
│   ├── L3
│   └── Tunnel
│
├── layer-1
│   └── L1
│
├── buffer
│   └── Buffer
│
└── acl1
    └── ACL
```
# cl-resource-query
forwarding architecture:
```
        FRR
         │
         ▼
Linux routing table
         │
         ▼
      switchd
         │
         ▼
 Spectrum ASIC
 ┌───────────────┐
 │ Route table   │
 │ Host table    │
 │ Neighbor      │
 │ MAC table     │
 │ ECMP          │
 │ ACL / TCAM    │
 └───────────────┘
```

Hardware limit
```
Control plane:

BGP route = YES
Linux route = YES


Data plane:

ASIC programming = NO / partial
```

Route exists in RIB/FIB ≠ Route successfully programmed into ASIC

BGP healthy doesn't always mean hardware forwarding healthy.

## ASIC resource exhaustion vs congestion
### Congestion
For 400G port, traffic = 450G

Q: Packet / queue / buffer pressure

Considerations:
- Buffer
- ECN
- PFC
- DCQCN
- Telemetry
- WJH buffer

### Resource exhaustion
For Route table capacity = 100k, Installed = 99.9k
Q: Forwarding entries overloaded

A: Bandwidth congestion ≠ ASIC resource exhaustion

## cl-resource-query commands
`sudo cl-resource-query`

It checks:
- IPv4 host entries
- IPv6 host entries
- IPv4 routes
- IPv6 routes
- neighbors
- ECMP entries
- MAC entries

Example for Spectrum-2
```
IPv4 host entries       used / max
IPv6 host entries       used / max
IPv4 route entries      used / max
IPv6 route entries      used / max
ECMP entries            used / max
MAC entries             used / max
```

Some other commands:
- `nv show platform asic resource`
- `nv show platform asic resource acl` # For ACL


Between WJH and cl-resource-query
```
Packet problem
     ↓
WJH

Capacity problem
     ↓
cl-resource-query
```

# For memory
## Q1. What is the fundamental difference between WJH and `cl-resource-query`?

- **WJH** answers: **Why was this packet dropped?**
- **`cl-resource-query`** answers: **How full are the ASIC hardware resources?**

Memory:

```text
Packet drop reason
    → WJH

ASIC capacity/resource usage
    → cl-resource-query
```

---

## Q2. What are the six WJH categories?

```text
L1
L2
L3
Tunnel
Buffer
ACL
```

Quick mapping:

| Category | Typical Problem |
|---|---|
| L1 | Physical/link issue |
| L2 | MAC/VLAN forwarding issue |
| L3 | Route/neighbor/TTL/MTU issue |
| Tunnel | VXLAN encapsulation/decapsulation issue |
| Buffer | Congestion/buffer-related drop |
| ACL | Policy-driven drop |

---

## Q3. A packet hits an ACL deny. Which WJH category is relevant?

**ACL**

```text
ACL deny
   ↓
WJH category: ACL
```

---

## Q4. Why can a healthy BGP RIB coexist with a hardware resource problem?

Because the **control plane and hardware forwarding plane are separate layers**.

A route can exist in:

```text
BGP / FRR
    ↓
Linux routing table
```

but the ASIC might not have enough hardware resources to program it.

```text
Route exists in control plane
        ≠
Route successfully programmed into ASIC
```

Check ASIC resources with:

```bash
sudo cl-resource-query
```

or:

```bash
nv show platform asic resource
```

---

## Q5. What command exports WJH packet data into a PCAP?

```bash
nv action export system wjh packet-buffer
```

Useful workflow:

```text
WJH detects drop
      ↓
Export PCAP
      ↓
Analyze packet in Wireshark
```

---

## Q6. When would NetQ be more useful than WJH?

Use **NetQ** when you need:

- fabric-wide visibility
- path analysis
- multiple-device correlation
- problems occurring across the fabric

Use **WJH** when you need:

- local packet-drop reason
- exact drop category/context

Memory:

```text
"Why did THIS packet drop?"
        → WJH

"Where in the fabric/path is the problem?"
        → NetQ
```

---

## Final Memory Table

| Question | Tool |
|---|---|
| Why was this packet dropped? | **WJH** |
| How full are ASIC resources? | **`cl-resource-query`** |
| What is general interface drop/error status? | **Interface counters** |
| What is happening across the fabric/path? | **NetQ** |
| What routes does the control plane know? | **FRR / BGP** |

### One-Line Memory

```text
Packet WHY   → WJH
ASIC FULL?   → cl-resource-query
Port STATUS  → Interface counters
Fabric WHERE → NetQ
Route EXISTS → BGP / FRR
```



# Lab
# S01 Lab — WJH and ASIC Resource Query on NVIDIA Air

## Lab Goal

Validate the troubleshooting workflow for:

* L3 forwarding
* unresolved neighbor conditions
* WJH visibility
* ASIC resource monitoring

Environment:

```text
NVIDIA Air / Cumulus Linux VX
```

---

## 1. Topology and IP Configuration

The Cumulus switch was configured with:

```text
swp1: 10.0.1.1/24
swp2: 10.0.2.1/24
```

Verification:

```bash
ip addr show swp1
ip addr show swp2
ip route
```

Routing table:

```text
10.0.1.0/24 dev swp1
10.0.2.0/24 dev swp2
```

Both interfaces were operational:

```text
swp1: UP, LOWER_UP
swp2: UP, LOWER_UP
```

---

## 2. Basic Connectivity Validation

The local routed interface addresses were reachable:

```bash
ping 10.0.1.1
ping 10.0.2.1
```

Both tests succeeded.

This confirmed that:

```text
Interface state      = healthy
IP configuration     = correct
Connected routes     = installed
```

---

## 3. Generate an Unresolved Neighbor Condition

A test destination was selected:

```text
10.0.2.99
```

The switch had a valid route for this destination:

```bash
ip route get 10.0.2.99
```

Output:

```text
10.0.2.99 dev swp2 src 10.0.2.1
```

Therefore:

```text
L3 route lookup
    ↓
SUCCESS
```

However, the destination did not exist, so ARP/neighbor resolution failed.

Verification:

```bash
ip neigh show
```

Output:

```text
10.0.2.99 dev swp2 FAILED
```

The important troubleshooting chain is:

```text
Route exists
    ↓
Outgoing interface = swp2
    ↓
Neighbor resolution attempted
    ↓
No ARP reply
    ↓
Neighbor state = FAILED
    ↓
Packet cannot be forwarded
```

On physical Spectrum hardware with WJH support, this type of failure would conceptually map to:

```text
WJH Group: L3
Drop Reason: unresolved-neighbor
```

---

## 4. WJH Test

Commands:

```bash
nv show system wjh channel
nv show system wjh packet-buffer
```

Result:

```text
No Data
```

In this NVIDIA Air/VX environment, no WJH packet-drop information was available.

This lab therefore demonstrates the forwarding failure and troubleshooting workflow, but does not provide real Spectrum ASIC WJH events.

---

## 5. ASIC Resource Query Test

Command:

```bash
sudo cl-resource-query
```

Result:

```text
cl-resource-query command is not supported in VX
```

This confirms that the virtual VX platform does not expose the physical ASIC resource information required by `cl-resource-query`.

The NVUE alternative was also tested:

```bash
nv show platform asic resource
```

Result:

```text
Error: 'asic' is not one of [...]
```

Therefore, ASIC resource utilization cannot be validated in this virtual environment.

---

## 6. Lab Findings

| Test                          | Result              |
| ----------------------------- | ------------------- |
| `swp1` / `swp2` L3 interfaces | PASS                |
| Connected routes installed    | PASS                |
| Route lookup to `10.0.2.99`   | PASS                |
| Neighbor resolution           | FAIL as intended    |
| Neighbor state                | `FAILED`            |
| WJH event visibility          | Not available       |
| `cl-resource-query`           | Not supported in VX |
| NVUE ASIC resource view       | Not available       |

---

## 7. Key Learning

The most important troubleshooting observation was:

```text
Route exists
    ≠
Packet can be forwarded
```

A packet can successfully pass the L3 route lookup but still fail because the next-hop or destination neighbor cannot be resolved.

Troubleshooting workflow:

```text
Ping / traffic failure
        ↓
Check route
        ↓
Route exists
        ↓
Check neighbor
        ↓
Neighbor = FAILED
        ↓
Root cause:
L2 adjacency / ARP resolution failure
```

On physical Spectrum hardware:

```text
Same failure
   ↓
WJH
   ↓
L3 / unresolved-neighbor
```

---

## 8. Platform Limitation Learned

NVIDIA Air/VX is useful for:

```text
Routing
NVUE configuration
BGP
EVPN/VXLAN
Failure simulation
Linux networking troubleshooting
```

But this lab showed that VX cannot fully reproduce:

```text
Real WJH ASIC events
cl-resource-query
ASIC hardware table utilization
```

Therefore:

```text
Virtual lab
    → validates configuration and troubleshooting logic

Physical Spectrum hardware
    → validates ASIC-specific telemetry and resources
```

---

## Exam Memory

```text
Route exists but neighbor fails
    → L3 forwarding problem
    → check `ip neigh`
    → expected WJH reason: unresolved-neighbor

Why did a packet drop?
    → WJH

How full are ASIC resources?
    → cl-resource-query

VX/Air
    → useful for logic/config testing
    → not a replacement for physical ASIC validation
```
