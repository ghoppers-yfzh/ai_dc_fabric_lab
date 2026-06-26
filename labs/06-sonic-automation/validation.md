# Lab 06 Validation

## Purpose

This document explains the validation workflow for Lab 06.

The goal is to confirm that the SONiC VS eBGP underlay is working after the lab has been deployed, ConfigDB has been loaded, runtime state has been prepared, and BGP configuration has been applied.

## Validation Script

Run:

```bash
bash scripts/05-validation-underlay.sh
```

The script reads:

```text
ip_asn.json
```

and writes output to:

```text
outputs/underlay-validation.md
```

## Validation Scope

The script validates four main areas:

```text
interface state
direct peer reachability
BGP control plane
loopback-to-loopback routed reachability
```

## Validation Flow

The validation script loops through every node defined in `ip_asn.json`.

For each node, it performs:

```text
1. show interface addresses
2. ping direct peers
3. show BGP summary
4. show BGP routes
5. ping all remote loopbacks using the local loopback as source
```

## 1. Interface Address Validation

Command pattern:

```bash
docker exec <container> ip -br addr
```

Example:

```bash
docker exec clab-06-sonic-automation-leaf1 ip -br addr
```

This confirms:

```text
management interface exists
SONiC front-panel interfaces have IP addresses
Loopback0 has the expected /32 address
Linux-side eth1/eth2 interfaces are up
```

Expected result:

```text
Ethernet0 has a point-to-point /31 address
Ethernet4 has a point-to-point /31 address
Loopback0 has a loopback /32 address
eth1 and eth2 are UP
```

## 2. Direct Peer Reachability

Command pattern:

```bash
docker exec <container> ping -c 3 -W 1 <peer-link-ip>
```

Example:

```bash
docker exec clab-06-sonic-automation-leaf1 ping -c 3 -W 1 10.0.11.0
```

This confirms:

```text
directly connected point-to-point links are working
local and peer interface IPs are correct
basic data-plane forwarding works on the direct link
ARP / neighbor resolution works
```

Expected result:

```text
3 packets transmitted
3 received
0% packet loss
```

If this fails, do not troubleshoot BGP first. Check interface state, IP addressing, and Linux-side `eth1` / `eth2` state.

## 3. BGP Summary Validation

Command pattern:

```bash
docker exec <container> vtysh -c "show ip bgp summary"
```

Example:

```bash
docker exec clab-06-sonic-automation-leaf1 vtysh -c "show ip bgp summary"
```

This confirms:

```text
bgpd is running
BGP neighbors are established
local ASN is correct
peer ASNs are correct
prefixes are received
```

Expected result:

```text
BGP neighbor state is Established
State/PfxRcd shows received prefix count
```

Example expected behavior:

```text
leaf nodes should have two BGP neighbors
spine nodes should have two BGP neighbors
```

## 4. BGP Route Validation

Command pattern:

```bash
docker exec <container> vtysh -c "show ip route bgp"
```

Example:

```bash
docker exec clab-06-sonic-automation-leaf1 vtysh -c "show ip route bgp"
```

This confirms:

```text
BGP-learned routes are installed in the routing table
remote loopback /32 routes are present
next hops point toward expected peers
```

Expected result:

```text
remote loopback /32 routes appear as BGP routes
routes are selected and installed
```

For example, a leaf should learn remote loopbacks such as:

```text
10.255.0.1/32
10.255.0.2/32
10.255.0.12/32
```

The exact route list depends on the current node.

## 5. Loopback-to-Loopback Reachability

Command pattern:

```bash
docker exec <container> ping -I <local-loopback-ip> -c 3 -W 1 <remote-loopback-ip>
```

Example:

```bash
docker exec clab-06-sonic-automation-leaf1 ping -I 10.255.0.11 -c 3 -W 1 10.255.0.12
```

This confirms:

```text
local loopback can be used as source
remote loopback is reachable
BGP-learned routes are working
return path exists
traffic crosses the routed fabric
```

Expected result:

```text
3 packets transmitted
3 received
0% packet loss
```

This is the strongest underlay validation check in this lab.

## Why the Source IP Is Specified

The validation script intentionally uses:

```bash
ping -I <local-loopback-ip> <remote-loopback-ip>
```

Without `-I <local-loopback-ip>`, Linux may choose a point-to-point link IP as the ping source.

That can cause a false failure if the remote node does not have a return route to that point-to-point subnet.

Using the local loopback as the source validates the intended behavior:

```text
local loopback -> routed underlay -> remote loopback
```

## Expected Successful Result

A successful validation output should show:

```text
interface addresses present
direct peer pings successful
BGP neighbors established
BGP routes learned
loopback-to-loopback pings successful
```

The output file should be saved at:

```text
outputs/underlay-validation.md
```

## Troubleshooting Guide

### Direct peer ping fails

Check:

```bash
docker exec <container> ip -br addr
docker exec <container> ip link show eth1
docker exec <container> ip link show eth2
docker exec <container> ip neigh
```

Likely causes:

```text
Linux-side veth interface is down
wrong point-to-point IP
wrong topology link
ConfigDB not loaded
```

### BGP summary does not show Established

Check:

```bash
docker exec <container> ps -ef | grep '[b]gpd'
docker exec <container> vtysh -c "show running-config"
docker exec <container> ping -c 3 <peer-link-ip>
```

Likely causes:

```text
bgpd not running
BGP config not loaded
direct peer reachability failed
ASN mismatch
neighbor IP mismatch
```

### BGP routes are missing

Check:

```bash
docker exec <container> vtysh -c "show ip bgp"
docker exec <container> vtysh -c "show running-config"
```

Likely causes:

```text
loopback not advertised
network statement missing
BGP policy issue
BGP session recently established and routes not yet converged
```

### Loopback ping fails but BGP route exists

Check whether the ping uses the correct source:

```bash
ping -I <local-loopback-ip> <remote-loopback-ip>
```

If the source is not specified, Linux may use a point-to-point link IP as the source. The return path to that link IP may not exist.

## What This Validation Proves

This validation proves:

```text
the SONiC VS underlay is reachable
direct point-to-point links work
BGP sessions establish
remote loopback routes are learned
loopback-to-loopback routed reachability works
```

## What This Validation Does Not Prove

This validation does not prove:

```text
hardware switch forwarding behavior
ASIC buffer behavior
line-rate performance
PFC behavior
ECN/DCQCN behavior
RoCEv2 performance
GPU cluster traffic behavior
production SONiC readiness
```

## Completion Criteria

Lab 06 validation is complete when:

```text
outputs/underlay-validation.md exists
direct peer pings show 0% packet loss
BGP summaries show established neighbors
BGP routes show remote loopback /32 routes
loopback-to-loopback pings show 0% packet loss
```
