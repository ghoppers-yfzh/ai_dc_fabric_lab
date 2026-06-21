# Lab 04 Validation — SONiC eBGP Between Two Nodes

## What This Validation Proves

This validation confirms that two SONiC virtual switches can form an eBGP session and exchange loopback routes.

The lab is considered successful when:

- both SONiC containers are running
- the config files are mounted into the containers
- the point-to-point link works
- `bgpd` is running in both containers
- the eBGP session is established
- each node learns the other node's loopback route
- loopback-to-loopback ping works

## 1. Check the Lab Is Running

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'
```

Expected containers:

```text
clab-04-sonic-ebgp-sonic1
clab-04-sonic-ebgp-sonic2
```

## 2. Check Config Mounts

```bash
docker exec clab-04-sonic-ebgp-sonic1 ls -l /sonic/config
docker exec clab-04-sonic-ebgp-sonic2 ls -l /sonic/config
```

Expected files:

```text
config_db.json
frr.vtysh
```

## 3. Load Interface Config

```bash
docker exec clab-04-sonic-ebgp-sonic1 config load /sonic/config/config_db.json -y
docker exec clab-04-sonic-ebgp-sonic2 config load /sonic/config/config_db.json -y
```

Bring up `Ethernet0` if needed:

```bash
docker exec clab-04-sonic-ebgp-sonic1 config interface startup Ethernet0
docker exec clab-04-sonic-ebgp-sonic2 config interface startup Ethernet0
```

The topology file also brings up `eth1` with containerlab `exec`:

```yaml
exec:
  - ip link set eth1 up
```

This matters because the containerlab veth link appears as `eth1` in the Linux namespace, while the lab IP is configured on SONiC `Ethernet0`.

## 4. Check Interfaces and IP Addresses

Use `ip` commands for this lab:

```bash
docker exec clab-04-sonic-ebgp-sonic1 ip -br addr show Ethernet0
docker exec clab-04-sonic-ebgp-sonic1 ip -br addr show Loopback0

docker exec clab-04-sonic-ebgp-sonic2 ip -br addr show Ethernet0
docker exec clab-04-sonic-ebgp-sonic2 ip -br addr show Loopback0
```

Expected addresses:

| Node | Interface | Expected IP |
|---|---|---|
| sonic1 | Ethernet0 | 10.0.12.1/30 |
| sonic2 | Ethernet0 | 10.0.12.2/30 |
| sonic1 | Loopback0 | 10.255.0.1/32 |
| sonic2 | Loopback0 | 10.255.0.2/32 |

`show ip interfaces` is avoided because this SONiC VS image may fail with `sudo: not found`.

## 5. Check the Linux-Side veth Link

```bash
docker exec clab-04-sonic-ebgp-sonic1 ip link show eth1
docker exec clab-04-sonic-ebgp-sonic2 ip link show eth1
```

Expected result:

```text
eth1 should be UP on both nodes
```

If it is down, bring it up manually:

```bash
docker exec clab-04-sonic-ebgp-sonic1 ip link set eth1 up
docker exec clab-04-sonic-ebgp-sonic2 ip link set eth1 up
```

If only one side is up, it may show `NO-CARRIER`. Bring up both sides before checking ping.

## 6. Check Direct Link Reachability

```bash
docker exec clab-04-sonic-ebgp-sonic1 ping -c 3 10.0.12.2
docker exec clab-04-sonic-ebgp-sonic2 ping -c 3 10.0.12.1
```

Expected result:

```text
0% packet loss
```

If direct ping fails, check ARP:

```bash
docker exec clab-04-sonic-ebgp-sonic1 ip neigh show dev Ethernet0
docker exec clab-04-sonic-ebgp-sonic2 ip neigh show dev Ethernet0
```

If the neighbour entry shows `FAILED`, check `eth1` first. BGP will not work until this point-to-point link is working.

## 7. Check FRR Daemons

```bash
docker exec clab-04-sonic-ebgp-sonic1 ps -ef | egrep 'watchfrr|zebra|bgpd|staticd|mgmtd'
docker exec clab-04-sonic-ebgp-sonic2 ps -ef | egrep 'watchfrr|zebra|bgpd|staticd|mgmtd'
```

`bgpd` must be running before BGP config can be loaded.

In this SONiC VS image, `/etc/frr/daemons` may already contain:

```text
bgpd=yes
```

That only means BGP is enabled for FRR startup. It does not prove that `bgpd` is running right now.

If `bgpd` is missing, start it manually:

```bash
docker exec clab-04-sonic-ebgp-sonic1 bash -lc "mkdir -p /run/frr && chown frr:frr /run/frr 2>/dev/null || true; /usr/lib/frr/bgpd -d -A 127.0.0.1"

docker exec clab-04-sonic-ebgp-sonic2 bash -lc "mkdir -p /run/frr && chown frr:frr /run/frr 2>/dev/null || true; /usr/lib/frr/bgpd -d -A 127.0.0.1"
```

Confirm again:

```bash
docker exec clab-04-sonic-ebgp-sonic1 ps -ef | grep '[b]gpd'
docker exec clab-04-sonic-ebgp-sonic2 ps -ef | grep '[b]gpd'
```

## 8. Load BGP Config

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

If the BGP config does not appear, check whether `bgpd` is running.

## 9. Check BGP Neighbor State

```bash
docker exec clab-04-sonic-ebgp-sonic1 vtysh -c 'show ip bgp summary'
docker exec clab-04-sonic-ebgp-sonic2 vtysh -c 'show ip bgp summary'
```

Expected result:

```text
sonic1 should see neighbor 10.0.12.2 in Established state.
sonic2 should see neighbor 10.0.12.1 in Established state.
```

In FRR output, the `State/PfxRcd` column usually shows a number when the session is established and prefixes have been received.

## 10. Check BGP Routes

```bash
docker exec clab-04-sonic-ebgp-sonic1 vtysh -c 'show ip route bgp'
docker exec clab-04-sonic-ebgp-sonic2 vtysh -c 'show ip route bgp'
```

Expected result on `sonic1`:

```text
B>* 10.255.0.2/32 [20/0] via 10.0.12.2, Ethernet0
```

Expected result on `sonic2`:

```text
B>* 10.255.0.1/32 [20/0] via 10.0.12.1, Ethernet0
```

Exact formatting may vary, but the remote loopback route should be installed as a BGP route.

## 11. Check Loopback-to-Loopback Reachability

```bash
docker exec clab-04-sonic-ebgp-sonic1 ping -c 3 -I 10.255.0.1 10.255.0.2
docker exec clab-04-sonic-ebgp-sonic2 ping -c 3 -I 10.255.0.2 10.255.0.1
```

Expected result:

```text
0% packet loss
```

This confirms that the remote loopback routes were learned through BGP and are usable for traffic forwarding.

## Successful Test Commands

These commands were used for the final successful validation:

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

## Troubleshooting Notes

### Direct ping fails but the IP addresses look correct

Check ARP:

```bash
docker exec clab-04-sonic-ebgp-sonic1 ip neigh show dev Ethernet0
docker exec clab-04-sonic-ebgp-sonic2 ip neigh show dev Ethernet0
```

If the neighbour state is `FAILED`, check `eth1`:

```bash
docker exec clab-04-sonic-ebgp-sonic1 ip link show eth1
docker exec clab-04-sonic-ebgp-sonic2 ip link show eth1
```

In this lab, `Ethernet0` is the SONiC front-panel interface, but the containerlab veth link appears as `eth1` in the Linux namespace. Bringing up `eth1` on both nodes fixes the direct ping issue.

### `show ip interfaces` fails with `sudo: not found`

Use `ip -br addr` instead:

```bash
docker exec clab-04-sonic-ebgp-sonic1 ip -br addr
docker exec clab-04-sonic-ebgp-sonic2 ip -br addr
```

This is a limitation of this SONiC VS image, not an IP configuration failure.

### `vtysh` says `bgpd is not running`

This means FRR is available, but the BGP daemon is not running.

`bgpd=yes` in `/etc/frr/daemons` is not enough by itself. It only affects how FRR starts when the service manager reads that file.

For this lab, start `bgpd` manually on both nodes, then load the BGP config again.

### `vtysh -f` reports unknown command for `configure terminal`

The `frr.vtysh` file should be a config snippet, not an interactive CLI transcript.

Do not include these lines in `frr.vtysh`:

```text
configure terminal
end
write memory
```

Use the config stanza directly, starting with `router bgp ...`.

## Result

Lab 04 is successful when all of these are true:

- direct point-to-point ping works
- BGP neighbors are established
- each node learns the remote loopback route through BGP
- loopback-to-loopback ping works

At this point, the lab is complete and ready to be committed.
