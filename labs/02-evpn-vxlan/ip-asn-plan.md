# IP plan

spine1 lo: 10.255.0.1/32
spine2 lo: 10.255.0.2/32
leaf1  lo: 10.255.1.1/32
leaf2  lo: 10.255.1.2/32

spine1-leaf1: 10.0.0.0/31
spine1-leaf2: 10.0.0.2/31
spine2-leaf1: 10.0.0.4/31
spine2-leaf2: 10.0.0.6/31

spine ASN: 65000
leaf1 ASN: 65101
leaf2 ASN: 65102


# Host, vlan, VNI plan

host1: 192.168.10.11/24
host2: 192.168.10.12/24
VLAN: 10
L2VNI: 10010