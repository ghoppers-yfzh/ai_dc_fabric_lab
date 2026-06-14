# SONiC Containerlab Basics

## Purpose

This document introduces SONiC as the next learning step after the FRR-based leaf-spine and EVPN/VXLAN labs.

It is a concept note, not a validation runbook.

Use it to understand:

- what SONiC is
- why SONiC matters in cloud and AI data center networking
- how SONiC differs from a simple FRR container
- what ConfigDB is
- how `sonic-vs` works in Containerlab
- what Lab 03 can and cannot prove

The hands-on steps belong in:

```text
labs/03-sonic-containerlab/validation.md
```

The lab overview belongs in:

```text
labs/03-sonic-containerlab/README.md
```

---

## 1. What SONiC Is

SONiC stands for **Software for Open Networking in the Cloud**.

It is an open network operating system originally built for cloud-scale data center environments. Instead of behaving like a traditional monolithic switch OS, SONiC is built around Linux, containerized services, a Redis-based database architecture, and a modular control-plane model.

For this project, the important point is not that SONiC is another CLI to learn.

The important point is that SONiC represents a cloud-style network operating model:

```text
Linux base system
  + containerized network services
  + structured configuration database
  + programmatic operational model
  + routing through FRR
  + vendor/platform abstraction through SAI
```

This makes SONiC relevant to cloud networking, hyperscaler networking, data center automation, and AI infrastructure networking discussions.

---

## 2. Why SONiC Matters for AI Data Center Networking

AI data center and GPU cloud environments usually care about:

- repeatable fabric deployment
- high port density
- automation-friendly configuration
- telemetry and operational visibility
- fast failure detection and repair
- open or disaggregated network operating models
- vendor flexibility
- large-scale BGP-based fabrics

SONiC is often discussed in this space because it fits the open networking and cloud-scale operations model.

This does not mean every AI data center uses SONiC. Many production AI fabrics use vendor NOS platforms such as Cisco NX-OS, Arista EOS, NVIDIA Cumulus Linux, or vendor-managed Ethernet/InfiniBand stacks.

However, understanding SONiC helps build credibility in conversations about:

- cloud data center networking
- open network operating systems
- disaggregated switching
- automation-first operations
- BGP-based data center fabrics
- multi-vendor infrastructure thinking

---

## 3. SONiC vs the Earlier FRR Labs

Lab 01 and Lab 02 used FRR containers directly.

That was useful because it exposed the routing and EVPN/VXLAN control plane clearly.

SONiC is different.

| Area | FRR Labs | SONiC Lab |
|---|---|---|
| System type | Routing software in containers | Full network operating system model |
| Base OS | Linux container | Linux-based NOS image |
| Routing stack | FRR directly | FRR inside SONiC service model |
| Configuration style | FRR config files and Linux commands | SONiC CLI / ConfigDB / config files |
| Operational model | Simple and transparent | More production NOS-like |
| Learning value | Protocol behavior | NOS architecture and operations |

A useful mental model:

```text
FRR lab = learn the routing protocol and EVPN/VXLAN behavior directly
SONiC lab = learn how a cloud-style NOS exposes and manages those functions
```

SONiC still uses FRR for routing, but FRR is only one part of the broader SONiC architecture.

---

## 4. High-level SONiC Architecture

At a high level, SONiC includes:

| Component | Role |
|---|---|
| Linux | Base operating system |
| Docker containers | Run SONiC services independently |
| Redis databases | Shared state and configuration infrastructure |
| ConfigDB | Stores intended configuration |
| AppDB / StateDB / ASICDB | Used by SONiC services to exchange application, state, and forwarding information |
| FRR / BGP container | Provides routing protocols such as BGP |
| SWSS | Switch state service layer between control plane and forwarding plane |
| SAI | Switch Abstraction Interface for ASIC/platform abstraction |
| SONiC CLI | Operational and configuration commands |

This architecture is very different from traditional switch operating systems where most services are hidden behind one vendor CLI.

The important learning point:

```text
SONiC separates configuration, state, routing, and forwarding workflows more explicitly than a traditional network OS.
```

For a network automation engineer, this matters because SONiC is designed around structured data and service interaction, not only manual CLI configuration.

---

## 5. ConfigDB Basics

ConfigDB is one of the most important SONiC concepts.

ConfigDB is SONiC's intended configuration database. It is implemented using local Redis. On boot, SONiC loads configuration from:

```text
/etc/sonic/config_db.json
```

into ConfigDB.

A simplified model:

```text
/etc/sonic/config_db.json
        |
        | loaded at boot or by config load
        v
Redis ConfigDB
        |
        | consumed by SONiC services
        v
running system state
```

Important operational point:

```text
Changing the running ConfigDB does not automatically rewrite /etc/sonic/config_db.json.
```

To persist configuration changes, SONiC commonly requires:

```bash
config save
```

To reload configuration from the JSON file:

```bash
config load
```

This is different from many traditional network devices where entering a CLI command directly changes the running configuration and then `write memory` or `copy run start` saves it.

A useful comparison:

| Traditional NOS | SONiC |
|---|---|
| CLI commands modify running config | CLI often updates structured ConfigDB |
| Startup config is vendor-specific text | Startup config is `config_db.json` |
| Show commands hide internal architecture | Redis databases expose more system structure |
| Automation often screen-scrapes CLI | Automation can target structured config/state |

---

## 6. What `sonic-vs` Is

`sonic-vs` is the SONiC virtual switch container kind supported by Containerlab.

It allows basic SONiC labs to run as containers instead of full virtual machines.

This is useful because it is lighter than running full switch VMs and is suitable for early learning tasks such as:

- booting SONiC
- checking SONiC CLI behavior
- understanding interface mapping
- testing basic Layer 3 connectivity
- exploring ConfigDB basics
- preparing for future BGP labs

In Containerlab, `sonic-vs` uses Linux-style interface names in the topology file, but SONiC exposes front-panel style interface names inside the NOS.

For the first data interface:

```text
Containerlab endpoint: sonic1:eth1
SONiC front-panel port: Ethernet0
```

The management interface is separate:

```text
eth0 = management interface connected to the Containerlab management network
```

A useful rule:

```text
Do not treat eth0 as a data-plane port.
Data-plane links start at eth1.
```

---

## 7. Interface Mapping in This Lab

Lab 03 starts with one SONiC switch and one Linux host:

```text
host1 ------------- sonic1
192.0.2.11/24      Ethernet0: 192.0.2.1/24
```

Containerlab topology endpoint:

```text
sonic1:eth1 <----> host1:eth1
```

Inside SONiC, the first data interface appears as:

```text
Ethernet0
```

Expected mapping:

| Container interface | SONiC role |
|---|---|
| `eth0` | management interface |
| `eth1` | first data/front-panel interface |
| `Ethernet0` | SONiC name for the first data/front-panel interface |

This is why the lab configures:

```text
Ethernet0 = 192.0.2.1/24
host1 eth1 = 192.0.2.11/24
```

---

## 8. What Lab 03 Can Prove

This first SONiC lab can prove:

- the SONiC image can boot under Containerlab
- Containerlab can create links to a `sonic-vs` node
- management and data interfaces are separate
- `eth1` maps to SONiC `Ethernet0`
- SONiC interface configuration commands work
- a Linux host can reach a SONiC data interface
- basic SONiC operational commands can be captured
- the repo has a clean baseline for future SONiC BGP labs

This is intentionally small.

The purpose is to build platform familiarity before adding routing complexity.

---

## 9. What Lab 03 Cannot Prove Yet

This first lab does not prove:

- production SONiC deployment readiness
- hardware ASIC forwarding behavior
- high-scale BGP behavior
- EVPN/VXLAN on SONiC
- RoCEv2 or lossless Ethernet behavior
- PFC / ECN / DCQCN configuration
- telemetry readiness
- multi-vendor interoperability
- AI fabric performance

This is expected.

A virtual `sonic-vs` lab is useful for control-plane and operational learning, but it is not a substitute for real switch hardware or a vendor-supported production SONiC platform.

---

## 10. Recommended Learning Flow

Use this order:

```text
1. Read this document
2. Read labs/03-sonic-containerlab/README.md
3. Run labs/03-sonic-containerlab/validation.md
4. Save outputs under labs/03-sonic-containerlab/outputs/
5. Record short observations in labs/03-sonic-containerlab/notes.md
```

Do not skip the notes file.

The notes file is where practical learning becomes portfolio evidence.

Good notes include:

- what worked
- what failed
- what was different from FRR labs
- what commands were useful
- what was confusing
- what should be tested next

---

## 11. Operational Commands to Recognize

The validation runbook will use commands such as:

```bash
show system status
show interfaces status
show ip interfaces
show ip route
show bgp summary
```

Linux-level commands are also still useful:

```bash
ip link
ip addr
ip route
docker ps
containerlab inspect
```

This is another key SONiC learning point:

```text
SONiC is still Linux underneath, but production operation should respect the SONiC configuration and service model.
```

---

## 12. Follow-up Lab Direction

After this basic lab works, the next useful stages are:

```text
03a - Basic SONiC boot and interface validation
03b - Two SONiC nodes with eBGP
03c - SONiC to FRR interoperability
03d - ConfigDB persistence and rollback notes
03e - SONiC vs FRR vs Cumulus vs Cisco Nexus comparison
```

Do not jump directly to SONiC EVPN/VXLAN until the basic SONiC operational model is clear.

A better sequence is:

```text
boot -> interface mapping -> L3 interface -> config persistence -> BGP -> interoperability -> EVPN/VXLAN
```

---


## 14. Key Takeaways

- SONiC is a network operating system, not just a routing daemon.
- FRR is used inside SONiC, but SONiC adds a broader NOS architecture.
- ConfigDB is central to the SONiC configuration model.
- `config_db.json` is the startup configuration source.
- `sonic-vs` is useful for lightweight lab exposure.
- In Containerlab, `eth0` is management and `eth1` maps to the first SONiC data interface.
- This first lab should prove boot, interface mapping, and basic L3 reachability only.
- More advanced labs should come after the basic operational model is understood.

---

## References

- SONiC Architecture Wiki: https://github.com/sonic-net/SONiC/wiki/Architecture
- SONiC Configuration Wiki: https://github.com/sonic-net/SONiC/wiki/Configuration
- SONiC configuration model in sonic-buildimage: https://github.com/sonic-net/sonic-buildimage/blob/master/src/sonic-yang-models/doc/Configuration.md
- Containerlab `sonic-vs` kind: https://containerlab.dev/manual/kinds/sonic-vs/
- Containerlab overview: https://containerlab.dev/
