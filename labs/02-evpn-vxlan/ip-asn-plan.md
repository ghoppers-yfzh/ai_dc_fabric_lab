# IP plan

spine1 lo: 10.255.0.1/32
spine2 lo: 10.255.0.2/32
leaf1  lo: 10.255.1.1/32
leaf2  lo: 10.255.1.2/32
leaf3 lo: 10.255.1.3/32
leaf4 lo: 10.255.1.4/32

spine1-leaf1: 10.0.0.0/31
spine1-leaf2: 10.0.0.2/31
spine1-leaf3: 10.0.0.8/31
spine1-leaf4: 10.0.0.10/31

spine2-leaf1: 10.0.0.4/31
spine2-leaf2: 10.0.0.6/31
spine2-leaf3: 10.0.0.12/31
spine2-leaf4: 10.0.0.14/31

spine ASN: 65000
leaf1 ASN: 65101
leaf2 ASN: 65102
leaf3 ASN: 65103
leaf4 ASN: 65104



# Host, vlan, VNI plan

host1: 192.168.10.11/24
host2: 192.168.10.12/24
host3: 192.168.10.13/24
host4: 192.168.10.14/24
VLAN: 10
L2VNI: 10010