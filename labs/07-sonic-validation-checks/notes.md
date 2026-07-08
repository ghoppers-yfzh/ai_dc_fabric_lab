# Lab 07 Notes - SONiC Validation Checks

## Purpose

Lab 07 builds on Lab 06.

Lab 06 created a host-side automation workflow for a SONiC VS leaf-spine underlay. It could deploy the lab, load ConfigDB, prepare runtime state, load BGP configuration, and save validation output.

Lab 07 turns that validation process into a machine-checkable Python script.

The main goal is not to create a new topology. The main goal is to make the existing SONiC underlay validation more structured, repeatable, and suitable for automation.

## What Changed from Lab 06

Lab 06 validation was mainly human-readable.

It printed commands and outputs into a Markdown file.

Lab 07 adds a Python checker that can:

```text
read structured lab data
run validation commands
track PASS/FAIL results
write a Markdown summary
return exit code 0 or 1
```

This is an important automation step because scripts used in CI/CD, pre-change checks, or post-change checks need clear success and failure behavior.

## Source Data

The script uses the Lab 06 source data file:

```text
../06-sonic-automation/ip_asn.json
```

This file describes:

```text
node names
loopback IP addresses
point-to-point link IP addresses
peer names
peer IP addresses
ASNs
```

The checker is data-driven. It does not hardcode every ping command manually.

This is the main design improvement over a basic shell validation script.

## Script

Main script:

```text
scripts/check-underlay.py
```

Default input:

```text
../06-sonic-automation/ip_asn.json
```

Default output:

```text
outputs/check-underlay-summary.md
```

Default containerlab prefix:

```text
clab-06-sonic-automation
```

## Validation Flow

For each node, the script performs the following checks:

```text
container exists
direct peer ping
BGP summary contains expected peers
BGP route table contains remote loopbacks
loopback-to-loopback ping using local loopback source
```

With four nodes, each node has:

```text
1 container check
2 direct peer pings
1 BGP summary check
1 BGP route check
3 loopback-to-loopback pings
```

That gives:

```text
8 checks per node
4 nodes
32 checks total
```

## Important Python Concepts Used

### Type Hints

Example:

```python
def run_command(command: list[str], timeout: int = 20) -> tuple[int, str]:
```

This means:

```text
command should be a list of strings
timeout should be an integer
the function returns a tuple containing an integer and a string
```

The return value is used like this:

```python
rc, output = run_command(["docker", "ps"])
```

`rc` is the command return code.

`output` is the command output.

### subprocess

The script uses `subprocess.run()` to run external commands from Python.

Example command built by the script:

```python
["docker", "exec", container, "ping", "-c", "3", "-W", "1", peer_ip]
```

This is equivalent to running:

```bash
docker exec <container> ping -c 3 -W 1 <peer_ip>
```

The script captures both stdout and stderr, so failures can be written into the Markdown summary.

### JSON Loading

The script uses `json.load()` to read `ip_asn.json`.

This turns JSON into Python lists and dictionaries.

Example:

```python
data = load_json(ip_asn_file)
```

The script then builds a node map:

```python
nodes = node_map(data)
```

This makes it easier to loop through nodes and their parameters.

### pathlib

The script uses `Path` to calculate paths relative to the script location.

This allows the script to find the repo root even when it is run from the lab directory.

Example:

```python
script_dir = Path(__file__).resolve().parent
lab07_dir = script_dir.parent
repo_root = lab07_dir.parent.parent
```

### Result Tracking

Each check is stored in a `results` list.

Each result contains:

```text
passed
name
command
output
```

At the end, the script counts passed and failed checks.

If no check failed, it returns exit code `0`.

If any check failed, it returns exit code `1`.

## Why Loopback Source Matters

Loopback-to-loopback ping uses the local loopback IP as the source.

Example:

```bash
docker exec clab-06-sonic-automation-leaf1 ping -I 10.255.0.11 -c 3 -W 1 10.255.0.12
```

This is important because without a fixed source IP, Linux may choose a point-to-point interface IP as the source.

That can cause misleading failures when return-path routing does not match the chosen source address.

For underlay validation, loopback-to-loopback reachability should prove that:

```text
the local loopback is usable as a source
the remote loopback is reachable
BGP has learned the required remote loopback routes
the return path also works
```

## What This Lab Proves

This lab proves that the existing SONiC VS underlay can be checked by a repeatable Python validation script.

It also proves that the script can produce a clear machine-readable result through exit codes:

```text
0 = PASS
1 = FAIL
```

This is useful for future CI-style validation.

## Current Limitations

The current script is intentionally simple.

It does not yet strictly parse BGP neighbor state.

The BGP summary check currently verifies that expected peer IPs appear in the output.

A stricter version could parse the `State/PfxRcd` column and confirm that each peer is fully established.

The container check currently uses full `docker inspect` output, which is verbose but acceptable for this first version.

## Lessons Learned

- Validation should be data-driven where possible.
- A readable shell script is useful for the first working version.
- Python is better when validation needs structured data, result tracking, and exit codes.
- Loopback-to-loopback validation is stronger than direct interface ping.
- Exit codes make validation useful for automation and CI workflows.
- A useful lab should not only configure the network; it should also prove the expected state.
