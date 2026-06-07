]633;E;echo "# Four-Leaf Host Overlay Reachability";fbf5a41f-2d56-4ae0-adfc-bae181e9a759]633;C# Four-Leaf Host Overlay Reachability

## host1 to host2
PING 192.168.10.12 (192.168.10.12) 56(84) bytes of data.
64 bytes from 192.168.10.12: icmp_seq=1 ttl=64 time=0.163 ms
64 bytes from 192.168.10.12: icmp_seq=2 ttl=64 time=0.141 ms
64 bytes from 192.168.10.12: icmp_seq=3 ttl=64 time=0.112 ms

--- 192.168.10.12 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2054ms
rtt min/avg/max/mdev = 0.112/0.138/0.163/0.020 ms

## host1 to host3
PING 192.168.10.13 (192.168.10.13) 56(84) bytes of data.
64 bytes from 192.168.10.13: icmp_seq=1 ttl=64 time=0.189 ms
64 bytes from 192.168.10.13: icmp_seq=2 ttl=64 time=0.117 ms
64 bytes from 192.168.10.13: icmp_seq=3 ttl=64 time=0.084 ms

--- 192.168.10.13 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2054ms
rtt min/avg/max/mdev = 0.084/0.130/0.189/0.043 ms

## host1 to host4
PING 192.168.10.14 (192.168.10.14) 56(84) bytes of data.
64 bytes from 192.168.10.14: icmp_seq=1 ttl=64 time=0.178 ms
64 bytes from 192.168.10.14: icmp_seq=2 ttl=64 time=0.105 ms
64 bytes from 192.168.10.14: icmp_seq=3 ttl=64 time=0.118 ms

--- 192.168.10.14 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2035ms
rtt min/avg/max/mdev = 0.105/0.133/0.178/0.031 ms

## host2 to host1
PING 192.168.10.11 (192.168.10.11) 56(84) bytes of data.
64 bytes from 192.168.10.11: icmp_seq=1 ttl=64 time=0.178 ms
64 bytes from 192.168.10.11: icmp_seq=2 ttl=64 time=0.076 ms
64 bytes from 192.168.10.11: icmp_seq=3 ttl=64 time=0.080 ms

--- 192.168.10.11 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2054ms
rtt min/avg/max/mdev = 0.076/0.111/0.178/0.047 ms

## host3 to host1
PING 192.168.10.11 (192.168.10.11) 56(84) bytes of data.
64 bytes from 192.168.10.11: icmp_seq=1 ttl=64 time=0.133 ms
64 bytes from 192.168.10.11: icmp_seq=2 ttl=64 time=0.097 ms
64 bytes from 192.168.10.11: icmp_seq=3 ttl=64 time=0.127 ms

--- 192.168.10.11 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2047ms
rtt min/avg/max/mdev = 0.097/0.119/0.133/0.015 ms

## host4 to host1
PING 192.168.10.11 (192.168.10.11) 56(84) bytes of data.
64 bytes from 192.168.10.11: icmp_seq=1 ttl=64 time=0.150 ms
64 bytes from 192.168.10.11: icmp_seq=2 ttl=64 time=0.097 ms
64 bytes from 192.168.10.11: icmp_seq=3 ttl=64 time=0.078 ms

--- 192.168.10.11 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2027ms
rtt min/avg/max/mdev = 0.078/0.108/0.150/0.030 ms
