# Lab 05 — SONiC Leaf-Spine eBGP Underlay

This lab builds a small SONiC leaf-spine underlay with two spines and two leaves.

The goal is to get a basic eBGP underlay working between SONiC nodes, advertise loopback routes, and prove that the leaves can reach each other through the fabric.

This lab does not cover EVPN/VXLAN yet. It keeps the focus on the underlay, which needs to be working before adding an overlay.

## Topology

```text
              spine1 AS65001
             /              \
            /                \
 leaf1 AS65101              leaf2 AS65102
            \                /
             \              /
              spine2 AS65002
```

Links:

```text
spine1 Ethernet0 <----> leaf1 Ethernet0
spine2 Ethernet0 <----> leaf1 Ethernet4
spine1 Ethernet4 <----> leaf2 Ethernet0
spine2 Ethernet4 <----> leaf2 Ethernet4
```

The containerlab links use Linux-side interfaces such as `eth1` and `eth2`. In this SONiC VS image, those interfaces need to be brought up for ARP to work. The topology file handles that with `exec` commands.

## Files

```text
labs/05-sonic-leaf-spine-ebgp/
├── README.md
├── topology.clab.yml
├── ip-plan.md
├── validation.md
├── configs/
│   ├── common/
│   │   └── daemons
│   ├── spine1/
│   │   ├── config_db.json
│   │   └── frr.vtysh
│   ├── spine2/
│   │   ├── config_db.json
│   │   └── frr.vtysh
│   ├── leaf1/
│   │   ├── config_db.json
│   │   └── frr.vtysh
│   └── leaf2/
│       ├── config_db.json
│       └── frr.vtysh
└── outputs/
```

## Addressing

| Node | Interface | IP address | Purpose |
|---|---:|---:|---|
| spine1 | Ethernet0 | `10.0.11.0/31` | to leaf1 |
| spine1 | Ethernet4 | `10.0.21.0/31` | to leaf2 |
| spine1 | Loopback0 | `10.255.0.1/32` | BGP router ID / advertised loopback |
| spine2 | Ethernet0 | `10.0.12.0/31` | to leaf1 |
| spine2 | Ethernet4 | `10.0.22.0/31` | to leaf2 |
| spine2 | Loopback0 | `10.255.0.2/32` | BGP router ID / advertised loopback |
| leaf1 | Ethernet0 | `10.0.11.1/31` | to spine1 |
| leaf1 | Ethernet4 | `10.0.12.1/31` | to spine2 |
| leaf1 | Loopback0 | `10.255.0.11/32` | advertised loopback |
| leaf2 | Ethernet0 | `10.0.21.1/31` | to spine1 |
| leaf2 | Ethernet4 | `10.0.22.1/31` | to spine2 |
| leaf2 | Loopback0 | `10.255.0.12/32` | advertised loopback |

## Deploy the lab

Run this from the lab directory:

```bash
sudo containerlab deploy -t topology.clab.yml
```

The topology should create four SONiC containers and four point-to-point links:

```text
spine1:eth1 <----> leaf1:eth1
spine2:eth1 <----> leaf1:eth2
spine1:eth2 <----> leaf2:eth1
spine2:eth2 <----> leaf2:eth2
```

## Load SONiC interface config

```bash
for node in spine1 spine2 leaf1 leaf2; do
  docker exec clab-05-sonic-leaf-spine-ebgp-${node} config load /sonic/config/config_db.json -y
done
```

A Python `SyntaxWarning` may appear the first time this command runs. It comes from the SONiC CLI code in this container image and does not stop the config from loading.

Check the addresses:

```bash
docker exec clab-05-sonic-leaf-spine-ebgp-spine1 ip -br addr show Ethernet0
docker exec clab-05-sonic-leaf-spine-ebgp-spine1 ip -br addr show Ethernet4

docker exec clab-05-sonic-leaf-spine-ebgp-spine2 ip -br addr show Ethernet0
docker exec clab-05-sonic-leaf-spine-ebgp-spine2 ip -br addr show Ethernet4

docker exec clab-05-sonic-leaf-spine-ebgp-leaf1 ip -br addr show Ethernet0
docker exec clab-05-sonic-leaf-spine-ebgp-leaf1 ip -br addr show Ethernet4

docker exec clab-05-sonic-leaf-spine-ebgp-leaf2 ip -br addr show Ethernet0
docker exec clab-05-sonic-leaf-spine-ebgp-leaf2 ip -br addr show Ethernet4
```

I use `ip -br addr` instead of `show ip interfaces` here. In this SONiC VS image, some `show` commands try to call `sudo`, but `sudo` is not installed in the container.

## Check direct link reachability

```bash
docker exec clab-05-sonic-leaf-spine-ebgp-spine1 ping -c 3 10.0.11.1
docker exec clab-05-sonic-leaf-spine-ebgp-spine1 ping -c 3 10.0.21.1

docker exec clab-05-sonic-leaf-spine-ebgp-spine2 ping -c 3 10.0.12.1
docker exec clab-05-sonic-leaf-spine-ebgp-spine2 ping -c 3 10.0.22.1
```

Do not move on to BGP until these direct pings work.

## Start bgpd

In this SONiC VS image, `bgpd` still needs to be started manually after the containers come up.

Check first:

```bash
for node in spine1 spine2 leaf1 leaf2; do
  echo "=== ${node} ==="
  docker exec clab-05-sonic-leaf-spine-ebgp-${node} ps -ef | grep '[b]gpd' || true
done
```

If no `bgpd` process is shown, start it on all nodes:

```bash
for node in spine1 spine2 leaf1 leaf2; do
  docker exec clab-05-sonic-leaf-spine-ebgp-${node} bash -lc "mkdir -p /run/frr && chown frr:frr /run/frr 2>/dev/null || true; pkill -x bgpd 2>/dev/null || true; /usr/lib/frr/bgpd -d -A 127.0.0.1"
done
```

You may see an FRR warning about a large file descriptor limit. It did not affect this lab.

This is a workaround for this SONiC VS lab image. It is not a production SONiC service model.

## Load BGP config

```bash
for node in spine1 spine2 leaf1 leaf2; do
  docker exec clab-05-sonic-leaf-spine-ebgp-${node} vtysh -f /sonic/config/frr.vtysh
done
```

Check that the BGP configuration is loaded:

```bash
for node in spine1 spine2 leaf1 leaf2; do
  echo "=== ${node} ==="
  docker exec clab-05-sonic-leaf-spine-ebgp-${node} vtysh -c 'show running-config' | sed -n '/router bgp/,/!/p'
done
```

## Validate BGP

```bash
docker exec clab-05-sonic-leaf-spine-ebgp-spine1 vtysh -c 'show ip bgp summary'
docker exec clab-05-sonic-leaf-spine-ebgp-spine2 vtysh -c 'show ip bgp summary'
docker exec clab-05-sonic-leaf-spine-ebgp-leaf1 vtysh -c 'show ip bgp summary'
docker exec clab-05-sonic-leaf-spine-ebgp-leaf2 vtysh -c 'show ip bgp summary'
```

Expected result:

```text
spine1 has two BGP neighbors: leaf1 and leaf2
spine2 has two BGP neighbors: leaf1 and leaf2
leaf1 has two BGP neighbors: spine1 and spine2
leaf2 has two BGP neighbors: spine1 and spine2
```

## Validate learned routes

```bash
docker exec clab-05-sonic-leaf-spine-ebgp-leaf1 vtysh -c 'show ip route bgp'
docker exec clab-05-sonic-leaf-spine-ebgp-leaf2 vtysh -c 'show ip route bgp'
```

Leaf1 should learn `10.255.0.12/32` through BGP. Leaf2 should learn `10.255.0.11/32` through BGP.

## Validate loopback reachability

```bash
docker exec clab-05-sonic-leaf-spine-ebgp-leaf1 ping -c 3 -I 10.255.0.11 10.255.0.12
docker exec clab-05-sonic-leaf-spine-ebgp-leaf2 ping -c 3 -I 10.255.0.12 10.255.0.11
```

If both pings work, the eBGP underlay is working.

## Clean up

```bash
sudo containerlab destroy -t topology.clab.yml
sudo containerlab destroy -t topology.clab.yml --cleanup
```

## Lab result

This lab was completed successfully.

The final validation showed:

```text
Direct spine-to-leaf pings: PASS
BGP sessions: PASS
BGP route learning: PASS
Leaf loopback reachability: PASS
```

## Notes

The useful part of this lab is the workflow:

1. Build a small SONiC leaf-spine topology.
2. Load interface config from `configs/`.
3. Confirm direct spine-to-leaf reachability.
4. Start `bgpd` when the SONiC VS image does not start it by itself.
5. Load FRR BGP config.
6. Validate BGP sessions, BGP routes, and loopback reachability.

This gives a clean SONiC underlay base before moving into automation or overlay work.
