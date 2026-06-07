# Anycast Gateway Validation

## Test Purpose

Validate that all hosts can reach the distributed anycast gateway IP 192.168.10.1 and that existing same-subnet VXLAN overlay reachability still works.

## Host default routes

### host1
default via 192.168.10.1 dev eth1 
172.20.20.0/24 dev eth0 proto kernel scope link src 172.20.20.8 
192.168.10.0/24 dev eth1 proto kernel scope link src 192.168.10.11 

### host2
default via 192.168.10.1 dev eth1 
172.20.20.0/24 dev eth0 proto kernel scope link src 172.20.20.10 
192.168.10.0/24 dev eth1 proto kernel scope link src 192.168.10.12 

### host3
default via 192.168.10.1 dev eth1 
172.20.20.0/24 dev eth0 proto kernel scope link src 172.20.20.6 
192.168.10.0/24 dev eth1 proto kernel scope link src 192.168.10.13 

### host4
default via 192.168.10.1 dev eth1 
172.20.20.0/24 dev eth0 proto kernel scope link src 172.20.20.5 
192.168.10.0/24 dev eth1 proto kernel scope link src 192.168.10.14 

## Leaf bridge interface addresses

### leaf1
br10             UP             192.168.10.1/24 fe80::3cac:2fff:fec0:5b82/64 
3: br10: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9450 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 00:00:00:00:10:01 brd ff:ff:ff:ff:ff:ff

### leaf2
br10             UP             192.168.10.1/24 fe80::f4c5:e4ff:feda:ecf6/64 
3: br10: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9450 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 00:00:00:00:10:01 brd ff:ff:ff:ff:ff:ff

### leaf3
br10             UP             192.168.10.1/24 fe80::a454:82ff:fecd:d39e/64 
3: br10: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9450 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 00:00:00:00:10:01 brd ff:ff:ff:ff:ff:ff

### leaf4
br10             UP             192.168.10.1/24 fe80::74d3:26ff:fe81:2b8b/64 
3: br10: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9450 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 00:00:00:00:10:01 brd ff:ff:ff:ff:ff:ff

## Host to anycast gateway

### host1 to 192.168.10.1
PING 192.168.10.1 (192.168.10.1) 56(84) bytes of data.
64 bytes from 192.168.10.1: icmp_seq=1 ttl=64 time=0.079 ms
64 bytes from 192.168.10.1: icmp_seq=2 ttl=64 time=0.039 ms
64 bytes from 192.168.10.1: icmp_seq=3 ttl=64 time=0.053 ms

--- 192.168.10.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2043ms
rtt min/avg/max/mdev = 0.039/0.057/0.079/0.016 ms

### host2 to 192.168.10.1
PING 192.168.10.1 (192.168.10.1) 56(84) bytes of data.
64 bytes from 192.168.10.1: icmp_seq=1 ttl=64 time=0.073 ms
64 bytes from 192.168.10.1: icmp_seq=2 ttl=64 time=0.025 ms
64 bytes from 192.168.10.1: icmp_seq=3 ttl=64 time=0.038 ms

--- 192.168.10.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2035ms
rtt min/avg/max/mdev = 0.025/0.045/0.073/0.020 ms

### host3 to 192.168.10.1
PING 192.168.10.1 (192.168.10.1) 56(84) bytes of data.
64 bytes from 192.168.10.1: icmp_seq=1 ttl=64 time=0.073 ms
64 bytes from 192.168.10.1: icmp_seq=2 ttl=64 time=0.048 ms
64 bytes from 192.168.10.1: icmp_seq=3 ttl=64 time=0.041 ms

--- 192.168.10.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2054ms
rtt min/avg/max/mdev = 0.041/0.054/0.073/0.013 ms

### host4 to 192.168.10.1
PING 192.168.10.1 (192.168.10.1) 56(84) bytes of data.
64 bytes from 192.168.10.1: icmp_seq=1 ttl=64 time=0.070 ms
64 bytes from 192.168.10.1: icmp_seq=2 ttl=64 time=0.073 ms
64 bytes from 192.168.10.1: icmp_seq=3 ttl=64 time=0.072 ms

--- 192.168.10.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2038ms
rtt min/avg/max/mdev = 0.070/0.071/0.073/0.001 ms

## host1 to remote hosts after anycast gateway configuration

### host1 to host2
PING 192.168.10.12 (192.168.10.12) 56(84) bytes of data.
64 bytes from 192.168.10.12: icmp_seq=1 ttl=64 time=0.188 ms
64 bytes from 192.168.10.12: icmp_seq=2 ttl=64 time=0.080 ms
64 bytes from 192.168.10.12: icmp_seq=3 ttl=64 time=0.082 ms

--- 192.168.10.12 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2025ms
rtt min/avg/max/mdev = 0.080/0.116/0.188/0.050 ms

### host1 to host3
PING 192.168.10.13 (192.168.10.13) 56(84) bytes of data.
64 bytes from 192.168.10.13: icmp_seq=1 ttl=64 time=0.194 ms
64 bytes from 192.168.10.13: icmp_seq=2 ttl=64 time=0.080 ms
64 bytes from 192.168.10.13: icmp_seq=3 ttl=64 time=0.137 ms

--- 192.168.10.13 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2042ms
rtt min/avg/max/mdev = 0.080/0.137/0.194/0.046 ms

### host1 to host4
PING 192.168.10.14 (192.168.10.14) 56(84) bytes of data.
64 bytes from 192.168.10.14: icmp_seq=1 ttl=64 time=0.221 ms
64 bytes from 192.168.10.14: icmp_seq=2 ttl=64 time=0.081 ms
64 bytes from 192.168.10.14: icmp_seq=3 ttl=64 time=0.080 ms

--- 192.168.10.14 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2029ms
rtt min/avg/max/mdev = 0.080/0.127/0.221/0.066 ms
