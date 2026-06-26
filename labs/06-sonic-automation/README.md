# Lab 06 - SONiC Underlay Validation Automation

## Purpose

This lab automates the known-good manual workflow from the SONiC leaf-spine eBGP underlay lab.

The goal is not to introduce a new routing design. The goal is to make SONiC lab deployment, ConfigDB loading, runtime preparation, BGP loading, and underlay validation repeatable.

This lab turns the manual SONiC eBGP workflow into a simple host-side automation workflow.

## Topology

The lab uses a small SONiC VS leaf-spine topology:

```text
          spine1          spine2
          /    \          /    \
       leaf1   \        /    leaf2
```

Logical scope:

- 2 spine nodes
- 2 leaf nodes
- SONiC VS containers
- eBGP underlay
- point-to-point `/31` links
- loopback `/32` route advertisement
- loopback-to-loopback reachability validation

## Files

```text
labs/06-sonic-automation/
├── README.md
├── notes.md
├── validation.md
├── topology.clab.yml
├── ip_asn.json
├── configs/
├── outputs/
└── scripts/
    ├── 01-deploy.sh
    ├── 02-load-configdb.sh
    ├── 03-prepare-runtime.sh
    ├── 04-load-bgp.sh
    └── 05-validation-underlay.sh
```

## Source Data

The file `ip_asn.json` is used as the lab source data for:

- node names
- loopback IPs
- point-to-point link IPs
- peer IPs
- ASNs

The validation script reads this file with `jq` and uses the data to run repeatable checks against each container.

## Workflow

Run the scripts from the lab directory or from the repo root.

Recommended order:

```bash
bash scripts/01-deploy.sh
bash scripts/02-load-configdb.sh
bash scripts/03-prepare-runtime.sh
bash scripts/04-load-bgp.sh
bash scripts/05-validation-underlay.sh
```

## Script Purpose

### `01-deploy.sh`

Deploys the Containerlab topology.

Expected actions:

```text
destroy old lab if present
deploy topology
create SONiC containers
create lab links
```

### `02-load-configdb.sh`

Loads SONiC ConfigDB data into each SONiC VS node.

Expected actions:

```text
copy or load node config_db.json
apply intended SONiC configuration
prepare interface IP and loopback state
```

### `03-prepare-runtime.sh`

Prepares runtime state that is required in this SONiC VS lab.

Expected actions:

```text
bring up Linux-side data interfaces if required
check or start bgpd
confirm runtime state before BGP config is loaded
```

This is treated as a virtual lab workaround, not a production SONiC operational model.

### `04-load-bgp.sh`

Loads FRR BGP configuration into each SONiC VS node.

Expected actions:

```text
load local ASN
load BGP neighbors
advertise loopback routes
activate eBGP sessions
```

### `05-validation-underlay.sh`

Runs underlay validation and saves the output to:

```text
outputs/underlay-validation.md
```

The script validates:

```text
interface addresses
direct peer reachability
BGP session state
BGP route learning
loopback-to-loopback reachability
```

## What This Lab Proves

This lab proves that:

- SONiC VS containers can be deployed in Containerlab.
- ConfigDB files can be loaded repeatably.
- Required runtime state can be prepared.
- BGP configuration can be loaded into FRR inside SONiC.
- Direct peer reachability works on point-to-point links.
- eBGP sessions establish between spines and leaves.
- Remote loopback routes are learned through BGP.
- Loopback-to-loopback reachability works when sourced from the local loopback IP.
- Validation output can be saved as repo evidence.

## What This Lab Does Not Prove

This lab does not prove:

- production SONiC deployment readiness
- hardware ASIC forwarding behavior
- line-rate forwarding performance
- real switch buffer behavior
- RoCEv2 behavior
- PFC, ECN, or DCQCN behavior
- GPU workload behavior
- production telemetry behavior

This is a virtual control-plane and workflow lab.

## Validation Output

The main validation output is:

```text
outputs/underlay-validation.md
```

This file should show:

- interface addressing on each node
- successful direct peer pings
- established BGP sessions
- learned BGP routes
- successful loopback-to-loopback pings using the local loopback as the source IP

## Key Learning Point

For loopback-to-loopback validation, use:

```bash
ping -I <local-loopback-ip> <remote-loopback-ip>
```

Do not rely on the default source address. Linux may choose a point-to-point link IP as the source. If that link subnet is not advertised through BGP, the remote node may not have a return route.

## Status

Lab 06 is considered successful when:

```text
direct peer ping passes
BGP sessions are established
remote loopback routes are installed
loopback-to-loopback ping passes with local loopback source
validation output is saved under outputs/
```
