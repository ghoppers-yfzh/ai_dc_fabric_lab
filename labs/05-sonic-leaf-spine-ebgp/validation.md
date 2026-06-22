# Lab 05 Validation — SONiC Leaf-Spine eBGP Underlay

This file records the validation result for Lab 05.

The lab is successful when:

- all four SONiC nodes are running
- direct spine-to-leaf pings work
- `bgpd` is running on all nodes
- all expected eBGP sessions are established
- leaf loopbacks are learned through BGP
- leaf1 and leaf2 can ping each other using loopback source addresses

## 1. Deploy

Command:

```bash
containerlab deploy -t topology.clab.yml
```

Result:

```text
Created container name=leaf2
Created container name=spine1
Created container name=leaf1
Created container name=spine2
Created link: spine1:eth2 <-> leaf2:eth1
Created link: spine1:eth1 <-> leaf1:eth1
Created link: spine2:eth1 <-> leaf1:eth2
Created link: spine2:eth2 <-> leaf2:eth2
Executed command node=leaf2 command="ip link set eth1 up"
Executed command node=leaf2 command="ip link set eth2 up"
Executed command node=spine1 command="ip link set eth1 up"
Executed command node=spine1 command="ip link set eth2 up"
Executed command node=leaf1 command="ip link set eth1 up"
Executed command node=leaf1 command="ip link set eth2 up"
Executed command node=spine2 command="ip link set eth1 up"
Executed command node=spine2 command="ip link set eth2 up"
```

The topology came up and the Linux-side veth interfaces were brought up by the `exec` commands in the topology file.

## 2. Load SONiC interface configuration

Command:

```bash
for node in spine1 spine2 leaf1 leaf2; do
  docker exec clab-05-sonic-leaf-spine-ebgp-${node} config load /sonic/config/config_db.json -y
done
```

Result:

```text
Running command: /usr/local/bin/sonic-cfggen -j /sonic/config/config_db.json --write-to-db
```

A Python `SyntaxWarning` appeared the first time the command was run. It was from the SONiC CLI code in this image and did not stop the config from loading.

## 3. Interface addressing

Command:

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

Observed output:

```text
spine1 Ethernet0  10.0.11.0/31
spine1 Ethernet4  10.0.21.0/31
spine2 Ethernet0  10.0.12.0/31
spine2 Ethernet4  10.0.22.0/31
leaf1  Ethernet0  10.0.11.1/31
leaf1  Ethernet4  10.0.12.1/31
leaf2  Ethernet0  10.0.21.1/31
leaf2  Ethernet4  10.0.22.1/31
```

Result: **PASS**

## 4. Direct spine-to-leaf reachability

Commands:

```bash
docker exec clab-05-sonic-leaf-spine-ebgp-spine1 ping -c 3 10.0.11.1
docker exec clab-05-sonic-leaf-spine-ebgp-spine1 ping -c 3 10.0.21.1

docker exec clab-05-sonic-leaf-spine-ebgp-spine2 ping -c 3 10.0.12.1
docker exec clab-05-sonic-leaf-spine-ebgp-spine2 ping -c 3 10.0.22.1
```

Observed result:

```text
spine1 -> leaf1: 0% packet loss
spine1 -> leaf2: 0% packet loss
spine2 -> leaf1: 0% packet loss
spine2 -> leaf2: 0% packet loss
```

Result: **PASS**

## 5. bgpd process

Initial check:

```bash
for node in spine1 spine2 leaf1 leaf2; do
  echo "=== ${node} ==="
  docker exec clab-05-sonic-leaf-spine-ebgp-${node} ps -ef | grep '[b]gpd' || true
done
```

Observed result before manual start:

```text
=== spine1 ===
=== spine2 ===
=== leaf1 ===
=== leaf2 ===
```

`bgpd` was not running after container startup.

Manual start command:

```bash
for node in spine1 spine2 leaf1 leaf2; do
  docker exec clab-05-sonic-leaf-spine-ebgp-${node} bash -lc "mkdir -p /run/frr && chown frr:frr /run/frr 2>/dev/null || true; pkill -x bgpd 2>/dev/null || true; /usr/lib/frr/bgpd -d -A 127.0.0.1"
done
```

Observed result after start:

```text
spine1  /usr/lib/frr/bgpd -d -A 127.0.0.1
spine2  /usr/lib/frr/bgpd -d -A 127.0.0.1
leaf1   /usr/lib/frr/bgpd -d -A 127.0.0.1
leaf2   /usr/lib/frr/bgpd -d -A 127.0.0.1
```

Result: **PASS**

Note: FRR printed a warning about a large FD limit. It did not affect the lab.

## 6. Load BGP configuration

Command:

```bash
for node in spine1 spine2 leaf1 leaf2; do
  docker exec clab-05-sonic-leaf-spine-ebgp-${node} vtysh -f /sonic/config/frr.vtysh
done
```

Observed output included `bgpd` receiving the configuration:

```text
[bgpd] sending configuration
[bgpd] done
```

BGP config check:

```bash
for node in spine1 spine2 leaf1 leaf2; do
  echo "=== ${node} ==="
  docker exec clab-05-sonic-leaf-spine-ebgp-${node} vtysh -c 'show running-config' | sed -n '/router bgp/,/!/p'
done
```

Observed BGP config:

```text
spine1: router bgp 65001, neighbors 10.0.11.1 and 10.0.21.1
spine2: router bgp 65002, neighbors 10.0.12.1 and 10.0.22.1
leaf1:  router bgp 65101, neighbors 10.0.11.0 and 10.0.12.0
leaf2:  router bgp 65102, neighbors 10.0.21.0 and 10.0.22.0
```

Result: **PASS**

## 7. BGP neighbor state

Commands:

```bash
docker exec clab-05-sonic-leaf-spine-ebgp-spine1 vtysh -c 'show ip bgp summary'
docker exec clab-05-sonic-leaf-spine-ebgp-spine2 vtysh -c 'show ip bgp summary'
docker exec clab-05-sonic-leaf-spine-ebgp-leaf1 vtysh -c 'show ip bgp summary'
docker exec clab-05-sonic-leaf-spine-ebgp-leaf2 vtysh -c 'show ip bgp summary'
```

Observed result:

```text
spine1 neighbors:
10.0.11.1 AS65101 State/PfxRcd 2
10.0.21.1 AS65102 State/PfxRcd 2

spine2 neighbors:
10.0.12.1 AS65101 State/PfxRcd 3
10.0.22.1 AS65102 State/PfxRcd 3

leaf1 neighbors:
10.0.11.0 AS65001 State/PfxRcd 2
10.0.12.0 AS65002 State/PfxRcd 2

leaf2 neighbors:
10.0.21.0 AS65001 State/PfxRcd 3
10.0.22.0 AS65002 State/PfxRcd 3
```

All expected BGP sessions were established.

Result: **PASS**

## 8. BGP routes on leaves

Commands:

```bash
docker exec clab-05-sonic-leaf-spine-ebgp-leaf1 vtysh -c 'show ip route bgp'
docker exec clab-05-sonic-leaf-spine-ebgp-leaf2 vtysh -c 'show ip route bgp'
```

Observed result on leaf1:

```text
B>* 10.255.0.1/32 via 10.0.11.0, Ethernet0
B>* 10.255.0.2/32 via 10.0.12.0, Ethernet4
B>* 10.255.0.12/32 via 10.0.11.0, Ethernet0
```

Observed result on leaf2:

```text
B>* 10.255.0.1/32 via 10.0.21.0, Ethernet0
B>* 10.255.0.2/32 via 10.0.22.0, Ethernet4
B>* 10.255.0.11/32 via 10.0.21.0, Ethernet0
```

Leaf1 learned leaf2's loopback. Leaf2 learned leaf1's loopback.

Result: **PASS**

## 9. Leaf loopback reachability

Commands:

```bash
docker exec clab-05-sonic-leaf-spine-ebgp-leaf1 ping -c 3 -I 10.255.0.11 10.255.0.12
docker exec clab-05-sonic-leaf-spine-ebgp-leaf2 ping -c 3 -I 10.255.0.12 10.255.0.11
```

Observed result:

```text
leaf1 -> leaf2 loopback: 3 packets transmitted, 3 received, 0% packet loss
leaf2 -> leaf1 loopback: 3 packets transmitted, 3 received, 0% packet loss
```

Result: **PASS**

## 10. Cleanup

Commands:

```bash
sudo containerlab destroy -t topology.clab.yml
sudo containerlab destroy -t topology.clab.yml --cleanup
```

Result:

```text
Removed container name=clab-05-sonic-leaf-spine-ebgp-leaf1
Removed container name=clab-05-sonic-leaf-spine-ebgp-spine2
Removed container name=clab-05-sonic-leaf-spine-ebgp-leaf2
Removed container name=clab-05-sonic-leaf-spine-ebgp-spine1
Removing lab directory path=.../clab-05-sonic-leaf-spine-ebgp
```

Result: **PASS**

## Troubleshooting notes

### SONiC CLI warning during config load

This warning may appear when `config load` is run for the first time:

```text
SyntaxWarning: "is" with a literal. Did you mean "=="?
```

It comes from the SONiC CLI Python code in this container image. The config still loaded successfully.

### `show ip interfaces` is not used

Some SONiC `show` commands try to call `sudo`, but `sudo` is not installed in this container image. For this lab, `ip -br addr` and `vtysh` were more reliable.

### `bgpd=yes` does not prove that bgpd is running

The common `daemons` file enables `bgpd`, but the running container still did not start the `bgpd` process by itself.

The practical fix in this lab was to start `bgpd` manually before loading the BGP config.

### Linux-side veth interfaces need to be up

The topology uses `eth1` and `eth2` as the Linux-side containerlab veth interfaces. These must be up for ARP to work between SONiC nodes.

The topology file handles this with `exec` commands:

```text
ip link set eth1 up
ip link set eth2 up
```

## Final result

```text
Direct spine-to-leaf pings: PASS
bgpd process: PASS
BGP config load: PASS
BGP sessions: PASS
BGP route learning: PASS
Leaf loopback reachability: PASS
Cleanup: PASS
```

Lab 05 is complete.
