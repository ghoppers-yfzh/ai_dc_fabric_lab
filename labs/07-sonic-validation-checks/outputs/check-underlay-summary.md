# Lab 07 SONiC Underlay Check Summary

## Result

RESULT: PASS

- Passed: 32
- Failed: 0

## Checks

### PASS - spine1 container exists

Command:

```bash
docker inspect clab-06-sonic-automation-spine1
```

Output:

```text
[
    {
        "Id": "41ededf11fd8678f913694a8c7972f3aa1dc20e009053156182904084faee01b",
        "Created": "2026-06-30T03:20:40.556018993Z",
        "Path": "/bin/bash",
        "Args": [],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 1803865,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2026-06-30T03:20:42.214017583Z",
            "FinishedAt": "0001-01-01T00:00:00Z"
        },
        "Image": "sha256:e6217fbf8eda7bc2a2f8fca62588234420808bf908ddd97ea5e07a57888fdda3",
        "ResolvConfPath": "/var/lib/docker/containers/41ededf11fd8678f913694a8c7972f3aa1dc20e009053156182904084faee01b/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/41ededf11fd8678f913694a8c7972f3aa1dc20e009053156182904084faee01b/hostname",
        "HostsPath": "/var/lib/docker/containers/41ededf11fd8678f913694a8c7972f3aa1dc20e009053156182904084faee01b/hosts",
        "LogPath": "/var/lib/docker/containers/41ededf11fd8678f913694a8c7972f3aa1dc20e009053156182904084faee01b/41ededf11fd8678f913694a8c7972f3aa1dc20e009053156182904084faee01b-json.log",
        "Name": "/clab-06-sonic-automation-spine1",
        "RestartCount": 0,
        "Driver": "overlay2",
        "Platform": "linux",
        "MountLabel": "",
        "ProcessLabel": "",
        "AppArmorProfile": "unconfined",
        "ExecIDs": [
            "fffe7b4c97bc37119621a18e17b87a83928a161ce81872aee4361c09a61f2fee"
        ],
        "HostConfig": {
            "Binds": [
                "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/configs/common/daemons:/etc/frr/daemons",
                "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/configs/spine1:/sonic/config"
            ],
            "ContainerIDFile": "",
            "LogConfig": {
                "Type": "json-file",
                "Config": {}
            },
            "NetworkMode": "clab",
            "PortBindings": null,
            "RestartPolicy": {
                "Name": "no",
                "MaximumRetryCount": 0
            },
            "AutoRemove": false,
            "VolumeDriver": "",
            "VolumesFrom": null,
            "ConsoleSize": [
                0,
                0
            ],
            "CapAdd": null,
            "CapDrop": null,
            "CgroupnsMode": "private",
            "Dns": [
                "72.249.191.254"
            ],
            "DnsOptions": null,
            "DnsSearch": null,
            "ExtraHosts": [],
            "GroupAdd": null,
            "IpcMode": "private",
            "Cgroup": "",
            "Links": null,
            "OomScoreAdj": 0,
            "PidMode": "",
            "Privileged": true,
            "PublishAllPorts": false,
            "ReadonlyRootfs": false,
            "SecurityOpt": [
                "label=disable"
            ],
            "UTSMode": "",
            "UsernsMode": "",
            "ShmSize": 67108864,
            "Runtime": "runc",
            "Isolation": "",
            "CpuShares": 0,
            "Memory": 0,
            "NanoCpus": 0,
            "CgroupParent": "",
            "BlkioWeight": 0,
            "BlkioWeightDevice": null,
            "BlkioDeviceReadBps": null,
            "BlkioDeviceWriteBps": null,
            "BlkioDeviceReadIOps": null,
            "BlkioDeviceWriteIOps": null,
            "CpuPeriod": 0,
            "CpuQuota": 0,
            "CpuRealtimePeriod": 0,
            "CpuRealtimeRuntime": 0,
            "CpusetCpus": "",
            "CpusetMems": "",
            "Devices": null,
            "DeviceCgroupRules": null,
            "DeviceRequests": null,
            "MemoryReservation": 0,
            "MemorySwap": 0,
            "MemorySwappiness": null,
            "OomKillDisable": null,
            "PidsLimit": null,
            "Ulimits": [
                {
                    "Name": "nofile",
                    "Hard": 524288,
                    "Soft": 524288
                }
            ],
            "CpuCount": 0,
            "CpuPercent": 0,
            "IOMaximumIOps": 0,
            "IOMaximumBandwidth": 0,
            "MaskedPaths": null,
            "ReadonlyPaths": null
        },
        "GraphDriver": {
            "Data": {
                "ID": "41ededf11fd8678f913694a8c7972f3aa1dc20e009053156182904084faee01b",
                "LowerDir": "/var/lib/docker/overlay2/a20d941f63fc1df268e595e1d97aa64f8875d2f973e11703376efce635c97c5f-init/diff:/var/lib/docker/overlay2/0e34ce6926132323ee59d4af1fd83cc5790911a727ac5cb3f255d4484f82fccc/diff:/var/lib/docker/overlay2/a1911de4977251cfcb5e83e43aceb71dfb6301deff7a7085befd91f5da60fe79/diff:/var/lib/docker/overlay2/e26b4f7873e7f674cef6eeced1c63d89c48e842c1517bd77ff0f14fe4a69e171/diff:/var/lib/docker/overlay2/a592f025dd323b3d601b6482002d8d8f90fcffc7266c78ad68f1893f8011be9a/diff:/var/lib/docker/overlay2/a9e7b7d2539dd259497fc4853eb5879b1e03c882c3e0a62a322c9e998988f78d/diff:/var/lib/docker/overlay2/74eb50caf8fdde8b17973ee36747b057c6d18d9076a1b71894f20897533f1478/diff:/var/lib/docker/overlay2/40a4d517d3207161b2f33098e30d882052a0efd19969dfa118b2b42db456dc90/diff:/var/lib/docker/overlay2/2826af6ab6b91bc62a49ed3c39860d40a905eab4689f9f3a355215707e9014bd/diff",
                "MergedDir": "/var/lib/docker/overlay2/a20d941f63fc1df268e595e1d97aa64f8875d2f973e11703376efce635c97c5f/merged",
                "UpperDir": "/var/lib/docker/overlay2/a20d941f63fc1df268e595e1d97aa64f8875d2f973e11703376efce635c97c5f/diff",
                "WorkDir": "/var/lib/docker/overlay2/a20d941f63fc1df268e595e1d97aa64f8875d2f973e11703376efce635c97c5f/work"
            },
            "Name": "overlay2"
        },
        "Mounts": [
            {
                "Type": "bind",
                "Source": "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/configs/common/daemons",
                "Destination": "/etc/frr/daemons",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            },
            {
                "Type": "bind",
                "Source": "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/configs/spine1",
                "Destination": "/sonic/config",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            }
        ],
        "Config": {
            "Hostname": "spine1",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": true,
            "AttachStderr": true,
            "Tty": true,
            "OpenStdin": true,
            "StdinOnce": false,
            "Env": [
                "CLAB_LABEL_CLAB_NODE_TYPE=",
                "CLAB_LABEL_CLAB_NODE_LAB_DIR=/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/clab-06-sonic-automation/spine1",
                "CLAB_LABEL_CLAB_NODE_NAME=spine1",
                "CLAB_LABEL_CLAB_TOPO_FILE=/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/topology.clab.yml",
                "CLAB_LABEL_CLAB_OWNER=yifan",
                "CLAB_LABEL_CLAB_NODE_LONGNAME=clab-06-sonic-automation-spine1",
                "CLAB_INTFS=2",
                "no_proxy=localhost,127.0.0.1,::1,*.local,172.20.20.0/24,3fff:172:20:20::/64,leaf1,leaf2,spine1,spine2",
                "NO_PROXY=localhost,127.0.0.1,::1,*.local,172.20.20.0/24,3fff:172:20:20::/64,leaf1,leaf2,spine1,spine2",
                "CLAB_LABEL_CLAB_NODE_KIND=sonic-vs",
                "CLAB_LABEL_CLAB_NODE_GROUP=",
                "CLAB_LABEL_CONTAINERLAB=06-sonic-automation",
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "PLATFORM=x86_64-kvm_x86_64-r0",
                "HWSKU=Force10-S6000"
            ],
            "Cmd": [],
            "Image": "docker-sonic-vs:latest",
            "Volumes": null,
            "WorkingDir": "/",
            "Entrypoint": [
                "/bin/bash"
            ],
            "OnBuild": null,
            "Labels": {
                "Tag": "202511.1137676-97a82c196",
                "clab-mgmt-net-bridge": "br-9fe0426c937b",
                "clab-node-group": "",
                "clab-node-kind": "sonic-vs",
                "clab-node-lab-dir": "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/clab-06-sonic-automation/spine1",
                "clab-node-longname": "clab-06-sonic-automation-spine1",
                "clab-node-name": "spine1",
                "clab-node-type": "",
                "clab-owner": "yifan",
                "clab-topo-file": "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/topology.clab.yml",
                "com.azure.sonic.manifest": "\n{\n    \"version\": \"1.0.0\",\n    \"package\": {\n        \"version\": \"\",\n        \"depends\": [],\n        \"name\": \"\"\n    },\n    \"service\": {\n        \"name\": \"\",\n        \"requires\": [],\n        \"after\": [],\n        \"before\": [],\n        \"dependent-of\": [],\n        \"asic-service\": false,\n        \"host-service\": false,\n        \"warm-shutdown\": {\n            \"after\": [],\n            \"before\": []\n        },\n        \"fast-shutdown\": {\n            \"after\": [],\n            \"before\": []\n        },\n        \"syslog\": {\n            \"support-rate-limit\": true\n        }\n    },\n    \"container\": {\n        \"privileged\": false,\n        \"volumes\": [],\n        \"tmpfs\": []\n    },\n    \"cli\": {\n        \"config\": \"\",\n        \"show\": \"\",\n        \"clear\": \"\"\n    }\n}",
                "com.azure.sonic.versions.libsairedis": "1.0.0",
                "com.azure.sonic.versions.libswsscommon": "1.0.0",
                "com.azure.sonic.versions.sonic-supervisord-utilities-rs": "1.0.0",
                "com.azure.sonic.versions.sonic_utilities": "1.2",
                "containerlab": "06-sonic-automation"
            }
        },
        "NetworkSettings": {
            "Bridge": "",
            "SandboxID": "f087ec1bf21de0c7838714c1cf6a6c64b054db4b69679e9fc243c2ab0a2f175b",
            "SandboxKey": "/var/run/docker/netns/f087ec1bf21d",
            "Ports": {},
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "",
            "Gateway": "",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "",
            "IPPrefixLen": 0,
            "IPv6Gateway": "",
            "MacAddress": "",
            "Networks": {
                "clab": {
                    "IPAMConfig": {},
                    "Links": null,
                    "Aliases": null,
                    "MacAddress": "e2:d5:48:52:c4:01",
                    "DriverOpts": null,
                    "GwPriority": 0,
                    "NetworkID": "9fe0426c937b93edcfa82c7a191011c534082672577800052a3603a0788dc28c",
                    "EndpointID": "0e8a675d8b522e70874b9abb9db094defa2487f88ea5e014067acac2345eb832",
                    "Gateway": "172.20.20.1",
                    "IPAddress": "172.20.20.5",
                    "IPPrefixLen": 24,
                    "IPv6Gateway": "3fff:172:20:20::1",
                    "GlobalIPv6Address": "3fff:172:20:20::5",
                    "GlobalIPv6PrefixLen": 64,
                    "DNSNames": [
                        "clab-06-sonic-automation-spine1",
                        "41ededf11fd8",
                        "spine1"
                    ]
                }
            }
        }
    }
]
```

### PASS - spine1 -> leaf1 direct peer ping (10.0.11.1)

Command:

```bash
docker exec clab-06-sonic-automation-spine1 ping -c 3 -W 1 10.0.11.1
```

Output:

```text
PING 10.0.11.1 (10.0.11.1) 56(84) bytes of data.
64 bytes from 10.0.11.1: icmp_seq=1 ttl=64 time=0.365 ms
64 bytes from 10.0.11.1: icmp_seq=2 ttl=64 time=0.330 ms
64 bytes from 10.0.11.1: icmp_seq=3 ttl=64 time=0.330 ms

--- 10.0.11.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2048ms
rtt min/avg/max/mdev = 0.330/0.341/0.365/0.016 ms
```

### PASS - spine1 -> leaf2 direct peer ping (10.0.21.1)

Command:

```bash
docker exec clab-06-sonic-automation-spine1 ping -c 3 -W 1 10.0.21.1
```

Output:

```text
PING 10.0.21.1 (10.0.21.1) 56(84) bytes of data.
64 bytes from 10.0.21.1: icmp_seq=1 ttl=64 time=0.359 ms
64 bytes from 10.0.21.1: icmp_seq=2 ttl=64 time=0.315 ms
64 bytes from 10.0.21.1: icmp_seq=3 ttl=64 time=0.343 ms

--- 10.0.21.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2048ms
rtt min/avg/max/mdev = 0.315/0.339/0.359/0.018 ms
```

### PASS - spine1 BGP summary contains expected peers

Command:

```bash
docker exec clab-06-sonic-automation-spine1 vtysh -c show ip bgp summary
```

Output:

```text
IPv4 Unicast Summary:
BGP router identifier 10.255.0.1, local AS number 65001 VRF default vrf-id 0
BGP table version 4
RIB entries 7, using 896 bytes of memory
Peers 2, using 47 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.11.1       4      65101         7         8        4    0    0 00:00:22            2        4 N/A
10.0.21.1       4      65102         7         8        4    0    0 00:00:22            2        4 N/A

Total number of neighbors 2
```

### PASS - spine1 BGP routes contain remote loopbacks

Command:

```bash
docker exec clab-06-sonic-automation-spine1 vtysh -c show ip route bgp
```

Output:

```text
Codes: K - kernel route, C - connected, L - local, S - static,
       R - RIP, O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric, t - Table-Direct,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

IPv4 unicast VRF default:
B>* 10.255.0.2/32 [20/0] via 10.0.11.1, Ethernet0, weight 1, 00:00:20
B>* 10.255.0.11/32 [20/0] via 10.0.11.1, Ethernet0, weight 1, 00:00:20
B>* 10.255.0.12/32 [20/0] via 10.0.21.1, Ethernet4, weight 1, 00:00:20
```

### PASS - spine1 (10.255.0.1) -> spine2 loopback (10.255.0.2)

Command:

```bash
docker exec clab-06-sonic-automation-spine1 ping -I 10.255.0.1 -c 3 -W 1 10.255.0.2
```

Output:

```text
PING 10.255.0.2 (10.255.0.2) from 10.255.0.1 : 56(84) bytes of data.
64 bytes from 10.255.0.2: icmp_seq=1 ttl=63 time=0.522 ms
64 bytes from 10.255.0.2: icmp_seq=2 ttl=63 time=0.493 ms
64 bytes from 10.255.0.2: icmp_seq=3 ttl=63 time=0.413 ms

--- 10.255.0.2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2025ms
rtt min/avg/max/mdev = 0.413/0.476/0.522/0.046 ms
```

### PASS - spine1 (10.255.0.1) -> leaf1 loopback (10.255.0.11)

Command:

```bash
docker exec clab-06-sonic-automation-spine1 ping -I 10.255.0.1 -c 3 -W 1 10.255.0.11
```

Output:

```text
PING 10.255.0.11 (10.255.0.11) from 10.255.0.1 : 56(84) bytes of data.
64 bytes from 10.255.0.11: icmp_seq=1 ttl=64 time=0.320 ms
64 bytes from 10.255.0.11: icmp_seq=2 ttl=64 time=0.273 ms
64 bytes from 10.255.0.11: icmp_seq=3 ttl=64 time=0.280 ms

--- 10.255.0.11 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2040ms
rtt min/avg/max/mdev = 0.273/0.291/0.320/0.020 ms
```

### PASS - spine1 (10.255.0.1) -> leaf2 loopback (10.255.0.12)

Command:

```bash
docker exec clab-06-sonic-automation-spine1 ping -I 10.255.0.1 -c 3 -W 1 10.255.0.12
```

Output:

```text
PING 10.255.0.12 (10.255.0.12) from 10.255.0.1 : 56(84) bytes of data.
64 bytes from 10.255.0.12: icmp_seq=1 ttl=64 time=0.382 ms
64 bytes from 10.255.0.12: icmp_seq=2 ttl=64 time=0.283 ms
64 bytes from 10.255.0.12: icmp_seq=3 ttl=64 time=0.309 ms

--- 10.255.0.12 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2030ms
rtt min/avg/max/mdev = 0.283/0.324/0.382/0.041 ms
```

### PASS - spine2 container exists

Command:

```bash
docker inspect clab-06-sonic-automation-spine2
```

Output:

```text
[
    {
        "Id": "a854b3f9bd998f02399f62e5f26fbd5b2230b7a6fc142954a0e4f8ad28bd43d3",
        "Created": "2026-06-30T03:20:40.556320943Z",
        "Path": "/bin/bash",
        "Args": [],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 1803774,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2026-06-30T03:20:42.11421731Z",
            "FinishedAt": "0001-01-01T00:00:00Z"
        },
        "Image": "sha256:e6217fbf8eda7bc2a2f8fca62588234420808bf908ddd97ea5e07a57888fdda3",
        "ResolvConfPath": "/var/lib/docker/containers/a854b3f9bd998f02399f62e5f26fbd5b2230b7a6fc142954a0e4f8ad28bd43d3/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/a854b3f9bd998f02399f62e5f26fbd5b2230b7a6fc142954a0e4f8ad28bd43d3/hostname",
        "HostsPath": "/var/lib/docker/containers/a854b3f9bd998f02399f62e5f26fbd5b2230b7a6fc142954a0e4f8ad28bd43d3/hosts",
        "LogPath": "/var/lib/docker/containers/a854b3f9bd998f02399f62e5f26fbd5b2230b7a6fc142954a0e4f8ad28bd43d3/a854b3f9bd998f02399f62e5f26fbd5b2230b7a6fc142954a0e4f8ad28bd43d3-json.log",
        "Name": "/clab-06-sonic-automation-spine2",
        "RestartCount": 0,
        "Driver": "overlay2",
        "Platform": "linux",
        "MountLabel": "",
        "ProcessLabel": "",
        "AppArmorProfile": "unconfined",
        "ExecIDs": [
            "4c0d1478894046c5e5dac68e920c444c9a2d878f3b6df305303a9cfd5b9c0fae"
        ],
        "HostConfig": {
            "Binds": [
                "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/configs/common/daemons:/etc/frr/daemons",
                "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/configs/spine2:/sonic/config"
            ],
            "ContainerIDFile": "",
            "LogConfig": {
                "Type": "json-file",
                "Config": {}
            },
            "NetworkMode": "clab",
            "PortBindings": null,
            "RestartPolicy": {
                "Name": "no",
                "MaximumRetryCount": 0
            },
            "AutoRemove": false,
            "VolumeDriver": "",
            "VolumesFrom": null,
            "ConsoleSize": [
                0,
                0
            ],
            "CapAdd": null,
            "CapDrop": null,
            "CgroupnsMode": "private",
            "Dns": [
                "72.249.191.254"
            ],
            "DnsOptions": null,
            "DnsSearch": null,
            "ExtraHosts": [],
            "GroupAdd": null,
            "IpcMode": "private",
            "Cgroup": "",
            "Links": null,
            "OomScoreAdj": 0,
            "PidMode": "",
            "Privileged": true,
            "PublishAllPorts": false,
            "ReadonlyRootfs": false,
            "SecurityOpt": [
                "label=disable"
            ],
            "UTSMode": "",
            "UsernsMode": "",
            "ShmSize": 67108864,
            "Runtime": "runc",
            "Isolation": "",
            "CpuShares": 0,
            "Memory": 0,
            "NanoCpus": 0,
            "CgroupParent": "",
            "BlkioWeight": 0,
            "BlkioWeightDevice": null,
            "BlkioDeviceReadBps": null,
            "BlkioDeviceWriteBps": null,
            "BlkioDeviceReadIOps": null,
            "BlkioDeviceWriteIOps": null,
            "CpuPeriod": 0,
            "CpuQuota": 0,
            "CpuRealtimePeriod": 0,
            "CpuRealtimeRuntime": 0,
            "CpusetCpus": "",
            "CpusetMems": "",
            "Devices": null,
            "DeviceCgroupRules": null,
            "DeviceRequests": null,
            "MemoryReservation": 0,
            "MemorySwap": 0,
            "MemorySwappiness": null,
            "OomKillDisable": null,
            "PidsLimit": null,
            "Ulimits": [
                {
                    "Name": "nofile",
                    "Hard": 524288,
                    "Soft": 524288
                }
            ],
            "CpuCount": 0,
            "CpuPercent": 0,
            "IOMaximumIOps": 0,
            "IOMaximumBandwidth": 0,
            "MaskedPaths": null,
            "ReadonlyPaths": null
        },
        "GraphDriver": {
            "Data": {
                "ID": "a854b3f9bd998f02399f62e5f26fbd5b2230b7a6fc142954a0e4f8ad28bd43d3",
                "LowerDir": "/var/lib/docker/overlay2/14d4e62d54390d9ec68ccf0c704656bca73c3b287f6840018d2d8535ad984259-init/diff:/var/lib/docker/overlay2/0e34ce6926132323ee59d4af1fd83cc5790911a727ac5cb3f255d4484f82fccc/diff:/var/lib/docker/overlay2/a1911de4977251cfcb5e83e43aceb71dfb6301deff7a7085befd91f5da60fe79/diff:/var/lib/docker/overlay2/e26b4f7873e7f674cef6eeced1c63d89c48e842c1517bd77ff0f14fe4a69e171/diff:/var/lib/docker/overlay2/a592f025dd323b3d601b6482002d8d8f90fcffc7266c78ad68f1893f8011be9a/diff:/var/lib/docker/overlay2/a9e7b7d2539dd259497fc4853eb5879b1e03c882c3e0a62a322c9e998988f78d/diff:/var/lib/docker/overlay2/74eb50caf8fdde8b17973ee36747b057c6d18d9076a1b71894f20897533f1478/diff:/var/lib/docker/overlay2/40a4d517d3207161b2f33098e30d882052a0efd19969dfa118b2b42db456dc90/diff:/var/lib/docker/overlay2/2826af6ab6b91bc62a49ed3c39860d40a905eab4689f9f3a355215707e9014bd/diff",
                "MergedDir": "/var/lib/docker/overlay2/14d4e62d54390d9ec68ccf0c704656bca73c3b287f6840018d2d8535ad984259/merged",
                "UpperDir": "/var/lib/docker/overlay2/14d4e62d54390d9ec68ccf0c704656bca73c3b287f6840018d2d8535ad984259/diff",
                "WorkDir": "/var/lib/docker/overlay2/14d4e62d54390d9ec68ccf0c704656bca73c3b287f6840018d2d8535ad984259/work"
            },
            "Name": "overlay2"
        },
        "Mounts": [
            {
                "Type": "bind",
                "Source": "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/configs/common/daemons",
                "Destination": "/etc/frr/daemons",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            },
            {
                "Type": "bind",
                "Source": "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/configs/spine2",
                "Destination": "/sonic/config",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            }
        ],
        "Config": {
            "Hostname": "spine2",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": true,
            "AttachStderr": true,
            "Tty": true,
            "OpenStdin": true,
            "StdinOnce": false,
            "Env": [
                "no_proxy=localhost,127.0.0.1,::1,*.local,172.20.20.0/24,3fff:172:20:20::/64,leaf1,leaf2,spine1,spine2",
                "CLAB_LABEL_CLAB_NODE_GROUP=",
                "CLAB_LABEL_CONTAINERLAB=06-sonic-automation",
                "CLAB_LABEL_CLAB_NODE_LONGNAME=clab-06-sonic-automation-spine2",
                "CLAB_INTFS=2",
                "NO_PROXY=localhost,127.0.0.1,::1,*.local,172.20.20.0/24,3fff:172:20:20::/64,leaf1,leaf2,spine1,spine2",
                "CLAB_LABEL_CLAB_NODE_LAB_DIR=/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/clab-06-sonic-automation/spine2",
                "CLAB_LABEL_CLAB_TOPO_FILE=/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/topology.clab.yml",
                "CLAB_LABEL_CLAB_OWNER=yifan",
                "CLAB_LABEL_CLAB_NODE_NAME=spine2",
                "CLAB_LABEL_CLAB_NODE_KIND=sonic-vs",
                "CLAB_LABEL_CLAB_NODE_TYPE=",
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "PLATFORM=x86_64-kvm_x86_64-r0",
                "HWSKU=Force10-S6000"
            ],
            "Cmd": [],
            "Image": "docker-sonic-vs:latest",
            "Volumes": null,
            "WorkingDir": "/",
            "Entrypoint": [
                "/bin/bash"
            ],
            "OnBuild": null,
            "Labels": {
                "Tag": "202511.1137676-97a82c196",
                "clab-mgmt-net-bridge": "br-9fe0426c937b",
                "clab-node-group": "",
                "clab-node-kind": "sonic-vs",
                "clab-node-lab-dir": "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/clab-06-sonic-automation/spine2",
                "clab-node-longname": "clab-06-sonic-automation-spine2",
                "clab-node-name": "spine2",
                "clab-node-type": "",
                "clab-owner": "yifan",
                "clab-topo-file": "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/topology.clab.yml",
                "com.azure.sonic.manifest": "\n{\n    \"version\": \"1.0.0\",\n    \"package\": {\n        \"version\": \"\",\n        \"depends\": [],\n        \"name\": \"\"\n    },\n    \"service\": {\n        \"name\": \"\",\n        \"requires\": [],\n        \"after\": [],\n        \"before\": [],\n        \"dependent-of\": [],\n        \"asic-service\": false,\n        \"host-service\": false,\n        \"warm-shutdown\": {\n            \"after\": [],\n            \"before\": []\n        },\n        \"fast-shutdown\": {\n            \"after\": [],\n            \"before\": []\n        },\n        \"syslog\": {\n            \"support-rate-limit\": true\n        }\n    },\n    \"container\": {\n        \"privileged\": false,\n        \"volumes\": [],\n        \"tmpfs\": []\n    },\n    \"cli\": {\n        \"config\": \"\",\n        \"show\": \"\",\n        \"clear\": \"\"\n    }\n}",
                "com.azure.sonic.versions.libsairedis": "1.0.0",
                "com.azure.sonic.versions.libswsscommon": "1.0.0",
                "com.azure.sonic.versions.sonic-supervisord-utilities-rs": "1.0.0",
                "com.azure.sonic.versions.sonic_utilities": "1.2",
                "containerlab": "06-sonic-automation"
            }
        },
        "NetworkSettings": {
            "Bridge": "",
            "SandboxID": "da65322d7b1c5b6dae0925d157ffd798135cf6664efdf8d01ff89c8611fb211c",
            "SandboxKey": "/var/run/docker/netns/da65322d7b1c",
            "Ports": {},
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "",
            "Gateway": "",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "",
            "IPPrefixLen": 0,
            "IPv6Gateway": "",
            "MacAddress": "",
            "Networks": {
                "clab": {
                    "IPAMConfig": {},
                    "Links": null,
                    "Aliases": null,
                    "MacAddress": "96:4e:79:07:08:b7",
                    "DriverOpts": null,
                    "GwPriority": 0,
                    "NetworkID": "9fe0426c937b93edcfa82c7a191011c534082672577800052a3603a0788dc28c",
                    "EndpointID": "d8781f25a48aa02ce9c5dc455388e9d7c9c98654f42b9de00ca26675c227a39f",
                    "Gateway": "172.20.20.1",
                    "IPAddress": "172.20.20.2",
                    "IPPrefixLen": 24,
                    "IPv6Gateway": "3fff:172:20:20::1",
                    "GlobalIPv6Address": "3fff:172:20:20::2",
                    "GlobalIPv6PrefixLen": 64,
                    "DNSNames": [
                        "clab-06-sonic-automation-spine2",
                        "a854b3f9bd99",
                        "spine2"
                    ]
                }
            }
        }
    }
]
```

### PASS - spine2 -> leaf1 direct peer ping (10.0.12.1)

Command:

```bash
docker exec clab-06-sonic-automation-spine2 ping -c 3 -W 1 10.0.12.1
```

Output:

```text
PING 10.0.12.1 (10.0.12.1) 56(84) bytes of data.
64 bytes from 10.0.12.1: icmp_seq=1 ttl=64 time=0.449 ms
64 bytes from 10.0.12.1: icmp_seq=2 ttl=64 time=0.365 ms
64 bytes from 10.0.12.1: icmp_seq=3 ttl=64 time=0.396 ms

--- 10.0.12.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2034ms
rtt min/avg/max/mdev = 0.365/0.403/0.449/0.034 ms
```

### PASS - spine2 -> leaf2 direct peer ping (10.0.22.1)

Command:

```bash
docker exec clab-06-sonic-automation-spine2 ping -c 3 -W 1 10.0.22.1
```

Output:

```text
PING 10.0.22.1 (10.0.22.1) 56(84) bytes of data.
64 bytes from 10.0.22.1: icmp_seq=1 ttl=64 time=0.369 ms
64 bytes from 10.0.22.1: icmp_seq=2 ttl=64 time=0.295 ms
64 bytes from 10.0.22.1: icmp_seq=3 ttl=64 time=0.314 ms

--- 10.0.22.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2029ms
rtt min/avg/max/mdev = 0.295/0.326/0.369/0.031 ms
```

### PASS - spine2 BGP summary contains expected peers

Command:

```bash
docker exec clab-06-sonic-automation-spine2 vtysh -c show ip bgp summary
```

Output:

```text
IPv4 Unicast Summary:
BGP router identifier 10.255.0.2, local AS number 65002 VRF default vrf-id 0
BGP table version 4
RIB entries 7, using 896 bytes of memory
Peers 2, using 47 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.12.1       4      65101         7         8        4    0    0 00:00:33            3        4 N/A
10.0.22.1       4      65102         7         8        4    0    0 00:00:33            3        4 N/A

Total number of neighbors 2
```

### PASS - spine2 BGP routes contain remote loopbacks

Command:

```bash
docker exec clab-06-sonic-automation-spine2 vtysh -c show ip route bgp
```

Output:

```text
Codes: K - kernel route, C - connected, L - local, S - static,
       R - RIP, O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric, t - Table-Direct,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

IPv4 unicast VRF default:
B>* 10.255.0.1/32 [20/0] via 10.0.12.1, Ethernet0, weight 1, 00:00:31
B>* 10.255.0.11/32 [20/0] via 10.0.12.1, Ethernet0, weight 1, 00:00:31
B>* 10.255.0.12/32 [20/0] via 10.0.22.1, Ethernet4, weight 1, 00:00:31
```

### PASS - spine2 (10.255.0.2) -> spine1 loopback (10.255.0.1)

Command:

```bash
docker exec clab-06-sonic-automation-spine2 ping -I 10.255.0.2 -c 3 -W 1 10.255.0.1
```

Output:

```text
PING 10.255.0.1 (10.255.0.1) from 10.255.0.2 : 56(84) bytes of data.
64 bytes from 10.255.0.1: icmp_seq=1 ttl=63 time=0.572 ms
64 bytes from 10.255.0.1: icmp_seq=2 ttl=63 time=0.607 ms
64 bytes from 10.255.0.1: icmp_seq=3 ttl=63 time=0.576 ms

--- 10.255.0.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2042ms
rtt min/avg/max/mdev = 0.572/0.585/0.607/0.015 ms
```

### PASS - spine2 (10.255.0.2) -> leaf1 loopback (10.255.0.11)

Command:

```bash
docker exec clab-06-sonic-automation-spine2 ping -I 10.255.0.2 -c 3 -W 1 10.255.0.11
```

Output:

```text
PING 10.255.0.11 (10.255.0.11) from 10.255.0.2 : 56(84) bytes of data.
64 bytes from 10.255.0.11: icmp_seq=1 ttl=64 time=0.407 ms
64 bytes from 10.255.0.11: icmp_seq=2 ttl=64 time=0.349 ms
64 bytes from 10.255.0.11: icmp_seq=3 ttl=64 time=0.342 ms

--- 10.255.0.11 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2029ms
rtt min/avg/max/mdev = 0.342/0.366/0.407/0.029 ms
```

### PASS - spine2 (10.255.0.2) -> leaf2 loopback (10.255.0.12)

Command:

```bash
docker exec clab-06-sonic-automation-spine2 ping -I 10.255.0.2 -c 3 -W 1 10.255.0.12
```

Output:

```text
PING 10.255.0.12 (10.255.0.12) from 10.255.0.2 : 56(84) bytes of data.
64 bytes from 10.255.0.12: icmp_seq=1 ttl=64 time=0.423 ms
64 bytes from 10.255.0.12: icmp_seq=2 ttl=64 time=0.356 ms
64 bytes from 10.255.0.12: icmp_seq=3 ttl=64 time=0.266 ms

--- 10.255.0.12 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2005ms
rtt min/avg/max/mdev = 0.266/0.348/0.423/0.064 ms
```

### PASS - leaf1 container exists

Command:

```bash
docker inspect clab-06-sonic-automation-leaf1
```

Output:

```text
[
    {
        "Id": "f91781576063268dfd604faf79c4a6d535d49c94521d0d5b456b75db545395ac",
        "Created": "2026-06-30T03:20:40.556891315Z",
        "Path": "/bin/bash",
        "Args": [],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 1803779,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2026-06-30T03:20:42.155912826Z",
            "FinishedAt": "0001-01-01T00:00:00Z"
        },
        "Image": "sha256:e6217fbf8eda7bc2a2f8fca62588234420808bf908ddd97ea5e07a57888fdda3",
        "ResolvConfPath": "/var/lib/docker/containers/f91781576063268dfd604faf79c4a6d535d49c94521d0d5b456b75db545395ac/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/f91781576063268dfd604faf79c4a6d535d49c94521d0d5b456b75db545395ac/hostname",
        "HostsPath": "/var/lib/docker/containers/f91781576063268dfd604faf79c4a6d535d49c94521d0d5b456b75db545395ac/hosts",
        "LogPath": "/var/lib/docker/containers/f91781576063268dfd604faf79c4a6d535d49c94521d0d5b456b75db545395ac/f91781576063268dfd604faf79c4a6d535d49c94521d0d5b456b75db545395ac-json.log",
        "Name": "/clab-06-sonic-automation-leaf1",
        "RestartCount": 0,
        "Driver": "overlay2",
        "Platform": "linux",
        "MountLabel": "",
        "ProcessLabel": "",
        "AppArmorProfile": "unconfined",
        "ExecIDs": [
            "19c81df04ed0ed5eba1899fc340325790c329b5de379a2153c3b06ee459722f3"
        ],
        "HostConfig": {
            "Binds": [
                "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/configs/common/daemons:/etc/frr/daemons",
                "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/configs/leaf1:/sonic/config"
            ],
            "ContainerIDFile": "",
            "LogConfig": {
                "Type": "json-file",
                "Config": {}
            },
            "NetworkMode": "clab",
            "PortBindings": null,
            "RestartPolicy": {
                "Name": "no",
                "MaximumRetryCount": 0
            },
            "AutoRemove": false,
            "VolumeDriver": "",
            "VolumesFrom": null,
            "ConsoleSize": [
                0,
                0
            ],
            "CapAdd": null,
            "CapDrop": null,
            "CgroupnsMode": "private",
            "Dns": [
                "72.249.191.254"
            ],
            "DnsOptions": null,
            "DnsSearch": null,
            "ExtraHosts": [],
            "GroupAdd": null,
            "IpcMode": "private",
            "Cgroup": "",
            "Links": null,
            "OomScoreAdj": 0,
            "PidMode": "",
            "Privileged": true,
            "PublishAllPorts": false,
            "ReadonlyRootfs": false,
            "SecurityOpt": [
                "label=disable"
            ],
            "UTSMode": "",
            "UsernsMode": "",
            "ShmSize": 67108864,
            "Runtime": "runc",
            "Isolation": "",
            "CpuShares": 0,
            "Memory": 0,
            "NanoCpus": 0,
            "CgroupParent": "",
            "BlkioWeight": 0,
            "BlkioWeightDevice": null,
            "BlkioDeviceReadBps": null,
            "BlkioDeviceWriteBps": null,
            "BlkioDeviceReadIOps": null,
            "BlkioDeviceWriteIOps": null,
            "CpuPeriod": 0,
            "CpuQuota": 0,
            "CpuRealtimePeriod": 0,
            "CpuRealtimeRuntime": 0,
            "CpusetCpus": "",
            "CpusetMems": "",
            "Devices": null,
            "DeviceCgroupRules": null,
            "DeviceRequests": null,
            "MemoryReservation": 0,
            "MemorySwap": 0,
            "MemorySwappiness": null,
            "OomKillDisable": null,
            "PidsLimit": null,
            "Ulimits": [
                {
                    "Name": "nofile",
                    "Hard": 524288,
                    "Soft": 524288
                }
            ],
            "CpuCount": 0,
            "CpuPercent": 0,
            "IOMaximumIOps": 0,
            "IOMaximumBandwidth": 0,
            "MaskedPaths": null,
            "ReadonlyPaths": null
        },
        "GraphDriver": {
            "Data": {
                "ID": "f91781576063268dfd604faf79c4a6d535d49c94521d0d5b456b75db545395ac",
                "LowerDir": "/var/lib/docker/overlay2/f7140b82884e8246b76a3ff2e541d431e15b656fc825d66effe2fb721a64ec5e-init/diff:/var/lib/docker/overlay2/0e34ce6926132323ee59d4af1fd83cc5790911a727ac5cb3f255d4484f82fccc/diff:/var/lib/docker/overlay2/a1911de4977251cfcb5e83e43aceb71dfb6301deff7a7085befd91f5da60fe79/diff:/var/lib/docker/overlay2/e26b4f7873e7f674cef6eeced1c63d89c48e842c1517bd77ff0f14fe4a69e171/diff:/var/lib/docker/overlay2/a592f025dd323b3d601b6482002d8d8f90fcffc7266c78ad68f1893f8011be9a/diff:/var/lib/docker/overlay2/a9e7b7d2539dd259497fc4853eb5879b1e03c882c3e0a62a322c9e998988f78d/diff:/var/lib/docker/overlay2/74eb50caf8fdde8b17973ee36747b057c6d18d9076a1b71894f20897533f1478/diff:/var/lib/docker/overlay2/40a4d517d3207161b2f33098e30d882052a0efd19969dfa118b2b42db456dc90/diff:/var/lib/docker/overlay2/2826af6ab6b91bc62a49ed3c39860d40a905eab4689f9f3a355215707e9014bd/diff",
                "MergedDir": "/var/lib/docker/overlay2/f7140b82884e8246b76a3ff2e541d431e15b656fc825d66effe2fb721a64ec5e/merged",
                "UpperDir": "/var/lib/docker/overlay2/f7140b82884e8246b76a3ff2e541d431e15b656fc825d66effe2fb721a64ec5e/diff",
                "WorkDir": "/var/lib/docker/overlay2/f7140b82884e8246b76a3ff2e541d431e15b656fc825d66effe2fb721a64ec5e/work"
            },
            "Name": "overlay2"
        },
        "Mounts": [
            {
                "Type": "bind",
                "Source": "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/configs/common/daemons",
                "Destination": "/etc/frr/daemons",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            },
            {
                "Type": "bind",
                "Source": "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/configs/leaf1",
                "Destination": "/sonic/config",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            }
        ],
        "Config": {
            "Hostname": "leaf1",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": true,
            "AttachStderr": true,
            "Tty": true,
            "OpenStdin": true,
            "StdinOnce": false,
            "Env": [
                "CLAB_LABEL_CLAB_NODE_LAB_DIR=/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/clab-06-sonic-automation/leaf1",
                "CLAB_LABEL_CLAB_NODE_LONGNAME=clab-06-sonic-automation-leaf1",
                "CLAB_LABEL_CLAB_NODE_TYPE=",
                "CLAB_INTFS=2",
                "no_proxy=localhost,127.0.0.1,::1,*.local,172.20.20.0/24,3fff:172:20:20::/64,leaf1,leaf2,spine1,spine2",
                "CLAB_LABEL_CLAB_NODE_GROUP=",
                "CLAB_LABEL_CONTAINERLAB=06-sonic-automation",
                "CLAB_LABEL_CLAB_NODE_NAME=leaf1",
                "CLAB_LABEL_CLAB_NODE_KIND=sonic-vs",
                "CLAB_LABEL_CLAB_TOPO_FILE=/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/topology.clab.yml",
                "CLAB_LABEL_CLAB_OWNER=yifan",
                "NO_PROXY=localhost,127.0.0.1,::1,*.local,172.20.20.0/24,3fff:172:20:20::/64,leaf1,leaf2,spine1,spine2",
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "PLATFORM=x86_64-kvm_x86_64-r0",
                "HWSKU=Force10-S6000"
            ],
            "Cmd": [],
            "Image": "docker-sonic-vs:latest",
            "Volumes": null,
            "WorkingDir": "/",
            "Entrypoint": [
                "/bin/bash"
            ],
            "OnBuild": null,
            "Labels": {
                "Tag": "202511.1137676-97a82c196",
                "clab-mgmt-net-bridge": "br-9fe0426c937b",
                "clab-node-group": "",
                "clab-node-kind": "sonic-vs",
                "clab-node-lab-dir": "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/clab-06-sonic-automation/leaf1",
                "clab-node-longname": "clab-06-sonic-automation-leaf1",
                "clab-node-name": "leaf1",
                "clab-node-type": "",
                "clab-owner": "yifan",
                "clab-topo-file": "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/topology.clab.yml",
                "com.azure.sonic.manifest": "\n{\n    \"version\": \"1.0.0\",\n    \"package\": {\n        \"version\": \"\",\n        \"depends\": [],\n        \"name\": \"\"\n    },\n    \"service\": {\n        \"name\": \"\",\n        \"requires\": [],\n        \"after\": [],\n        \"before\": [],\n        \"dependent-of\": [],\n        \"asic-service\": false,\n        \"host-service\": false,\n        \"warm-shutdown\": {\n            \"after\": [],\n            \"before\": []\n        },\n        \"fast-shutdown\": {\n            \"after\": [],\n            \"before\": []\n        },\n        \"syslog\": {\n            \"support-rate-limit\": true\n        }\n    },\n    \"container\": {\n        \"privileged\": false,\n        \"volumes\": [],\n        \"tmpfs\": []\n    },\n    \"cli\": {\n        \"config\": \"\",\n        \"show\": \"\",\n        \"clear\": \"\"\n    }\n}",
                "com.azure.sonic.versions.libsairedis": "1.0.0",
                "com.azure.sonic.versions.libswsscommon": "1.0.0",
                "com.azure.sonic.versions.sonic-supervisord-utilities-rs": "1.0.0",
                "com.azure.sonic.versions.sonic_utilities": "1.2",
                "containerlab": "06-sonic-automation"
            }
        },
        "NetworkSettings": {
            "Bridge": "",
            "SandboxID": "0773de4e7d3e0583a645067765db90acf343636aa4c56591530517ab212630fe",
            "SandboxKey": "/var/run/docker/netns/0773de4e7d3e",
            "Ports": {},
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "",
            "Gateway": "",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "",
            "IPPrefixLen": 0,
            "IPv6Gateway": "",
            "MacAddress": "",
            "Networks": {
                "clab": {
                    "IPAMConfig": {},
                    "Links": null,
                    "Aliases": null,
                    "MacAddress": "16:80:3a:bf:c4:97",
                    "DriverOpts": null,
                    "GwPriority": 0,
                    "NetworkID": "9fe0426c937b93edcfa82c7a191011c534082672577800052a3603a0788dc28c",
                    "EndpointID": "9f889b3d223963808f1e414cbe2c97d02c323e7cde04a997d807df3d047eba54",
                    "Gateway": "172.20.20.1",
                    "IPAddress": "172.20.20.3",
                    "IPPrefixLen": 24,
                    "IPv6Gateway": "3fff:172:20:20::1",
                    "GlobalIPv6Address": "3fff:172:20:20::3",
                    "GlobalIPv6PrefixLen": 64,
                    "DNSNames": [
                        "clab-06-sonic-automation-leaf1",
                        "f91781576063",
                        "leaf1"
                    ]
                }
            }
        }
    }
]
```

### PASS - leaf1 -> spine1 direct peer ping (10.0.11.0)

Command:

```bash
docker exec clab-06-sonic-automation-leaf1 ping -c 3 -W 1 10.0.11.0
```

Output:

```text
PING 10.0.11.0 (10.0.11.0) 56(84) bytes of data.
64 bytes from 10.0.11.0: icmp_seq=1 ttl=64 time=0.324 ms
64 bytes from 10.0.11.0: icmp_seq=2 ttl=64 time=0.333 ms
64 bytes from 10.0.11.0: icmp_seq=3 ttl=64 time=0.408 ms

--- 10.0.11.0 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2025ms
rtt min/avg/max/mdev = 0.324/0.355/0.408/0.037 ms
```

### PASS - leaf1 -> spine2 direct peer ping (10.0.12.0)

Command:

```bash
docker exec clab-06-sonic-automation-leaf1 ping -c 3 -W 1 10.0.12.0
```

Output:

```text
PING 10.0.12.0 (10.0.12.0) 56(84) bytes of data.
64 bytes from 10.0.12.0: icmp_seq=1 ttl=64 time=0.401 ms
64 bytes from 10.0.12.0: icmp_seq=2 ttl=64 time=0.334 ms
64 bytes from 10.0.12.0: icmp_seq=3 ttl=64 time=0.337 ms

--- 10.0.12.0 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2026ms
rtt min/avg/max/mdev = 0.334/0.357/0.401/0.030 ms
```

### PASS - leaf1 BGP summary contains expected peers

Command:

```bash
docker exec clab-06-sonic-automation-leaf1 vtysh -c show ip bgp summary
```

Output:

```text
IPv4 Unicast Summary:
BGP router identifier 10.255.0.11, local AS number 65101 VRF default vrf-id 0
BGP table version 4
RIB entries 7, using 896 bytes of memory
Peers 2, using 47 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.11.0       4      65001         7         7        4    0    0 00:00:44            2        4 N/A
10.0.12.0       4      65002         7         7        4    0    0 00:00:44            2        4 N/A

Total number of neighbors 2
```

### PASS - leaf1 BGP routes contain remote loopbacks

Command:

```bash
docker exec clab-06-sonic-automation-leaf1 vtysh -c show ip route bgp
```

Output:

```text
Codes: K - kernel route, C - connected, L - local, S - static,
       R - RIP, O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric, t - Table-Direct,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

IPv4 unicast VRF default:
B>* 10.255.0.1/32 [20/0] via 10.0.11.0, Ethernet0, weight 1, 00:00:42
B>* 10.255.0.2/32 [20/0] via 10.0.12.0, Ethernet4, weight 1, 00:00:42
B>* 10.255.0.12/32 [20/0] via 10.0.11.0, Ethernet0, weight 1, 00:00:42
```

### PASS - leaf1 (10.255.0.11) -> spine1 loopback (10.255.0.1)

Command:

```bash
docker exec clab-06-sonic-automation-leaf1 ping -I 10.255.0.11 -c 3 -W 1 10.255.0.1
```

Output:

```text
PING 10.255.0.1 (10.255.0.1) from 10.255.0.11 : 56(84) bytes of data.
64 bytes from 10.255.0.1: icmp_seq=1 ttl=64 time=0.412 ms
64 bytes from 10.255.0.1: icmp_seq=2 ttl=64 time=0.340 ms
64 bytes from 10.255.0.1: icmp_seq=3 ttl=64 time=0.349 ms

--- 10.255.0.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2037ms
rtt min/avg/max/mdev = 0.340/0.367/0.412/0.032 ms
```

### PASS - leaf1 (10.255.0.11) -> spine2 loopback (10.255.0.2)

Command:

```bash
docker exec clab-06-sonic-automation-leaf1 ping -I 10.255.0.11 -c 3 -W 1 10.255.0.2
```

Output:

```text
PING 10.255.0.2 (10.255.0.2) from 10.255.0.11 : 56(84) bytes of data.
64 bytes from 10.255.0.2: icmp_seq=1 ttl=64 time=0.395 ms
64 bytes from 10.255.0.2: icmp_seq=2 ttl=64 time=0.404 ms
64 bytes from 10.255.0.2: icmp_seq=3 ttl=64 time=0.467 ms

--- 10.255.0.2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2044ms
rtt min/avg/max/mdev = 0.395/0.422/0.467/0.032 ms
```

### PASS - leaf1 (10.255.0.11) -> leaf2 loopback (10.255.0.12)

Command:

```bash
docker exec clab-06-sonic-automation-leaf1 ping -I 10.255.0.11 -c 3 -W 1 10.255.0.12
```

Output:

```text
PING 10.255.0.12 (10.255.0.12) from 10.255.0.11 : 56(84) bytes of data.
64 bytes from 10.255.0.12: icmp_seq=1 ttl=63 time=0.595 ms
64 bytes from 10.255.0.12: icmp_seq=2 ttl=63 time=0.609 ms
64 bytes from 10.255.0.12: icmp_seq=3 ttl=63 time=0.609 ms

--- 10.255.0.12 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2049ms
rtt min/avg/max/mdev = 0.595/0.604/0.609/0.006 ms
```

### PASS - leaf2 container exists

Command:

```bash
docker inspect clab-06-sonic-automation-leaf2
```

Output:

```text
[
    {
        "Id": "9f94e1d1601abc839303529da82441213b3ee15209687e4bd4834d48c4e63bda",
        "Created": "2026-06-30T03:20:40.555969363Z",
        "Path": "/bin/bash",
        "Args": [],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 1803847,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2026-06-30T03:20:42.19760751Z",
            "FinishedAt": "0001-01-01T00:00:00Z"
        },
        "Image": "sha256:e6217fbf8eda7bc2a2f8fca62588234420808bf908ddd97ea5e07a57888fdda3",
        "ResolvConfPath": "/var/lib/docker/containers/9f94e1d1601abc839303529da82441213b3ee15209687e4bd4834d48c4e63bda/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/9f94e1d1601abc839303529da82441213b3ee15209687e4bd4834d48c4e63bda/hostname",
        "HostsPath": "/var/lib/docker/containers/9f94e1d1601abc839303529da82441213b3ee15209687e4bd4834d48c4e63bda/hosts",
        "LogPath": "/var/lib/docker/containers/9f94e1d1601abc839303529da82441213b3ee15209687e4bd4834d48c4e63bda/9f94e1d1601abc839303529da82441213b3ee15209687e4bd4834d48c4e63bda-json.log",
        "Name": "/clab-06-sonic-automation-leaf2",
        "RestartCount": 0,
        "Driver": "overlay2",
        "Platform": "linux",
        "MountLabel": "",
        "ProcessLabel": "",
        "AppArmorProfile": "unconfined",
        "ExecIDs": [
            "4d9775d0ff48a5f5e1bffb1e53116719f1841e1201d21196eee279d3a61a723d"
        ],
        "HostConfig": {
            "Binds": [
                "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/configs/common/daemons:/etc/frr/daemons",
                "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/configs/leaf2:/sonic/config"
            ],
            "ContainerIDFile": "",
            "LogConfig": {
                "Type": "json-file",
                "Config": {}
            },
            "NetworkMode": "clab",
            "PortBindings": null,
            "RestartPolicy": {
                "Name": "no",
                "MaximumRetryCount": 0
            },
            "AutoRemove": false,
            "VolumeDriver": "",
            "VolumesFrom": null,
            "ConsoleSize": [
                0,
                0
            ],
            "CapAdd": null,
            "CapDrop": null,
            "CgroupnsMode": "private",
            "Dns": [
                "72.249.191.254"
            ],
            "DnsOptions": null,
            "DnsSearch": null,
            "ExtraHosts": [],
            "GroupAdd": null,
            "IpcMode": "private",
            "Cgroup": "",
            "Links": null,
            "OomScoreAdj": 0,
            "PidMode": "",
            "Privileged": true,
            "PublishAllPorts": false,
            "ReadonlyRootfs": false,
            "SecurityOpt": [
                "label=disable"
            ],
            "UTSMode": "",
            "UsernsMode": "",
            "ShmSize": 67108864,
            "Runtime": "runc",
            "Isolation": "",
            "CpuShares": 0,
            "Memory": 0,
            "NanoCpus": 0,
            "CgroupParent": "",
            "BlkioWeight": 0,
            "BlkioWeightDevice": null,
            "BlkioDeviceReadBps": null,
            "BlkioDeviceWriteBps": null,
            "BlkioDeviceReadIOps": null,
            "BlkioDeviceWriteIOps": null,
            "CpuPeriod": 0,
            "CpuQuota": 0,
            "CpuRealtimePeriod": 0,
            "CpuRealtimeRuntime": 0,
            "CpusetCpus": "",
            "CpusetMems": "",
            "Devices": null,
            "DeviceCgroupRules": null,
            "DeviceRequests": null,
            "MemoryReservation": 0,
            "MemorySwap": 0,
            "MemorySwappiness": null,
            "OomKillDisable": null,
            "PidsLimit": null,
            "Ulimits": [
                {
                    "Name": "nofile",
                    "Hard": 524288,
                    "Soft": 524288
                }
            ],
            "CpuCount": 0,
            "CpuPercent": 0,
            "IOMaximumIOps": 0,
            "IOMaximumBandwidth": 0,
            "MaskedPaths": null,
            "ReadonlyPaths": null
        },
        "GraphDriver": {
            "Data": {
                "ID": "9f94e1d1601abc839303529da82441213b3ee15209687e4bd4834d48c4e63bda",
                "LowerDir": "/var/lib/docker/overlay2/55e308e543b8a58fbe5eac6569cfa8bbf1134a014812c76b1d387032fe07d64c-init/diff:/var/lib/docker/overlay2/0e34ce6926132323ee59d4af1fd83cc5790911a727ac5cb3f255d4484f82fccc/diff:/var/lib/docker/overlay2/a1911de4977251cfcb5e83e43aceb71dfb6301deff7a7085befd91f5da60fe79/diff:/var/lib/docker/overlay2/e26b4f7873e7f674cef6eeced1c63d89c48e842c1517bd77ff0f14fe4a69e171/diff:/var/lib/docker/overlay2/a592f025dd323b3d601b6482002d8d8f90fcffc7266c78ad68f1893f8011be9a/diff:/var/lib/docker/overlay2/a9e7b7d2539dd259497fc4853eb5879b1e03c882c3e0a62a322c9e998988f78d/diff:/var/lib/docker/overlay2/74eb50caf8fdde8b17973ee36747b057c6d18d9076a1b71894f20897533f1478/diff:/var/lib/docker/overlay2/40a4d517d3207161b2f33098e30d882052a0efd19969dfa118b2b42db456dc90/diff:/var/lib/docker/overlay2/2826af6ab6b91bc62a49ed3c39860d40a905eab4689f9f3a355215707e9014bd/diff",
                "MergedDir": "/var/lib/docker/overlay2/55e308e543b8a58fbe5eac6569cfa8bbf1134a014812c76b1d387032fe07d64c/merged",
                "UpperDir": "/var/lib/docker/overlay2/55e308e543b8a58fbe5eac6569cfa8bbf1134a014812c76b1d387032fe07d64c/diff",
                "WorkDir": "/var/lib/docker/overlay2/55e308e543b8a58fbe5eac6569cfa8bbf1134a014812c76b1d387032fe07d64c/work"
            },
            "Name": "overlay2"
        },
        "Mounts": [
            {
                "Type": "bind",
                "Source": "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/configs/common/daemons",
                "Destination": "/etc/frr/daemons",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            },
            {
                "Type": "bind",
                "Source": "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/configs/leaf2",
                "Destination": "/sonic/config",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            }
        ],
        "Config": {
            "Hostname": "leaf2",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": true,
            "AttachStderr": true,
            "Tty": true,
            "OpenStdin": true,
            "StdinOnce": false,
            "Env": [
                "no_proxy=localhost,127.0.0.1,::1,*.local,172.20.20.0/24,3fff:172:20:20::/64,leaf1,leaf2,spine1,spine2",
                "NO_PROXY=localhost,127.0.0.1,::1,*.local,172.20.20.0/24,3fff:172:20:20::/64,leaf1,leaf2,spine1,spine2",
                "CLAB_LABEL_CLAB_NODE_GROUP=",
                "CLAB_LABEL_CLAB_TOPO_FILE=/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/topology.clab.yml",
                "CLAB_LABEL_CLAB_NODE_TYPE=",
                "CLAB_LABEL_CLAB_NODE_LAB_DIR=/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/clab-06-sonic-automation/leaf2",
                "CLAB_INTFS=2",
                "CLAB_LABEL_CLAB_NODE_NAME=leaf2",
                "CLAB_LABEL_CLAB_NODE_KIND=sonic-vs",
                "CLAB_LABEL_CLAB_NODE_LONGNAME=clab-06-sonic-automation-leaf2",
                "CLAB_LABEL_CLAB_OWNER=yifan",
                "CLAB_LABEL_CONTAINERLAB=06-sonic-automation",
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "PLATFORM=x86_64-kvm_x86_64-r0",
                "HWSKU=Force10-S6000"
            ],
            "Cmd": [],
            "Image": "docker-sonic-vs:latest",
            "Volumes": null,
            "WorkingDir": "/",
            "Entrypoint": [
                "/bin/bash"
            ],
            "OnBuild": null,
            "Labels": {
                "Tag": "202511.1137676-97a82c196",
                "clab-mgmt-net-bridge": "br-9fe0426c937b",
                "clab-node-group": "",
                "clab-node-kind": "sonic-vs",
                "clab-node-lab-dir": "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/clab-06-sonic-automation/leaf2",
                "clab-node-longname": "clab-06-sonic-automation-leaf2",
                "clab-node-name": "leaf2",
                "clab-node-type": "",
                "clab-owner": "yifan",
                "clab-topo-file": "/home/yifan/ai_dc_fabric_lab/labs/06-sonic-automation/topology.clab.yml",
                "com.azure.sonic.manifest": "\n{\n    \"version\": \"1.0.0\",\n    \"package\": {\n        \"version\": \"\",\n        \"depends\": [],\n        \"name\": \"\"\n    },\n    \"service\": {\n        \"name\": \"\",\n        \"requires\": [],\n        \"after\": [],\n        \"before\": [],\n        \"dependent-of\": [],\n        \"asic-service\": false,\n        \"host-service\": false,\n        \"warm-shutdown\": {\n            \"after\": [],\n            \"before\": []\n        },\n        \"fast-shutdown\": {\n            \"after\": [],\n            \"before\": []\n        },\n        \"syslog\": {\n            \"support-rate-limit\": true\n        }\n    },\n    \"container\": {\n        \"privileged\": false,\n        \"volumes\": [],\n        \"tmpfs\": []\n    },\n    \"cli\": {\n        \"config\": \"\",\n        \"show\": \"\",\n        \"clear\": \"\"\n    }\n}",
                "com.azure.sonic.versions.libsairedis": "1.0.0",
                "com.azure.sonic.versions.libswsscommon": "1.0.0",
                "com.azure.sonic.versions.sonic-supervisord-utilities-rs": "1.0.0",
                "com.azure.sonic.versions.sonic_utilities": "1.2",
                "containerlab": "06-sonic-automation"
            }
        },
        "NetworkSettings": {
            "Bridge": "",
            "SandboxID": "5d4287bf9a7c1c56b265dd9e10a100465d436470fc289872b21b5831c076c07c",
            "SandboxKey": "/var/run/docker/netns/5d4287bf9a7c",
            "Ports": {},
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "",
            "Gateway": "",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "",
            "IPPrefixLen": 0,
            "IPv6Gateway": "",
            "MacAddress": "",
            "Networks": {
                "clab": {
                    "IPAMConfig": {},
                    "Links": null,
                    "Aliases": null,
                    "MacAddress": "de:46:c5:79:ea:75",
                    "DriverOpts": null,
                    "GwPriority": 0,
                    "NetworkID": "9fe0426c937b93edcfa82c7a191011c534082672577800052a3603a0788dc28c",
                    "EndpointID": "c2a6059cab18333eaa144e45c9d9e62f041b6def2dbdeb68cc7dce46eeaf1b78",
                    "Gateway": "172.20.20.1",
                    "IPAddress": "172.20.20.4",
                    "IPPrefixLen": 24,
                    "IPv6Gateway": "3fff:172:20:20::1",
                    "GlobalIPv6Address": "3fff:172:20:20::4",
                    "GlobalIPv6PrefixLen": 64,
                    "DNSNames": [
                        "clab-06-sonic-automation-leaf2",
                        "9f94e1d1601a",
                        "leaf2"
                    ]
                }
            }
        }
    }
]
```

### PASS - leaf2 -> spine1 direct peer ping (10.0.21.0)

Command:

```bash
docker exec clab-06-sonic-automation-leaf2 ping -c 3 -W 1 10.0.21.0
```

Output:

```text
PING 10.0.21.0 (10.0.21.0) 56(84) bytes of data.
64 bytes from 10.0.21.0: icmp_seq=1 ttl=64 time=0.460 ms
64 bytes from 10.0.21.0: icmp_seq=2 ttl=64 time=0.339 ms
64 bytes from 10.0.21.0: icmp_seq=3 ttl=64 time=0.361 ms

--- 10.0.21.0 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2044ms
rtt min/avg/max/mdev = 0.339/0.386/0.460/0.052 ms
```

### PASS - leaf2 -> spine2 direct peer ping (10.0.22.0)

Command:

```bash
docker exec clab-06-sonic-automation-leaf2 ping -c 3 -W 1 10.0.22.0
```

Output:

```text
PING 10.0.22.0 (10.0.22.0) 56(84) bytes of data.
64 bytes from 10.0.22.0: icmp_seq=1 ttl=64 time=0.422 ms
64 bytes from 10.0.22.0: icmp_seq=2 ttl=64 time=0.404 ms
64 bytes from 10.0.22.0: icmp_seq=3 ttl=64 time=0.338 ms

--- 10.0.22.0 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2040ms
rtt min/avg/max/mdev = 0.338/0.388/0.422/0.036 ms
```

### PASS - leaf2 BGP summary contains expected peers

Command:

```bash
docker exec clab-06-sonic-automation-leaf2 vtysh -c show ip bgp summary
```

Output:

```text
IPv4 Unicast Summary:
BGP router identifier 10.255.0.12, local AS number 65102 VRF default vrf-id 0
BGP table version 4
RIB entries 7, using 896 bytes of memory
Peers 2, using 47 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.0.21.0       4      65001         7         7        4    0    0 00:00:55            3        4 N/A
10.0.22.0       4      65002         7         7        4    0    0 00:00:55            3        4 N/A

Total number of neighbors 2
```

### PASS - leaf2 BGP routes contain remote loopbacks

Command:

```bash
docker exec clab-06-sonic-automation-leaf2 vtysh -c show ip route bgp
```

Output:

```text
Codes: K - kernel route, C - connected, L - local, S - static,
       R - RIP, O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric, t - Table-Direct,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

IPv4 unicast VRF default:
B>* 10.255.0.1/32 [20/0] via 10.0.21.0, Ethernet0, weight 1, 00:00:53
B>* 10.255.0.2/32 [20/0] via 10.0.22.0, Ethernet4, weight 1, 00:00:53
B>* 10.255.0.11/32 [20/0] via 10.0.21.0, Ethernet0, weight 1, 00:00:53
```

### PASS - leaf2 (10.255.0.12) -> spine1 loopback (10.255.0.1)

Command:

```bash
docker exec clab-06-sonic-automation-leaf2 ping -I 10.255.0.12 -c 3 -W 1 10.255.0.1
```

Output:

```text
PING 10.255.0.1 (10.255.0.1) from 10.255.0.12 : 56(84) bytes of data.
64 bytes from 10.255.0.1: icmp_seq=1 ttl=64 time=0.361 ms
64 bytes from 10.255.0.1: icmp_seq=2 ttl=64 time=0.305 ms
64 bytes from 10.255.0.1: icmp_seq=3 ttl=64 time=0.301 ms

--- 10.255.0.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2041ms
rtt min/avg/max/mdev = 0.301/0.322/0.361/0.027 ms
```

### PASS - leaf2 (10.255.0.12) -> spine2 loopback (10.255.0.2)

Command:

```bash
docker exec clab-06-sonic-automation-leaf2 ping -I 10.255.0.12 -c 3 -W 1 10.255.0.2
```

Output:

```text
PING 10.255.0.2 (10.255.0.2) from 10.255.0.12 : 56(84) bytes of data.
64 bytes from 10.255.0.2: icmp_seq=1 ttl=64 time=0.380 ms
64 bytes from 10.255.0.2: icmp_seq=2 ttl=64 time=0.377 ms
64 bytes from 10.255.0.2: icmp_seq=3 ttl=64 time=0.431 ms

--- 10.255.0.2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2025ms
rtt min/avg/max/mdev = 0.377/0.396/0.431/0.024 ms
```

### PASS - leaf2 (10.255.0.12) -> leaf1 loopback (10.255.0.11)

Command:

```bash
docker exec clab-06-sonic-automation-leaf2 ping -I 10.255.0.12 -c 3 -W 1 10.255.0.11
```

Output:

```text
PING 10.255.0.11 (10.255.0.11) from 10.255.0.12 : 56(84) bytes of data.
64 bytes from 10.255.0.11: icmp_seq=1 ttl=63 time=0.641 ms
64 bytes from 10.255.0.11: icmp_seq=2 ttl=63 time=0.637 ms
64 bytes from 10.255.0.11: icmp_seq=3 ttl=63 time=0.609 ms

--- 10.255.0.11 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2032ms
rtt min/avg/max/mdev = 0.609/0.629/0.641/0.014 ms
```

