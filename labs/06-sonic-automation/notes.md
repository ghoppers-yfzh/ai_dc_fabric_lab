# Lab 06 Notes

## Purpose of This Lab

Lab 06 focuses on automation of a known-good SONiC eBGP underlay workflow.

The goal is not to add a new protocol or new topology. The goal is to make the existing manual workflow repeatable and easier to validate.

The lab follows this sequence:

```text
deploy topology
load ConfigDB
prepare runtime state
load BGP config
validate underlay
save output
```

## Host-side Scripts

The scripts in this lab are host-side orchestration scripts.

They are executed from the lab host, not manually inside each SONiC container.

Example:

```bash
bash scripts/05-validation-underlay.sh
```

The scripts then use `docker exec` to run commands inside each SONiC VS container.

Example:

```bash
docker exec clab-06-sonic-automation-leaf1 ip -br addr
```

This keeps the workflow repeatable and avoids manually entering each container.

## Why the Scripts Are Split

The workflow is intentionally split into separate scripts:

```text
01-deploy.sh
02-load-configdb.sh
03-prepare-runtime.sh
04-load-bgp.sh
05-validation-underlay.sh
```

This makes it easier to see which stage failed.

For learning and troubleshooting, this is better than hiding everything in a single `run-all.sh`.

A combined script can be added later, but the current version keeps each step visible.

## ConfigDB vs Runtime State

Loading ConfigDB is not the same as having all runtime processes ready.

ConfigDB represents intended SONiC configuration.

Runtime state still needs to be checked separately.

Examples of runtime state:

```text
Linux-side data interface state
bgpd process state
FRR readiness
BGP neighbor state
```

This lab keeps ConfigDB loading and runtime preparation as separate steps.

## SONiC VS Interface Mapping

In this Containerlab SONiC VS environment:

```text
Containerlab eth1 -> SONiC Ethernet0
Containerlab eth2 -> SONiC Ethernet4
```

The management interface is separate:

```text
eth0 = management network
```

Data-plane validation should not rely on `eth0`.

## Linux-side Interface State

In this virtual lab, Linux-side data interfaces may need to be brought up explicitly:

```bash
ip link set eth1 up
ip link set eth2 up
```

This is a SONiC VS lab behavior. It should be documented as a lab workaround, not treated as a production SONiC practice.

## BGP Runtime

The lab may require checking or starting `bgpd` manually inside the SONiC VS container.

Useful check:

```bash
ps -ef | grep '[b]gpd'
```

If `bgpd` is not running, BGP config may not load correctly through `vtysh`.

This is another SONiC VS lab-specific runtime behavior.

## Direct Peer Ping

Direct peer ping validates local point-to-point connectivity.

Example:

```bash
ping -c 3 -W 1 <peer-link-ip>
```

This validates:

```text
interface state
point-to-point addressing
direct link reachability
basic data-plane forwarding
```

Direct peer ping should pass before spending time troubleshooting BGP.

## BGP Summary

BGP summary validates control-plane session state.

Example:

```bash
vtysh -c "show ip bgp summary"
```

Expected result:

```text
neighbors are established
State/PfxRcd shows received prefixes
local AS and neighbor AS are correct
```

BGP session state alone is not enough. Route learning and data-plane reachability must also be checked.

## BGP Route Validation

BGP route validation confirms that remote loopback routes are installed.

Example:

```bash
vtysh -c "show ip route bgp"
```

Expected result:

```text
remote loopback /32 routes are present
routes point to expected spine or leaf next hops
```

This proves that the control plane is learning useful routes.

## Loopback-to-Loopback Ping

Loopback-to-loopback ping is the strongest underlay reachability test in this lab.

Correct format:

```bash
ping -I <local-loopback-ip> <remote-loopback-ip>
```

Example:

```bash
ping -I 10.255.0.11 -c 3 -W 1 10.255.0.12
```

This validates:

```text
local loopback source
remote loopback destination
BGP route learning
forward path
return path
end-to-end routed underlay reachability
```

## Why Source IP Matters

If the source IP is not specified, Linux may choose a point-to-point link IP as the source.

Example problem:

```text
source = 10.0.11.1
destination = 10.255.0.12
```

If the remote node does not have a return route to the point-to-point link subnet, the ping can fail even when the remote loopback route exists.

Using the local loopback as the source avoids this problem because loopback `/32` routes are advertised through BGP.

Correct validation:

```bash
ping -I <local-loopback-ip> <remote-loopback-ip>
```

## Interface Name vs Source IP

Linux `ping -I` can accept either an interface name or a source IP.

For this lab, use the source IP.

Recommended:

```bash
ping -I 10.255.0.11 10.255.0.12
```

Avoid binding to `Loopback0` for this validation:

```bash
ping -I Loopback0 10.255.0.12
```

The packet still needs to follow the routed underlay path through Ethernet interfaces. Binding to the loopback interface is not the same as using the loopback IP as the source address.

## jq Usage

The validation script uses `jq` to read `ip_asn.json`.

Main uses:

```bash
jq -r '.[].node' ip_asn.json
```

This lists all nodes.

```bash
jq -r --arg node "${node}" '.[] | select(.node == $node) | .parameters.loopback' ip_asn.json
```

This gets the local loopback for the current node.

```bash
jq -r --arg node "${node}" '.[] | select(.node == $node) | .parameters.links[] | [.peer, .peer_ip] | @tsv' ip_asn.json
```

This gets direct peer information for the current node.

The pattern is:

```text
structured data -> jq query -> shell loop -> docker exec validation
```

## Current Limitations

The current validation script is intentionally simple.

It saves output but does not yet provide a full automated PASS/FAIL summary.

Future improvements could include:

```text
set -o pipefail
automatic failure counting
summary table
separate per-node output files
CI-friendly exit code
run-all.sh wrapper
```

For the current learning stage, the simple version is preferred because it is easier to read and troubleshoot.

## Key Takeaways

- Automate only after the manual workflow is understood.
- Keep deployment, config loading, runtime preparation, and validation as separate steps.
- Direct peer ping should pass before BGP troubleshooting.
- BGP sessions must be checked together with route learning.
- Loopback-to-loopback ping should use the local loopback IP as the source.
- Virtual SONiC labs are useful for control-plane and workflow learning, but they do not prove hardware forwarding or AI fabric performance.
