# Lab 07 Validation - SONiC Underlay Validation Checks

## Purpose

This file summarizes the validation result for Lab 07.

Lab 07 validates the SONiC underlay built in Lab 06 using a Python checker.

The checker reads Lab 06 topology data from:

```text
../06-sonic-automation/ip_asn.json
```

It writes detailed output to:

```text
outputs/check-underlay-summary.md
```

## Lab Dependency

Lab 07 depends on the Lab 06 topology.

Before running this validation, Lab 06 should be deployed and prepared:

```bash
cd ../06-sonic-automation

bash scripts/01-deploy.sh
bash scripts/02-load-configdb.sh
bash scripts/03-prepare-runtime.sh
bash scripts/04-load-bgp.sh
```

Then run Lab 07 validation:

```bash
cd ../07-sonic-validation-checks

python3 scripts/check-underlay.py
```

## Validation Command

The validation was run with:

```bash
python3 scripts/check-underlay.py
```

The script completed with:

```text
Validation summary saved to: /home/yifan/ai_dc_fabric_lab/labs/07-sonic-validation-checks/outputs/check-underlay-summary.md
RESULT: PASS
```

## Summary Result

```text
RESULT: PASS
Passed: 32
Failed: 0
```

## Checks Covered

The checker validated four SONiC VS nodes:

```text
spine1
spine2
leaf1
leaf2
```

For each node, the checker validated:

```text
container existence
direct peer reachability
BGP summary output
BGP route learning
loopback-to-loopback reachability
```

Each node had eight checks:

```text
1 container check
2 direct peer pings
1 BGP summary check
1 BGP route check
3 loopback-to-loopback pings
```

Total:

```text
4 nodes x 8 checks = 32 checks
```

## Direct Peer Reachability

All direct point-to-point peer pings passed.

This confirms that the SONiC VS interfaces, Containerlab veth links, and directly connected `/31` peer addresses were reachable.

Example checks included:

```text
spine1 -> leaf1
spine1 -> leaf2
spine2 -> leaf1
spine2 -> leaf2
leaf1 -> spine1
leaf1 -> spine2
leaf2 -> spine1
leaf2 -> spine2
```

## BGP Summary Checks

The checker ran:

```bash
vtysh -c "show ip bgp summary"
```

on each node.

The script checked that expected peer IPs appeared in the BGP summary output.

All BGP summary checks passed.

## BGP Route Checks

The checker ran:

```bash
vtysh -c "show ip route bgp"
```

on each node.

The script checked that remote loopback `/32` prefixes appeared in the BGP route table.

All BGP route checks passed.

## Loopback-to-Loopback Reachability

The checker tested loopback-to-loopback reachability between all nodes.

It used the local loopback IP as the ping source.

Example:

```bash
docker exec clab-06-sonic-automation-leaf1 ping -I 10.255.0.11 -c 3 -W 1 10.255.0.12
```

This is stronger than a direct peer ping because it validates:

```text
remote loopback route learning
forward path
return path
correct source address behavior
```

All loopback-to-loopback pings passed.

## Exit Code Behavior

The successful run returned:

```text
exit code 0
```

The intended behavior is:

```text
0 = all checks passed
1 = one or more checks failed
```

This makes the checker suitable for future CI-style validation.

## Evidence File

Detailed raw output is saved in:

```text
outputs/check-underlay-summary.md
```

This file contains command output for each validation check.

## Conclusion

Lab 07 successfully converted Lab 06 underlay validation into a repeatable Python-based validation checker.

The validation result passed with:

```text
32 passed
0 failed
```

The lab is ready to commit as the first version of machine-checkable SONiC underlay validation.
