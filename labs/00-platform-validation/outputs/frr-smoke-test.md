# frr Smoke Test

## Purpose

Validate that Containerlab can deploy FRRouting containers and that `vtysh` works.

## Topology

```text
r1 --- r2
```
## Commands and output result
Containerlab deploy and inspect
```
$ containerlab deploy -t frr-smoke-test.clab.yml 
$ containerlab inspect -t frr-smoke-test.clab.yml 
03:05:19 INFO Parsing & checking topology file=frr-smoke-test.clab.yml
╭────────────────────────┬──────────────────────┬─────────┬───────────────────╮
│          Name          │      Kind/Image      │  State  │   IPv4/6 Address  │
├────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-smoke-test-r1 │ linux                │ running │ 172.20.20.4       │
│                        │ frrouting/frr:latest │         │ 3fff:172:20:20::4 │
├────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-smoke-test-r2 │ linux                │ running │ 172.20.20.5       │
│                        │ frrouting/frr:latest │         │ 3fff:172:20:20::5 │
╰────────────────────────┴──────────────────────┴─────────┴───────────────────╯
```

vtysh command test
```
$ docker exec -it clab-frr-smoke-test-r1 vtysh
% Can't open configuration file /etc/frr/vtysh.conf due to 'No such file or directory'.

Hello, this is FRRouting (version 8.4_git).
Copyright 1996-2005 Kunihiro Ishiguro, et al.

r1# show ip route
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

K>* 0.0.0.0/0 [0/0] via 172.20.20.1, eth0, 00:00:45
C>* 172.20.20.0/24 is directly connected, eth0, 00:00:45
r1# 
```
Cleanup
```
$ containerlab destroy -t frr-smoke-test.clab.yml --cleanup
03:07:48 INFO Parsing & checking topology file=frr-smoke-test.clab.yml
03:07:48 INFO Parsing & checking topology file=frr-smoke-test.clab.yml
03:07:48 INFO Destroying lab name=frr-smoke-test
03:07:49 INFO Removed container name=clab-frr-smoke-test-r1
03:07:49 INFO Removed container name=clab-frr-smoke-test-r2
03:07:49 INFO Removing host entries path=/etc/hosts
03:07:49 INFO Removing SSH config path=/etc/ssh/ssh_config.d/clab-frr-smoke-test.conf
```