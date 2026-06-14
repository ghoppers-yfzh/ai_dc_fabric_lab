# Validation Guide — SONiC Containerlab Basics

## Purpose

This file documents the validation workflow for Lab 03.

The goal of this first SONiC lab is intentionally small:

- boot a `sonic-vs` container under Containerlab
- connect one Linux host to one SONiC data interface
- understand the interface mapping between Containerlab and SONiC
- configure a basic Layer 3 interface on SONiC
- validate host-to-switch reachability
- save evidence under `outputs/`

This lab does not validate BGP, EVPN/VXLAN, RoCEv2, PFC, ECN, DCQCN, telemetry, or production hardware behavior.

---

## Lab Scope

Validated scope:

- SONiC VS image loading
- Containerlab deployment
- one SONiC node
- one Linux host
- one data-plane link
- SONiC `Ethernet0` interface startup
- IPv4 address assignment on SONiC `Ethernet0`
- IPv4 address assignment on host `eth1`
- same-subnet ping between host and SONiC
- basic output capture

Out of scope for this stage:

- BGP
- EVPN/VXLAN
- multi-node SONiC fabric
- SONiC-to-FRR interoperability
- ConfigDB persistence deep dive
- ASIC forwarding behavior
- production SONiC deployment readiness

---

## Topology

```text
host1 ---------------- sonic1
eth1                  Ethernet0
192.0.2.11/24         192.0.2.1/24
```

Containerlab link definition:

```text
sonic1:eth1 <----> host1:eth1
```

Expected interface mapping:

| Containerlab endpoint | Inside SONiC / Linux | Role |
|---|---|---|
| `sonic1:eth0` | `eth0` | management interface |
| `sonic1:eth1` | `Ethernet0` | first SONiC data/front-panel interface |
| `host1:eth1` | `eth1` | host data interface |

Important rule:

```text
Do not use eth0 as a data-plane port.
Containerlab data links start from eth1.
```

---

## Image Requirement

This lab uses:

```text
docker-sonic-vs:202511
```

Check that the image exists locally:

```bash
docker images | grep -i sonic
```

Expected result:

```text
docker-sonic-vs   202511
```

The topology file should reference the same local image tag:

```bash
grep -n "image:" topology.clab.yml
```

Expected result:

```text
image: docker-sonic-vs:202511
```

---

## Topology File Check

Before deploying, confirm that `host1` does not try to add a default route through SONiC.

```bash
grep -n "ip route add default" topology.clab.yml || echo "OK: no host default route override"
```

Expected result:

```text
OK: no host default route override
```

Reason:

`host1` already receives a default route through the Containerlab management network. Adding another default route causes:

```text
RTNETLINK answers: File exists
```

For this same-subnet lab, no default route through SONiC is needed.

---

## Deploy the Lab

From the lab directory:

```bash
cd ~/ai_dc_fabric_lab/labs/03-sonic-containerlab
containerlab deploy -t topology.clab.yml
```

Expected result:

- lab directory is created
- `sonic1` container is created
- `host1` container is created
- link `sonic1:eth1` to `host1:eth1` is created
- `host1` receives `192.0.2.11/24` on `eth1`
- both containers are running

The deploy output should show something similar to:

```text
Created link: sonic1:eth1 <----> host1:eth1
Executed command node=host1 command="ip addr add 192.0.2.11/24 dev eth1"
Executed command node=host1 command="ip link set eth1 up"
```

---

## Inspect the Lab

```bash
containerlab inspect -t topology.clab.yml
```

```bash
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
```

Expected containers:

```text
clab-sonic-basic-sonic1
clab-sonic-basic-host1
```

Expected image for SONiC:

```text
docker-sonic-vs:202511
```

---

## Host Validation

The host uses `alpine:latest`, so use `sh`, not `bash`.

```bash
docker exec -it clab-sonic-basic-host1 sh
```

Check host interface and route table:

```bash
ip addr show eth1
ip route
```

Expected result:

```text
192.0.2.11/24 on eth1
192.0.2.0/24 dev eth1 scope link src 192.0.2.11
default via 172.20.20.1 dev eth0
```

The default route through `eth0` is the Containerlab management default route. This is expected.

Exit the host shell:

```bash
exit
```

---

## SONiC Basic Validation

Enter the SONiC container:

```bash
docker exec -it clab-sonic-basic-sonic1 bash
```

Check interfaces:

```bash
show interfaces status
```

Before configuration, `Ethernet0` may be admin down / oper down.

Configure `Ethernet0`:

```bash
config interface startup Ethernet0
config interface ip add Ethernet0 192.0.2.1/24
```

Check interface status:

```bash
show interfaces status
ip addr show Ethernet0
ip route
```

Expected result:

```text
Ethernet0 admin up
Ethernet0 oper up
Ethernet0 has 192.0.2.1/24
192.0.2.0/24 is connected through Ethernet0
```

Example evidence:

```text
Ethernet0 ... routed ... Oper up ... Admin up
```

```text
Ethernet0: <BROADCAST,MULTICAST,UP,LOWER_UP>
inet 192.0.2.1/24 brd 192.0.2.255 scope global Ethernet0
```

```text
192.0.2.0/24 dev Ethernet0 proto kernel scope link src 192.0.2.1
```

---

## SONiC Image-specific Note

The `docker-sonic-vs:202511` image may not include the `sudo` binary.

Some SONiC `show` commands internally call `sudo`, which can cause errors such as:

```text
/bin/sh: 1: sudo: not found
```

Because of this image-specific behavior, avoid using the following command as final evidence in this lab:

```bash
show ip interfaces
```

Use these commands instead:

```bash
show interfaces status
ip addr show Ethernet0
ip route
```

The lab runs as root inside the SONiC container, so this is sufficient for Lab 03a validation.

---

## Reachability Validation

### SONiC to host1

From inside the SONiC container:

```bash
ping -c 3 192.0.2.11
```

Expected result:

```text
0% packet loss
```

Exit the SONiC shell:

```bash
exit
```

### host1 to SONiC

From the lab server:

```bash
docker exec clab-sonic-basic-host1 ping -c 3 192.0.2.1
```

Expected result:

```text
0% packet loss
```

This confirms that the SONiC data interface and the host data interface are in the same Layer 3 subnet and can reach each other.

---

## Save Validation Outputs

From the lab directory:

```bash
cd ~/ai_dc_fabric_lab/labs/03-sonic-containerlab
mkdir -p outputs
```

Save deploy status:

```bash
{
  echo "# Lab 03a Deploy Status"
  echo
  echo "## containerlab inspect"
  containerlab inspect -t topology.clab.yml
  echo
  echo "## docker ps"
  docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
} > outputs/lab03a-deploy-status.md
```

Save SONiC outputs:

```bash
docker exec clab-sonic-basic-sonic1 show interfaces status \
  > outputs/sonic1-interface-status.txt 2>&1

docker exec clab-sonic-basic-sonic1 ip addr show Ethernet0 \
  > outputs/sonic1-ethernet0-ip-addr.txt

docker exec clab-sonic-basic-sonic1 ip route \
  > outputs/sonic1-ip-route.txt
```

Save host outputs:

```bash
docker exec clab-sonic-basic-host1 sh -c "ip addr show eth1" \
  > outputs/host1-eth1-ip-addr.txt

docker exec clab-sonic-basic-host1 sh -c "ip route" \
  > outputs/host1-ip-route.txt
```

Save reachability outputs:

```bash
docker exec clab-sonic-basic-host1 ping -c 3 192.0.2.1 \
  > outputs/host1-to-sonic1-ping.txt

docker exec clab-sonic-basic-sonic1 ping -c 3 192.0.2.11 \
  > outputs/sonic1-to-host1-ping.txt
```

---

## Expected Output Files

The completed Lab 03a validation should include:

```text
outputs/lab03a-deploy-status.md
outputs/sonic1-interface-status.txt
outputs/sonic1-ethernet0-ip-addr.txt
outputs/sonic1-ip-route.txt
outputs/host1-eth1-ip-addr.txt
outputs/host1-ip-route.txt
outputs/host1-to-sonic1-ping.txt
outputs/sonic1-to-host1-ping.txt
```

---

## Completion Criteria

Lab 03a is complete when:

- `docker-sonic-vs:202511` is loaded locally
- `topology.clab.yml` references `docker-sonic-vs:202511`
- `containerlab deploy -t topology.clab.yml` succeeds
- `sonic1` is running
- `host1` is running
- Containerlab creates the link between `sonic1:eth1` and `host1:eth1`
- `host1` has `192.0.2.11/24` on `eth1`
- SONiC `Ethernet0` is admin up
- SONiC `Ethernet0` is oper up
- SONiC `Ethernet0` has `192.0.2.1/24`
- SONiC can ping `192.0.2.11`
- `host1` can ping `192.0.2.1`
- validation outputs are saved under `outputs/`
- practical observations are recorded in `notes.md`

---

## Cleanup

Destroy the lab:

```bash
containerlab destroy -t topology.clab.yml
```

Destroy and remove generated runtime files:

```bash
containerlab destroy -t topology.clab.yml --cleanup
```

Generated Containerlab runtime directories should not be committed.

Use `.gitignore` to ignore them:

```gitignore
clab-*/
```
