# Lab 07 - SONiC Validation Checks

## Purpose

This lab improves the validation workflow from Lab 06.

Lab 06 introduced host-side shell scripts to deploy a SONiC VS leaf-spine lab, load ConfigDB, prepare runtime state, load BGP configuration, and save underlay validation output.

Lab 07 focuses on making validation more machine-checkable.

The goal is to move from human-readable validation output to a clear PASS/FAIL checker that can be used in repeatable automation workflows.

## Scope

This lab does not introduce a new topology.

It reuses the Lab 06 SONiC leaf-spine topology and source data.

Primary input:

```text
labs/06-sonic-automation/ip_asn.json
```

Expected running containers:

```text
clab-06-sonic-automation-spine1
clab-06-sonic-automation-spine2
clab-06-sonic-automation-leaf1
clab-06-sonic-automation-leaf2
```

## Directory Structure

```text
labs/07-sonic-validation-checks/
├── README.md
├── scripts/
│   └── check-underlay.py
└── outputs/
```

## What This Lab Checks

The checker should validate:

```text
container existence
direct peer reachability
BGP neighbor state
BGP route learning
loopback-to-loopback reachability
```

The script should print a simple summary such as:

```text
PASS container spine1 exists
PASS spine1 -> leaf1 direct peer ping
PASS spine1 BGP summary
PASS spine1 -> leaf1 loopback ping
```

If all checks pass, the script should exit with code `0`.

If any check fails, the script should exit with code `1`.

## Why This Lab Uses Python

Lab 06 used a shell script because it was easier to read and matched the manual workflow.

Lab 07 uses Python because it is better suited for:

```text
reading JSON data
looping through structured topology information
tracking PASS/FAIL results
printing summaries
returning CI-friendly exit codes
```

The purpose is not to replace shell completely.

The purpose is to show how validation logic can become more structured and reusable.

## Input Data

The checker reads node and link information from:

```text
../06-sonic-automation/ip_asn.json
```

The JSON file provides:

```text
node name
loopback IP
point-to-point link IP
peer name
peer IP
ASN
```

This keeps the validation script data-driven instead of hardcoding every ping target.

## Planned Script

Main script:

```text
scripts/check-underlay.py
```

Planned behavior:

```text
1. Load Lab 06 ip_asn.json.
2. Build expected container names.
3. Check each container exists.
4. For each node, ping all direct peer IPs.
5. Check BGP summary output.
6. Check BGP route output.
7. Ping every remote loopback using the local loopback as source.
8. Print PASS/FAIL summary.
9. Save output to outputs/check-underlay-summary.md.
10. Exit 0 if all checks pass, otherwise exit 1.
```

## Suggested Commands

Make sure Lab 06 is already running and prepared:

```bash
cd labs/06-sonic-automation

bash scripts/01-deploy.sh
bash scripts/02-load-configdb.sh
bash scripts/03-prepare-runtime.sh
bash scripts/04-load-bgp.sh
```

Then run Lab 07 validation checks:

```bash
cd ../07-sonic-validation-checks

python3 scripts/check-underlay.py
```

## Expected Successful Result

A successful run should show:

```text
all expected containers are present
all direct peer pings pass
BGP neighbors are established
remote loopback routes are present
loopback-to-loopback pings pass
```

The script should finish with:

```text
RESULT: PASS
```

and exit with code:

```text
0
```

## Failure Behavior

If a check fails, the script should clearly show:

```text
which node failed
which check failed
which command was run
what the return code was
```

The script should finish with:

```text
RESULT: FAIL
```

and exit with code:

```text
1
```

## Validation Logic

### Container Check

Check that each expected container exists before running network validation.

Example command:

```bash
docker inspect clab-06-sonic-automation-leaf1
```

### Direct Peer Ping

Use peer IPs from `ip_asn.json`.

Example command:

```bash
docker exec clab-06-sonic-automation-leaf1 ping -c 3 -W 1 10.0.11.0
```

### BGP Summary

Check BGP state with FRR inside SONiC:

```bash
docker exec clab-06-sonic-automation-leaf1 vtysh -c "show ip bgp summary"
```

The first version can check that the command succeeds and that expected neighbor IPs appear in the output.

Later versions can parse neighbor state more strictly.

### BGP Routes

Check learned BGP routes:

```bash
docker exec clab-06-sonic-automation-leaf1 vtysh -c "show ip route bgp"
```

The first version should confirm that remote loopback prefixes appear in the output.

### Loopback-to-Loopback Ping

Use the local loopback as the source IP.

Example:

```bash
docker exec clab-06-sonic-automation-leaf1 ping -I 10.255.0.11 -c 3 -W 1 10.255.0.12
```

This avoids false failures caused by Linux choosing a point-to-point link IP as the ping source.

## Notes

This lab should stay simple.

Avoid adding NetBox, Jinja templates, CI pipelines, or topology generation in the first version.

The first goal is a readable validation checker with reliable PASS/FAIL behavior.
