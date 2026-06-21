# Lab 04 — SONiC eBGP Between Two Nodes

## Goal

This lab builds a simple eBGP session between two SONiC virtual switches in containerlab.

The lab is small on purpose. Before building a larger SONiC fabric, I want to understand the basic pieces clearly: interface mapping, ConfigDB loading, FRR daemon behaviour, BGP configuration, and route validation.

By the end of this lab:

- `sonic1` and `sonic2` should be running as SONiC VS containers.
- `Ethernet0` should be used as a routed point-to-point link.
- Each node should have a loopback address.
- `bgpd` should be running on both nodes.
- The eBGP session should be established.
- Each node should learn the other node's loopback route through BGP.
- Loopback-to-loopback ping should work.

## Topology

```text
+--------+ Ethernet0      Ethernet0 +--------+
| sonic1 | 10.0.12.1/30  10.0.12.2/30 | sonic2 |
| AS65101|---------------------------| AS65102|
| Lo0    |                           | Lo0    |
|10.255.0.1/32                       |10.255.0.2/32
+--------+                           +--------+
```

Containerlab link:

```text
sonic1:eth1 <----> sonic2:eth1
```

SONiC interface used by the lab:

```text
Ethernet0
```

In this SONiC VS image, the containerlab link appears as `eth1` in the Linux namespace, while the SONiC front-panel interface is `Ethernet0`. The lab IP address is configured on `Ethernet0`, but `eth1` also needs to be up for the point-to-point link to pass traffic.

The topology file handles this with containerlab `exec` commands:

```yaml
exec:
  - ip link set eth1 up
```

Without this, `Ethernet0` can have the correct IP address but ARP may still fail across the link.

## Files

```text
labs/04-sonic-ebgp/
├── README.md
├── topology.clab.yml
├── ip-plan.md
├── validation.md
├── configs/
│   ├── common/
│   │   └── daemons
│   ├── sonic1/
│   │   ├── config_db.json
│   │   └── frr.vtysh
│   └── sonic2/
│       ├── config_db.json
│       └── frr.vtysh
├── scripts/
│   └── validate.sh
└── outputs/
    └── .gitkeep
```

The config files are bind-mounted into the containers. This keeps the workflow simple: keep the intended config in the repo, then load it into the SONiC containers.

## Prerequisites

The SONiC VS image should already be available locally:

```bash
docker image ls | grep sonic
```

This lab expects the image tag below unless `topology.clab.yml` is changed:

```text
docker-sonic-vs:latest
```

## Deploy the Lab

From the lab directory:

```bash
cd labs/04-sonic-ebgp
sudo containerlab deploy -t topology.clab.yml
```

Check the containers:

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'
```

Check that the config directory is mounted:

```bash
docker exec clab-04-sonic-ebgp-sonic1 ls -l /sonic/config
docker exec clab-04-sonic-ebgp-sonic2 ls -l /sonic/config
```

Expected files:

```text
config_db.json
frr.vtysh
```

## Load SONiC Interface Config

Load the interface and loopback config from ConfigDB JSON:

```bash
docker exec clab-04-sonic-ebgp-sonic1 config load /sonic/config/config_db.json -y
docker exec clab-04-sonic-ebgp-sonic2 config load /sonic/config/config_db.json -y
```

Bring up `Ethernet0` if needed:

```bash
docker exec clab-04-sonic-ebgp-sonic1 config interface startup Ethernet0
docker exec clab-04-sonic-ebgp-sonic2 config interface startup Ethernet0
```

The topology already brings up the Linux-side `eth1` interface with containerlab `exec`. If direct ping does not work, check it manually:

```bash
docker exec clab-04-sonic-ebgp-sonic1 ip link show eth1
docker exec clab-04-sonic-ebgp-sonic2 ip link show eth1
```

If needed, bring it up manually:

```bash
docker exec clab-04-sonic-ebgp-sonic1 ip link set eth1 up
docker exec clab-04-sonic-ebgp-sonic2 ip link set eth1 up
```

Check the IP addresses:

```bash
docker exec clab-04-sonic-ebgp-sonic1 ip -br addr show Ethernet0
docker exec clab-04-sonic-ebgp-sonic1 ip -br addr show Loopback0

docker exec clab-04-sonic-ebgp-sonic2 ip -br addr show Ethernet0
docker exec clab-04-sonic-ebgp-sonic2 ip -br addr show Loopback0
```

`show ip interfaces` is not used in this lab because this SONiC VS image may call `sudo` internally, and `sudo` is not installed in the container.

## Check the Direct Link

Before looking at BGP, confirm the point-to-point link works:

```bash
docker exec clab-04-sonic-ebgp-sonic1 ping -c 3 10.0.12.2
docker exec clab-04-sonic-ebgp-sonic2 ping -c 3 10.0.12.1
```

Expected result:

```text
0% packet loss
```

If this fails, check ARP:

```bash
docker exec clab-04-sonic-ebgp-sonic1 ip neigh show dev Ethernet0
docker exec clab-04-sonic-ebgp-sonic2 ip neigh show dev Ethernet0
```

If the neighbour state shows `FAILED`, check whether `eth1` is up on both containers.

## Start BGP Daemon

In this SONiC VS image, FRR may be running but `bgpd` may not start automatically.

`/etc/frr/daemons` can contain:

```text
bgpd=yes
```

That is only a startup setting. It does not prove that `bgpd` is currently running.

Check the running FRR processes:

```bash
docker exec clab-04-sonic-ebgp-sonic1 ps -ef | egrep 'watchfrr|zebra|bgpd|staticd|mgmtd'
docker exec clab-04-sonic-ebgp-sonic2 ps -ef | egrep 'watchfrr|zebra|bgpd|staticd|mgmtd'
```

If `bgpd` is not running, start it manually for this lab:

```bash
docker exec clab-04-sonic-ebgp-sonic1 bash -lc "mkdir -p /run/frr && chown frr:frr /run/frr 2>/dev/null || true; /usr/lib/frr/bgpd -d -A 127.0.0.1"

docker exec clab-04-sonic-ebgp-sonic2 bash -lc "mkdir -p /run/frr && chown frr:frr /run/frr 2>/dev/null || true; /usr/lib/frr/bgpd -d -A 127.0.0.1"
```

Confirm it is running:

```bash
docker exec clab-04-sonic-ebgp-sonic1 ps -ef | grep '[b]gpd'
docker exec clab-04-sonic-ebgp-sonic2 ps -ef | grep '[b]gpd'
```

This manual step is a workaround for this virtual SONiC lab. It is not meant to describe how a production SONiC switch should be operated.

## Load BGP Config

Load the BGP config after `bgpd` is running:

```bash
docker exec clab-04-sonic-ebgp-sonic1 vtysh -f /sonic/config/frr.vtysh
docker exec clab-04-sonic-ebgp-sonic2 vtysh -f /sonic/config/frr.vtysh
```

Check the running config:

```bash
docker exec clab-04-sonic-ebgp-sonic1 vtysh -c 'show running-config'
docker exec clab-04-sonic-ebgp-sonic2 vtysh -c 'show running-config'
```

Expected result:

```text
sonic1 should show router bgp 65101
sonic2 should show router bgp 65102
```

The `frr.vtysh` files are config snippets. They should not include interactive commands such as:

```text
configure terminal
end
write memory
```

Those commands are useful when typing manually inside `vtysh`, but not when loading a file with `vtysh -f`.

## Validate

Run the main checks:

```bash
docker exec clab-04-sonic-ebgp-sonic1 ping -c 3 10.0.12.2
docker exec clab-04-sonic-ebgp-sonic2 ping -c 3 10.0.12.1

docker exec clab-04-sonic-ebgp-sonic1 vtysh -c 'show ip bgp summary'
docker exec clab-04-sonic-ebgp-sonic2 vtysh -c 'show ip bgp summary'

docker exec clab-04-sonic-ebgp-sonic1 vtysh -c 'show ip route bgp'
docker exec clab-04-sonic-ebgp-sonic2 vtysh -c 'show ip route bgp'

docker exec clab-04-sonic-ebgp-sonic1 ping -c 3 -I 10.255.0.1 10.255.0.2
docker exec clab-04-sonic-ebgp-sonic2 ping -c 3 -I 10.255.0.2 10.255.0.1
```

Expected result:

- Direct ping works across `Ethernet0`.
- BGP state is established.
- `sonic1` learns `10.255.0.2/32` through BGP.
- `sonic2` learns `10.255.0.1/32` through BGP.
- Loopback-to-loopback ping works.

## Clean Up

```bash
sudo containerlab destroy -t topology.clab.yml
```

## Notes

A few useful lessons came out of this lab:

- `Ethernet0` is the SONiC front-panel interface used for the lab IP address.
- `eth1` is the Linux-side veth interface created by containerlab.
- In this lab, `eth1` needs to be up on both containers before ARP works.
- `vtysh` can work even when not every FRR daemon is running.
- `/etc/frr/daemons` is a startup policy file, not proof of current process state.
- If `vtysh` says `bgpd is not running`, check the process list and start `bgpd` before loading BGP config.

These are good troubleshooting points to remember before moving to a larger SONiC leaf-spine lab.
