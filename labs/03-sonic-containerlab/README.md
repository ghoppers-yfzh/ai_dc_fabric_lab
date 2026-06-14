# Lab 03 — SONiC Containerlab Basics

## Purpose

This lab introduces SONiC in Containerlab as the next step after the FRR-based leaf-spine and EVPN/VXLAN labs.

The goal of this first SONiC lab is intentionally small:

- boot a SONiC virtual switch in Containerlab
- understand the `sonic-vs` container workflow
- map Linux container interfaces to SONiC front-panel ports
- configure a basic Layer 3 interface
- validate connectivity to a Linux test host
- capture initial SONiC operational commands
- document how SONiC differs from the earlier FRR-only labs

This lab is not trying to build a full SONiC EVPN fabric yet. The immediate goal is platform familiarity and a clean validation baseline.

---

## Why This Lab Matters

Lab 01 and Lab 02 used FRR directly to build a data center fabric foundation.

SONiC is different because it is a network operating system built around a structured configuration database, containerized network services, and cloud-scale operational models.

For AI data center networking and GPU cloud infrastructure roles, this exposure is useful because SONiC is commonly discussed in hyperscaler, cloud, and open networking environments.

---

## Lab Scope

Current scope:

- one SONiC virtual switch
- one Linux test host
- one point-to-point data link
- manual interface configuration
- basic reachability validation
- operational command discovery

Future expansion:

- two SONiC nodes with BGP
- SONiC + FRR interoperability
- SONiC config persistence using `config_db.json`
- basic automation
- comparison with FRR / Cumulus / Cisco Nexus operational models

---

## Topology

```text
host1 ------------- sonic1
192.0.2.11/24      Ethernet0: 192.0.2.1/24
```

Containerlab management interfaces are separate from the data link.

---

## Files

```text
labs/03-sonic-containerlab/
├── README.md
├── topology.clab.yml
├── validation.md
├── notes.md
└── outputs/
```

---

## Image Requirement

This lab expects a local SONiC container image.

The topology file uses this example image name:

```text
docker-sonic-vs:202511
```

If your local image has a different tag, update `topology.clab.yml` before deploying.

Check local images:

```bash
docker images | grep -i sonic
```

---

## Deploy

From the lab directory:

```bash
cd ~/ai_dc_fabric_lab/labs/03-sonic-containerlab
sudo containerlab deploy -t topology.clab.yml
```

Inspect the lab:

```bash
sudo containerlab inspect -t topology.clab.yml
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
```

---

## Configure SONiC Interface

Enter the SONiC container:

```bash
docker exec -it clab-sonic-basic-sonic1 bash
```

Configure `Ethernet0`:

```bash
config interface ip add Ethernet0 192.0.2.1/24
config interface startup Ethernet0
```

Validate from SONiC:

```bash
show ip interfaces
ip addr show Ethernet0
ping -c 3 192.0.2.11
```

---

## Validate From Host

Check host interface:

```bash
docker exec clab-sonic-basic-host1 ip addr show eth1
docker exec clab-sonic-basic-host1 ip route
```

Ping SONiC:

```bash
docker exec clab-sonic-basic-host1 ping -c 3 192.0.2.1
```

Expected result:

```text
0% packet loss
```

---

## Save Evidence

```bash
mkdir -p outputs

{
  echo "# SONiC Basic Interface Validation"
  echo
  echo "## Containerlab inspect"
  sudo containerlab inspect -t topology.clab.yml
  echo
  echo "## Docker containers"
  docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
  echo
  echo "## SONiC show ip interfaces"
  docker exec clab-sonic-basic-sonic1 show ip interfaces || true
  echo
  echo "## SONiC Ethernet0"
  docker exec clab-sonic-basic-sonic1 ip addr show Ethernet0 || true
  echo
  echo "## host1 eth1"
  docker exec clab-sonic-basic-host1 ip addr show eth1
  echo
  echo "## host1 route"
  docker exec clab-sonic-basic-host1 ip route
  echo
  echo "## host1 ping sonic1"
  docker exec clab-sonic-basic-host1 ping -c 3 192.0.2.1
} > outputs/sonic-basic-validation.md
```

---

## Completion Criteria

This lab stage is complete when:

- `sonic1` starts successfully
- `host1` starts successfully
- `Ethernet0` on SONiC is configured with `192.0.2.1/24`
- `host1` has `192.0.2.11/24` on `eth1`
- `host1` can ping `192.0.2.1`
- SONiC operational commands are documented
- evidence is saved in `outputs/sonic-basic-validation.md`

---

## Cleanup

```bash
sudo containerlab destroy -t topology.clab.yml
```

Destroy and remove runtime files:

```bash
sudo containerlab destroy -t topology.clab.yml --cleanup
```

---

## Notes

Keep this lab small.

The value of this stage is to confirm the SONiC image, boot process, interface mapping, and operational workflow before building a larger BGP or EVPN lab.
