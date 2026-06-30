# Cumulus Linux and NVUE Notes

## Purpose

This document captures the basic operating model of NVIDIA Cumulus Linux and NVUE.

The goal is not to build a Cumulus lab right now. The goal is to understand how Cumulus Linux is structured, how NVUE is used, and how it compares with SONiC, FRR-only labs, and traditional vendor network operating systems.

Key topics:

- Cumulus Linux
- NVUE
- Linux-based network operating system model
- FRR in Cumulus Linux
- interface and BGP configuration model
- EVPN/VXLAN configuration model
- operational differences compared with SONiC and Cisco Nexus

---

## 1. What Cumulus Linux Is

Cumulus Linux is NVIDIA's Linux-based network operating system for Ethernet switches.

A simple mental model:

```text
Cumulus Linux = Linux-based NOS for Ethernet switches
              + FRR for routing
              + Linux networking tools
              + NVUE as structured configuration/API layer
              + NVIDIA switch platform integration
```

Cumulus Linux is closer to a Linux server operational model than a traditional closed switch CLI model.

Instead of treating the switch as a black-box appliance, Cumulus exposes familiar Linux concepts:

```text
interfaces
system services
files
packages
FRR
logs
shell access
automation hooks
```

This makes it relevant to network automation, data center fabric operations, and infrastructure teams that prefer Linux-style workflows.

---

## 2. Why Cumulus Linux Matters

Cumulus Linux is useful to understand because it represents a different network operating model from traditional switch OS platforms.

Traditional network OS model:

```text
single vendor CLI
hidden Linux or embedded OS internals
configuration stored in vendor-specific format
operational workflows centered on CLI commands
```

Cumulus Linux model:

```text
Linux base system
FRR for routing protocols
Linux networking constructs
structured configuration through NVUE
automation-friendly operational model
```

This matters in modern data center networking because large fabrics are usually operated with:

```text
repeatable configuration
source-of-truth data
automation
validation
telemetry
Git-based workflows
```

Cumulus Linux is not the only platform that supports this model, but it is an important example of Linux-based data center switching.

---

## 3. What NVUE Is

NVUE stands for NVIDIA User Experience.

NVUE is a structured configuration and operational interface for Cumulus Linux.

It provides:

```text
CLI
REST API
object model
configuration apply workflow
show commands
set/unset commands
```

A useful mental model:

```text
NVUE = structured intent/configuration layer for Cumulus Linux
```

It is not just another CLI syntax. It is designed around a structured object model.

Common NVUE command patterns:

```bash
nv show ...
nv set ...
nv unset ...
nv config apply
nv config save
```

Example style:

```bash
nv show interface
nv show router bgp
nv set interface swp1 link state up
nv config apply
```

The exact command syntax depends on the Cumulus Linux version.

---

## 4. NVUE vs Linux Commands vs vtysh

Cumulus Linux can be configured in more than one way:

```text
NVUE commands
Linux commands
vtysh
manual file editing
automation tools
```

The important operational rule is:

```text
Do not mix NVUE-managed configuration with manual Linux/vtysh/file-based configuration for the same settings.
```

NVIDIA documentation warns that NVUE commands can replace configuration in files such as:

```text
/etc/network/interfaces
/etc/frr/frr.conf
```

This means that if a switch is operated through NVUE, configuration changes should generally stay within the NVUE workflow.

Bad mixed model:

```text
configure interface with NVUE
manually edit /etc/network/interfaces
run nv config apply later
manual change disappears or conflicts
```

Better model:

```text
choose NVUE as the source of configuration intent
make changes through nv set / nv unset
apply and save through NVUE
```

This is one of the most important Cumulus operational lessons.

---

## 5. FRR Role in Cumulus Linux

Cumulus Linux uses FRR for routing protocols.

FRR can provide:

```text
BGP
OSPF
static routing
EVPN control plane
route installation through zebra
```

This is similar to the earlier FRR-only labs in concept, but the platform model is different.

FRR-only lab:

```text
Linux container + FRR config files
```

Cumulus Linux:

```text
switch NOS + Linux + FRR + NVUE + platform integration
```

In Cumulus Linux, FRR is still important, but it should be understood as part of the broader NOS workflow.

If operating through NVUE, BGP and EVPN configuration should generally be expressed through NVUE rather than manually editing FRR config directly.

---

## 6. Interface Configuration Model

Cumulus Linux uses Linux-style interface naming and networking concepts.

Common switch port naming:

```text
swp1
swp2
swp3
...
```

Common Linux-style constructs:

```text
bridges
bonds
VLANs
SVIs
VRFs
VXLAN interfaces
```

This is different from Cisco-style naming:

```text
Ethernet1/1
Port-channel10
Vlan10
```

It is also different from SONiC's front-panel naming style:

```text
Ethernet0
Ethernet4
Ethernet8
```

The operational mindset is closer to Linux networking:

```text
physical switch ports = Linux interfaces
bridges = Linux bridge constructs
routing = FRR / kernel routing table
configuration = NVUE or Linux config files depending on chosen model
```

---

## 7. BGP Configuration Model

For a data center underlay, Cumulus Linux commonly supports the same design ideas used in earlier labs:

```text
leaf-spine topology
point-to-point links
/31 addressing
loopbacks
private ASNs
eBGP underlay
ECMP
```

Conceptually, a BGP underlay still needs to prove:

```text
direct link reachability
BGP neighbor establishment
route learning
loopback reachability
failure behavior
```

The difference is how the platform expresses and manages configuration.

FRR-only lab:

```text
edit bgpd.conf
run vtysh
validate with show ip bgp summary
```

SONiC lab:

```text
load ConfigDB
prepare runtime daemons
load FRR config
validate through vtysh and Linux commands
```

Cumulus Linux with NVUE:

```text
use nv set commands
apply configuration
validate with nv show / vtysh / Linux commands depending on workflow
```

The network design is familiar. The operating model is the new thing to learn.

---

## 8. EVPN/VXLAN Configuration Model

Cumulus Linux supports EVPN as the control plane for VXLAN.

In an EVPN/VXLAN fabric, the main building blocks are familiar:

```text
underlay routing
loopback reachability
VTEP source address
VLAN to VNI mapping
EVPN control plane
VXLAN data plane
L2VNI
L3VNI
VRF
anycast gateway
```

Cumulus Linux can express these through NVUE commands and its platform model.

At a high level:

```text
BGP underlay provides VTEP reachability.
EVPN advertises MAC/IP and VNI reachability.
VXLAN encapsulates tenant traffic between VTEPs.
```

For Cumulus, the useful learning goal is not memorizing every command immediately.

The useful goal is understanding how these concepts appear in the Cumulus model:

```text
bridge domains
VLANs
VNIs
VRFs
SVIs
VXLAN interfaces
BGP EVPN address family
NVUE object model
```

---

## 9. NVUE Configuration Workflow

A typical NVUE workflow is:

```bash
nv show ...
nv set ...
nv config diff
nv config apply
nv config save
```

A practical way to think about it:

```text
nv set       = stage intended change
nv config diff  = review change
nv config apply = apply running change
nv config save  = persist change
```

This is different from traditional CLI workflows where commands often take effect immediately.

The review/apply model is useful because it fits automation and change-control thinking.

---

## 10. Cumulus vs SONiC

Both Cumulus Linux and SONiC are relevant to cloud and data center networking, but their configuration models are different.

| Area | Cumulus Linux | SONiC |
|---|---|---|
| Base model | Linux-based NOS | Linux-based NOS with containerized services |
| Main structured config model | NVUE | ConfigDB |
| Routing stack | FRR | FRR inside SONiC service model |
| Interface naming | `swp1`, `swp2` style | `Ethernet0`, `Ethernet4` style |
| Operational style | Linux + NVUE + FRR | ConfigDB + Redis DBs + containers + FRR |
| Configuration warning | Avoid mixing NVUE with manual file/vtysh config | Understand ConfigDB vs runtime state |
| Learning value | Linux NOS and NVIDIA Ethernet operations | Cloud NOS architecture and ConfigDB model |

A simple comparison:

```text
Cumulus Linux = Linux switch NOS with NVUE as structured configuration layer.
SONiC = cloud-style NOS built around Redis databases, containers, ConfigDB, and FRR.
```

Both are useful, but they teach different operating models.

---

## 11. Cumulus vs Cisco Nexus

Cisco Nexus and Cumulus Linux can both be used in data center fabrics, but the operational model is different.

| Area | Cisco Nexus | Cumulus Linux |
|---|---|---|
| CLI model | Vendor CLI | Linux + NVUE |
| Configuration style | NX-OS running/startup config | NVUE object model or Linux config files |
| Routing | NX-OS routing stack | FRR |
| Automation | NX-API, Ansible modules, model-driven options | Linux tools, NVUE API/CLI, automation tooling |
| Operator mindset | Network appliance | Linux-based switch |
| Troubleshooting | NX-OS show commands | `nv show`, Linux commands, FRR/vtysh, logs |

For engineers with Cisco Nexus experience, the key adjustment is:

```text
Do not expect Cumulus Linux to behave like NX-OS with different command syntax.
Treat it as a Linux-based switch operating system with its own configuration model.
```

---

## 12. Operational Takeaways

Important points to remember:

```text
Cumulus Linux is a Linux-based network OS, not a traditional monolithic switch CLI.
NVUE is the structured configuration and operational interface.
FRR provides routing protocols such as BGP and EVPN.
Avoid mixing NVUE-managed config with manual Linux/vtysh/file-based changes.
EVPN/VXLAN concepts remain the same, but the configuration model is platform-specific.
Cumulus and SONiC are both useful to learn because they represent different open/cloud networking operating models.
```

For practical data center fabric learning, the most useful comparison is:

```text
FRR labs teach protocol behavior.
SONiC labs teach ConfigDB and cloud NOS runtime behavior.
Cumulus notes teach Linux NOS and NVUE operating model.
Cisco Nexus experience provides production data center fabric context.
```

---

## 13. Terms to Recognize

| Term | Meaning |
|---|---|
| Cumulus Linux | NVIDIA Linux-based NOS for Ethernet switches |
| NVUE | NVIDIA User Experience; structured CLI/API/object model for Cumulus Linux |
| FRR | Routing protocol suite used by Cumulus Linux |
| `swp` | Common Cumulus Linux switch port naming style |
| EVPN | BGP control plane commonly used with VXLAN overlays |
| VXLAN | Data-plane encapsulation for overlay networking |
| VTEP | VXLAN Tunnel Endpoint |
| L2VNI | VNI for L2 bridging domain |
| L3VNI | VNI for routed VRF traffic |
| MLAG | Multi-chassis link aggregation concept |
| NVUE API | API interface for structured Cumulus configuration and state |

---

## References

- NVIDIA Cumulus Linux User Guide: https://docs.nvidia.com/networking-ethernet-software/cumulus-linux/
- NVIDIA NVUE CLI documentation: https://docs.nvidia.com/networking-ethernet-software/cumulus-linux-516/System-Configuration/NVIDIA-User-Experience-NVUE/NVUE-CLI/
- NVIDIA NVUE Command Reference: https://docs.nvidia.com/networking-ethernet-software/nvue-reference/
- NVIDIA Cumulus Linux VXLAN and EVPN Network Reference Design Guide: https://docs.nvidia.com/networking-ethernet-software/guides/EVPN-Network-Reference/
- NVIDIA Cumulus Linux VXLAN Devices documentation: https://docs.nvidia.com/networking-ethernet-software/cumulus-linux-515/Network-Virtualization/VXLAN-Devices/
- NVIDIA Cumulus Linux EVPN documentation: https://docs.nvidia.com/networking-ethernet-software/cumulus-linux-44/Network-Virtualization/Ethernet-Virtual-Private-Network-EVPN/
- FRRouting vtysh documentation: https://docs.frrouting.org/en/latest/vtysh.html
