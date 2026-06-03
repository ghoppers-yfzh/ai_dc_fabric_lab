# Platform Validation Lab

This directory contains small smoke tests used before starting the real Phase 1 leaf-spine lab.

## Why this exists

Before building a 2-spine / 4-leaf / 4-host fabric, the platform itself must be proven to work. This avoids confusing platform problems with network design problems.

## Tests

### Alpine two-node smoke test

```bash
containerlab deploy -t alpine-smoke-test.clab.yml
containerlab inspect -t alpine-smoke-test.clab.yml
containerlab destroy -t alpine-smoke-test.clab.yml
```

### FRR two-node smoke test

```bash
containerlab deploy -t frr-smoke-test.clab.yml
docker exec -it clab-frr-mini-test-r1 vtysh
containerlab destroy -t frr-smoke-test.clab.yml
```

## Current result

Current platform validation passed on `labvm`.

Do not commit raw `clab-*` runtime directories.
