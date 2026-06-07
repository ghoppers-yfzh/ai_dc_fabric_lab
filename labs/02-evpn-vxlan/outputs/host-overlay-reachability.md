# Host Overlay Reachability

## host1 to host2
PING 192.168.10.12 (192.168.10.12) 56(84) bytes of data.
64 bytes from 192.168.10.12: icmp_seq=1 ttl=64 time=0.174 ms
64 bytes from 192.168.10.12: icmp_seq=2 ttl=64 time=0.106 ms
64 bytes from 192.168.10.12: icmp_seq=3 ttl=64 time=0.080 ms

--- 192.168.10.12 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2025ms
rtt min/avg/max/mdev = 0.080/0.120/0.174/0.039 ms

## host2 to host1
PING 192.168.10.11 (192.168.10.11) 56(84) bytes of data.
64 bytes from 192.168.10.11: icmp_seq=1 ttl=64 time=0.217 ms
64 bytes from 192.168.10.11: icmp_seq=2 ttl=64 time=0.157 ms
64 bytes from 192.168.10.11: icmp_seq=3 ttl=64 time=0.081 ms

--- 192.168.10.11 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2052ms
rtt min/avg/max/mdev = 0.081/0.151/0.217/0.055 ms
