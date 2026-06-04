## Basic checks
```
$ containerlab deploy -t topology.clab.yml 
02:44:20 INFO Containerlab started version=0.75.0
02:44:20 INFO Parsing & checking topology file=topology.clab.yml
02:44:20 INFO Pulling image image=docker.io/library/alpine:latest
latest: Pulling from library/alpine
6a0ac1617861: Pull complete 
Digest: sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11
Status: Downloaded newer image for alpine:latest
02:44:22 INFO Done pulling image image=docker.io/library/alpine:latest
02:44:22 INFO Creating lab directory path=/home/yifan/ai_dc_fabric_lab/labs/01-frr-leaf-spine/clab-frr-leaf-spine
02:44:23 INFO Creating container name=host3
02:44:23 INFO Creating container name=leaf1
02:44:23 INFO Creating container name=leaf3
02:44:23 INFO Creating container name=leaf2
02:44:23 INFO Creating container name=host1
02:44:23 INFO Creating container name=host4
02:44:23 INFO Creating container name=host2
02:44:23 INFO Creating container name=spine1
02:44:23 INFO Creating container name=leaf4
02:44:23 INFO Creating container name=spine2
02:44:28 INFO Created link: leaf3:eth3 ▪┄┄▪ host3:eth1
02:44:29 INFO Created link: leaf1:eth3 ▪┄┄▪ host1:eth1
02:44:29 INFO Created link: spine1:eth1 ▪┄┄▪ leaf1:eth1
02:44:29 INFO Created link: leaf4:eth3 ▪┄┄▪ host4:eth1
02:44:29 INFO Created link: spine1:eth2 ▪┄┄▪ leaf2:eth1
02:44:29 INFO Created link: spine1:eth3 ▪┄┄▪ leaf3:eth1
02:44:29 INFO Created link: spine1:eth4 ▪┄┄▪ leaf4:eth1
02:44:29 INFO Created link: spine2:eth1 ▪┄┄▪ leaf1:eth2
02:44:29 INFO Created link: leaf2:eth3 ▪┄┄▪ host2:eth1
02:44:29 INFO Created link: spine2:eth2 ▪┄┄▪ leaf2:eth2
02:44:29 INFO Created link: spine2:eth3 ▪┄┄▪ leaf3:eth2
02:44:29 INFO Created link: spine2:eth4 ▪┄┄▪ leaf4:eth2
02:44:29 INFO Adding host entries path=/etc/hosts
02:44:29 INFO Adding SSH config for nodes path=/etc/ssh/ssh_config.d/clab-frr-leaf-spine.conf
02:44:29 INFO containerlab version
  🎉=
  │ A newer containerlab version (0.76.0) is available!
  │ Release notes: https://containerlab.dev/rn/0.76/
  │ Run 'clab version upgrade' or see https://containerlab.dev/install/ for other installation options.
╭────────────────────────────┬──────────────────────┬─────────┬───────────────────╮
│            Name            │      Kind/Image      │  State  │   IPv4/6 Address  │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-host1  │ linux                │ running │ 172.20.20.4       │
│                            │ alpine:latest        │         │ 3fff:172:20:20::4 │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-host2  │ linux                │ running │ 172.20.20.13      │
│                            │ alpine:latest        │         │ 3fff:172:20:20::d │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-host3  │ linux                │ running │ 172.20.20.5       │
│                            │ alpine:latest        │         │ 3fff:172:20:20::5 │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-host4  │ linux                │ running │ 172.20.20.7       │
│                            │ alpine:latest        │         │ 3fff:172:20:20::7 │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-leaf1  │ linux                │ running │ 172.20.20.9       │
│                            │ frrouting/frr:latest │         │ 3fff:172:20:20::9 │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-leaf2  │ linux                │ running │ 172.20.20.8       │
│                            │ frrouting/frr:latest │         │ 3fff:172:20:20::8 │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-leaf3  │ linux                │ running │ 172.20.20.6       │
│                            │ frrouting/frr:latest │         │ 3fff:172:20:20::6 │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-leaf4  │ linux                │ running │ 172.20.20.10      │
│                            │ frrouting/frr:latest │         │ 3fff:172:20:20::a │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-spine1 │ linux                │ running │ 172.20.20.11      │
│                            │ frrouting/frr:latest │         │ 3fff:172:20:20::b │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-spine2 │ linux                │ running │ 172.20.20.12      │
│                            │ frrouting/frr:latest │         │ 3fff:172:20:20::c │
╰────────────────────────────┴──────────────────────┴─────────┴───────────────────╯
$ containerlab inspect -t topology.clab.yml 
02:45:02 INFO Parsing & checking topology file=topology.clab.yml
╭────────────────────────────┬──────────────────────┬─────────┬───────────────────╮
│            Name            │      Kind/Image      │  State  │   IPv4/6 Address  │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-host1  │ linux                │ running │ 172.20.20.4       │
│                            │ alpine:latest        │         │ 3fff:172:20:20::4 │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-host2  │ linux                │ running │ 172.20.20.13      │
│                            │ alpine:latest        │         │ 3fff:172:20:20::d │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-host3  │ linux                │ running │ 172.20.20.5       │
│                            │ alpine:latest        │         │ 3fff:172:20:20::5 │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-host4  │ linux                │ running │ 172.20.20.7       │
│                            │ alpine:latest        │         │ 3fff:172:20:20::7 │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-leaf1  │ linux                │ running │ 172.20.20.9       │
│                            │ frrouting/frr:latest │         │ 3fff:172:20:20::9 │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-leaf2  │ linux                │ running │ 172.20.20.8       │
│                            │ frrouting/frr:latest │         │ 3fff:172:20:20::8 │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-leaf3  │ linux                │ running │ 172.20.20.6       │
│                            │ frrouting/frr:latest │         │ 3fff:172:20:20::6 │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-leaf4  │ linux                │ running │ 172.20.20.10      │
│                            │ frrouting/frr:latest │         │ 3fff:172:20:20::a │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-spine1 │ linux                │ running │ 172.20.20.11      │
│                            │ frrouting/frr:latest │         │ 3fff:172:20:20::b │
├────────────────────────────┼──────────────────────┼─────────┼───────────────────┤
│ clab-frr-leaf-spine-spine2 │ linux                │ running │ 172.20.20.12      │
│                            │ frrouting/frr:latest │         │ 3fff:172:20:20::c │
╰────────────────────────────┴──────────────────────┴─────────┴───────────────────╯
$ docker exec -it clab-frr-leaf-spine-spine1 vtysh
% Can't open configuration file /etc/frr/vtysh.conf due to 'No such file or directory'.

Hello, this is FRRouting (version 8.4_git).
Copyright 1996-2005 Kunihiro Ishiguro, et al.

spine1# show version
FRRouting 8.4_git (spine1) on Linux(6.12.86+deb13-amd64).
Copyright 1996-2005 Kunihiro Ishiguro, et al.
configured with:
    '--prefix=/usr' '--sbindir=/usr/lib/frr' '--sysconfdir=/etc/frr' '--libdir=/usr/lib' '--localstatedir=/var/run/frr' '--enable-rpki' '--enable-vtysh' '--enable-multipath=64' '--enable-vty-group=frrvty' '--enable-user=frr' '--enable-group=frr' '--enable-pcre2posix' 'CC=gcc' 'CXX=g++'
spine1# show running-config 
Building configuration...

Current configuration:
!
frr version 8.4_git
frr defaults traditional
hostname spine1
no ipv6 forwarding
!
end
spine1# show ip route
Codes: K - kernel route, C - connected, S - static, R - RIP,
       O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

K>* 0.0.0.0/0 [0/0] via 172.20.20.1, eth0, 00:01:15
C>* 172.20.20.0/24 is directly connected, eth0, 00:01:15
spine1# show bgp summary
bgpd is not running
spine1# 
```