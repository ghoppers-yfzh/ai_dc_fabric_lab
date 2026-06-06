# Host Reachability Validation

## host1 route table
default via 192.168.1.1 dev eth1 
172.20.20.0/24 dev eth0 proto kernel scope link src 172.20.20.7 
192.168.1.0/24 dev eth1 proto kernel scope link src 192.168.1.11 

## host1 to host2
PING 192.168.2.11 (192.168.2.11) 56(84) bytes of data.
64 bytes from 192.168.2.11: icmp_seq=1 ttl=61 time=0.125 ms
64 bytes from 192.168.2.11: icmp_seq=2 ttl=61 time=0.093 ms
64 bytes from 192.168.2.11: icmp_seq=3 ttl=61 time=0.085 ms

--- 192.168.2.11 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2027ms
rtt min/avg/max/mdev = 0.085/0.101/0.125/0.017 ms

## host1 to host3
PING 192.168.3.11 (192.168.3.11) 56(84) bytes of data.
64 bytes from 192.168.3.11: icmp_seq=1 ttl=61 time=0.131 ms
64 bytes from 192.168.3.11: icmp_seq=2 ttl=61 time=0.061 ms
64 bytes from 192.168.3.11: icmp_seq=3 ttl=61 time=0.061 ms

--- 192.168.3.11 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2049ms
rtt min/avg/max/mdev = 0.061/0.084/0.131/0.033 ms

## host1 to host4
PING 192.168.4.11 (192.168.4.11) 56(84) bytes of data.
64 bytes from 192.168.4.11: icmp_seq=1 ttl=61 time=0.106 ms
64 bytes from 192.168.4.11: icmp_seq=2 ttl=61 time=0.091 ms
64 bytes from 192.168.4.11: icmp_seq=3 ttl=61 time=0.060 ms

--- 192.168.4.11 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2044ms
rtt min/avg/max/mdev = 0.060/0.085/0.106/0.019 ms
