# SONiC Runtime and BGP Notes

## Purpose

This note captures the most useful SONiC runtime lessons from:

- `labs/03-sonic-containerlab/`
- `labs/04-sonic-ebgp/`
- `labs/05-sonic-leaf-spine-ebgp/`

The point is not to make SONiC look harder than it is. The point is to separate three things that are easy to mix up:

```text
configuration files
runtime processes
data-plane interface state
```

---

## 1. SONiC Is Not Just FRR

The earlier FRR labs run routing software directly.

SONiC is different. It is a network operating system model built around:

- Linux
- containers
- Redis databases
- ConfigDB
- FRR for routing
- platform abstraction through SONiC services

This matters because a routing command can fail for reasons that are not BGP design problems.

In the lab, BGP failed at first because the runtime process was not running, not because the ASN or neighbor configuration was wrong.

---

## 2. ConfigDB Is Intended Configuration

In SONiC, `config_db.json` describes intended configuration.

In these labs, interface addresses are stored in:

```text
configs/<node>/config_db.json
```

Then loaded with:

```bash
config load /sonic/config/config_db.json -y
```

This writes the JSON data into SONiC's ConfigDB.

Important point:

```text
ConfigDB loaded successfully does not mean every routing daemon is running.
```

ConfigDB handles intended system configuration. FRR runtime state still has to be checked separately.

---

## 3. `eth1` and `Ethernet0` Are Related, But Not the Same Name

In Containerlab, the SONiC data link is described with Linux-style names.

Example:

```yaml
links:
  - endpoints: ["sonic1:eth1", "sonic2:eth1"]
```

Inside SONiC, the first front-panel port appears as:

```text
Ethernet0
```

So the mapping is:

| Container/Linux side | SONiC front-panel side |
|---|---|
| `eth0` | management network |
| `eth1` | `Ethernet0` |
| `eth2` | `Ethernet4` |

In Lab 04 and Lab 05, direct ping failed until the Linux-side veth interfaces were brought up.

Example fix:

```bash
ip link set eth1 up
ip link set eth2 up
```

This can be placed in `topology.clab.yml` as an `exec` command.

---

## 4. Why Ping Failed Even When Ethernet0 Had an IP

This was the confusing part.

The SONiC front-panel interface had an IP address:

```text
Ethernet0 10.0.12.1/30
```

But cross-ping failed and ARP showed:

```text
FAILED
```

The reason was that the underlying Containerlab veth interface was down.

The IP address existed on the SONiC interface, but the virtual link was not passing traffic.

Useful troubleshooting order:

```bash
ip -br addr show Ethernet0
ip link show Ethernet0
ip link show eth1
ip neigh show dev Ethernet0
ping <neighbor-ip>
```

If ARP is failed, check the Linux-side veth link before spending time on BGP.

---

## 5. `show ip interfaces` Was Not Reliable in This Image

In the current SONiC VS image, this command failed:

```bash
show ip interfaces
```

The error showed that the command tried to call `sudo`, but `sudo` was not present in the container.

For these labs, the safer validation commands are:

```bash
ip -br addr show
ip link show
ip neigh show
vtysh -c 'show ip bgp summary'
vtysh -c 'show ip route bgp'
```

The lesson is not that SONiC CLI is bad. The lesson is that virtual lab images can have small limitations, so validation should use reliable commands.

---

## 6. `bgpd=yes` Is Not the Same as `bgpd` Running

This was the main BGP runtime lesson.

The file:

```text
/etc/frr/daemons
```

can contain:

```text
bgpd=yes
```

That means BGP is enabled for FRR startup.

It does not prove the BGP process is currently running.

The real check is:

```bash
ps -ef | grep '[b]gpd'
```

If `bgpd` is not running, `vtysh` may still open, but BGP commands will not work correctly.

The error can look like:

```text
bgpd is not running
```

---

## 7. Why `vtysh` Can Open When BGP Is Not Running

`vtysh` is a frontend to FRR daemons.

It can connect to available daemons such as:

- `zebra`
- `staticd`
- `mgmtd`

But if `bgpd` is not running, BGP configuration has nowhere to go.

This is why `vtysh` itself being available is not enough.

Good validation:

```bash
vtysh -c 'show running-config'
ps -ef | grep '[b]gpd'
vtysh -c 'show ip bgp summary'
```

---

## 8. Manual `bgpd` Startup Used in the Labs

In this SONiC VS image, `bgpd` was started manually:

```bash
mkdir -p /run/frr
chown frr:frr /run/frr 2>/dev/null || true
/usr/lib/frr/bgpd -d -A 127.0.0.1
```

After that, BGP config was loaded:

```bash
vtysh -f /sonic/config/frr.vtysh
```

This is acceptable for the lab because the goal is to learn and validate control-plane behavior.

It should be documented as a lab workaround, not as a production best practice.

A production or vendor-supported SONiC environment should use the normal service model for routing daemons.

---

## 9. Practical Validation Order

Use this order for SONiC eBGP labs:

```text
1. Deploy topology
2. Confirm containers are running
3. Load ConfigDB
4. Confirm interface addresses
5. Confirm Linux-side veth links are up
6. Ping direct neighbors
7. Confirm bgpd process is running
8. Load BGP config
9. Check BGP summary
10. Check BGP routes
11. Ping loopback to loopback
```

Do not skip direct ping. If direct ping fails, BGP troubleshooting is premature.

---

## 10. Key Takeaways

- `config_db.json` is intended configuration.
- Running processes are checked with `ps`.
- `vtysh` being available does not prove all FRR daemons are running.
- `bgpd=yes` does not prove `bgpd` is currently running.
- `eth1` and `eth2` are Containerlab-side interfaces; `Ethernet0` and `Ethernet4` are SONiC front-panel names.
- ARP failure usually means a link or interface-state problem, not a BGP problem.
- In virtual labs, reliable Linux commands are often better than fragile wrapper commands.
