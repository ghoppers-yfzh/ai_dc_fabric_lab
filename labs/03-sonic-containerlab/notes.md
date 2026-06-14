# Lab 03 Notes — SONiC Containerlab Basics

## Purpose

This file records practical observations, issues, and lessons learned while running Lab 03.

The lab overview belongs in:

```text
labs/03-sonic-containerlab/README.md
```

The step-by-step validation workflow belongs in:

```text
labs/03-sonic-containerlab/validation.md
```

This notes file should capture what was discovered during the lab, especially behavior that is not obvious from the topology file alone.

---

## 03a - Basic SONiC Boot and Interface Validation

### Result

Lab 03a successfully validated basic SONiC container boot, data interface mapping, and host-to-switch Layer 3 reachability.

### Validated behavior

- `sonic1` booted using `docker-sonic-vs:202511`.
- `host1` booted using `alpine:latest`.
- The Containerlab data link was created between `sonic1:eth1` and `host1:eth1`.
- SONiC exposed the first data/front-panel interface as `Ethernet0`.
- `Ethernet0` was brought up and configured with `192.0.2.1/24`.
- `host1` was configured with `192.0.2.11/24` on `eth1`.
- SONiC and `host1` could ping each other successfully.

### Successful reachability test

From SONiC:

```bash
ping 192.0.2.11
```

Observed result:

```text
2 packets transmitted, 2 received, 0% packet loss
```

This confirms that the data link between SONiC `Ethernet0` and host `eth1` is working.

---

## Image Preparation Note

The `docker-sonic-vs` image is not pulled directly from Docker Hub by default.

When Containerlab cannot find `docker-sonic-vs:latest` locally, it attempts to pull:

```text
docker.io/library/docker-sonic-vs:latest
```

This fails because the image is not available there as a normal public Docker Hub image.

The SONiC VS image was downloaded from the SONiC build artifact as a zip file. Inside that artifact, the image path was:

```text
sonic-buildimage.vs/target/docker-sonic-vs.gz
```

The image was extracted and loaded into Docker, then tagged as:

```text
docker-sonic-vs:202511
```

The topology file should reference the local image tag:

```yaml
image: docker-sonic-vs:202511
```

---

## Artifact Zip Path Note

The downloaded Azure artifact was a large zip file, not a standalone gzip file.

The correct path inside the zip was:

```text
sonic-buildimage.vs/target/docker-sonic-vs.gz
```

The shorter path below did not match:

```text
target/docker-sonic-vs.gz
```

A working extraction command was:

```bash
unzip -j sonic-buildimage.vs.zip \
  sonic-buildimage.vs/target/docker-sonic-vs.gz \
  -d .
```

Then the image can be loaded with:

```bash
docker load -i docker-sonic-vs.gz
```

---

## Large Download Note

The SONiC build artifact can be very large.

For long downloads, use `tmux` or `screen` so the download continues even if the SSH session disconnects.

Example:

```bash
tmux new -s sonic-download
```

Inside the tmux session:

```bash
curl -fL --retry 5 --retry-delay 10 -C - "$URL" -o sonic-buildimage.vs.zip
```

Detach from tmux:

```text
Ctrl-b, then d
```

Reattach later:

```bash
tmux attach -t sonic-download
```

Avoid restarting `curl` with the same `-o` filename unless using resume mode. A restarted download can truncate the existing file to zero bytes if interrupted early.

---

## Alpine Host Shell Note

The `host1` container uses `alpine:latest`.

Alpine does not include `bash` by default, so this command fails:

```bash
docker exec -it clab-sonic-basic-host1 bash
```

Use `sh` instead:

```bash
docker exec -it clab-sonic-basic-host1 sh
```

---

## Host Default Route Note

`host1` receives a default route through the Containerlab management network:

```text
default via 172.20.20.1 dev eth0
```

Adding another default route through SONiC fails:

```bash
ip route add default via 192.0.2.1
```

Error:

```text
RTNETLINK answers: File exists
```

For the basic same-subnet test in Lab 03a, no default route through SONiC is required.

The connected route is enough:

```text
192.0.2.0/24 dev eth1 scope link src 192.0.2.11
```

This allows `host1` to reach SONiC `Ethernet0` at `192.0.2.1` directly.

The topology file should not include this command for `host1`:

```bash
ip route add default via 192.0.2.1
```

---

## SONiC 202511 sudo Note

The `docker-sonic-vs:202511` image used in this lab does not include the `sudo` binary.

Some SONiC `show` commands internally call `sudo`, which can cause errors such as:

```text
/bin/sh: 1: sudo: not found
```

For this lab, the following commands were enough to validate interface state and routing:

```bash
show interfaces status
ip addr show Ethernet0
ip route
```

The command below was not used as final evidence because it triggered a traceback in this image:

```bash
show ip interfaces
```

This is an image-specific lab behavior, not a production SONiC operational recommendation.

---

## Interface Mapping Observation

Containerlab created this link:

```text
sonic1:eth1 <----> host1:eth1
```

Inside SONiC, the first data/front-panel interface appeared as:

```text
Ethernet0
```

The management interface remains separate:

```text
eth0 = Containerlab management interface
eth1 = first data link from Containerlab topology
Ethernet0 = SONiC front-panel name for the first data interface
```

Useful rule:

```text
Do not treat eth0 as a data-plane port.
Data-plane links start from eth1.
```

---

## Validated Interface State

After configuration, SONiC showed `Ethernet0` as up:

```text
Ethernet0 ... routed ... Oper up ... Admin up
```

Linux-level verification showed:

```text
Ethernet0: <BROADCAST,MULTICAST,UP,LOWER_UP>
inet 192.0.2.1/24 brd 192.0.2.255 scope global Ethernet0
```

The SONiC routing table included:

```text
192.0.2.0/24 dev Ethernet0 proto kernel scope link src 192.0.2.1
```

---

## Evidence Files

The following output files should be saved for Lab 03a:

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

## Next Lab Direction

The next useful step is not EVPN/VXLAN yet.

A better sequence is:

```text
03a - Basic SONiC boot and interface validation
03b - Two SONiC nodes with basic L3 connectivity
03c - Two SONiC nodes with eBGP
03d - SONiC to FRR interoperability
03e - ConfigDB persistence and rollback notes
```

Only after the basic SONiC operational model is clear should the lab move toward SONiC EVPN/VXLAN.
