# Alpine Smoke Test

## Purpose

Validate that Docker and Containerlab can deploy a minimal two-node Linux lab.

## Topology

```text
a1 --- c1
```
## Commands and output result

Containerlab deploy and inspect
```
$ containerlab deploy -t alpine-smoke-test.clab.yml 
$ containerlab inspect -t alpine-smoke-test.clab.yml 
02:57:21 INFO Parsing & checking topology file=alpine-smoke-test.clab.yml
╭───────────────────┬───────────────┬─────────┬───────────────────╮
│        Name       │   Kind/Image  │  State  │   IPv4/6 Address  │
├───────────────────┼───────────────┼─────────┼───────────────────┤
│ clab-clab-test-a1 │ linux         │ running │ 172.20.20.3       │
│                   │ alpine:3.18.4 │         │ 3fff:172:20:20::3 │
├───────────────────┼───────────────┼─────────┼───────────────────┤
│ clab-clab-test-c1 │ linux         │ running │ 172.20.20.2       │
│                   │ alpine:3.18.4 │         │ 3fff:172:20:20::2 │
╰───────────────────┴───────────────┴─────────┴───────────────────╯
```
a1 ping c1 from docker
```
$ docker exec -it clab-clab-test-a1 ping clab-clab-test-c1
PING clab-clab-test-c1 (3fff:172:20:20::2): 56 data bytes
64 bytes from 3fff:172:20:20::2: seq=0 ttl=64 time=0.159 ms
64 bytes from 3fff:172:20:20::2: seq=1 ttl=64 time=0.116 ms
64 bytes from 3fff:172:20:20::2: seq=2 ttl=64 time=0.073 ms
64 bytes from 3fff:172:20:20::2: seq=3 ttl=64 time=0.068 ms
64 bytes from 3fff:172:20:20::2: seq=4 ttl=64 time=0.068 ms
^C
--- clab-clab-test-c1 ping statistics ---
5 packets transmitted, 5 packets received, 0% packet loss
round-trip min/avg/max = 0.068/0.096/0.159 ms
```
destroy contianerlab with cleanup(Remove the run time folder)
```
$ containerlab destroy -t alpine-smoke-test.clab.yml --cleanup
```
