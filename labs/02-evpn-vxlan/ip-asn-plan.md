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



# Host, VLAN, VNI plan

## VLAN 10 / L2VNI 10010

| Host | Leaf | IP | Gateway |
|---|---|---|---|
| host1 | leaf1 | 192.168.10.11/24 | 192.168.10.1 |
| host2 | leaf2 | 192.168.10.12/24 | 192.168.10.1 |

| Item | Value |
|---|---|
| VLAN | 10 |
| L2VNI | 10010 |
| Anycast gateway IP | 192.168.10.1/24 |
| Anycast gateway MAC | 00:00:00:00:10:01 |
| Route target | 65000:10010 |

## VLAN 20 / L2VNI 10020

| Host | Leaf | IP | Gateway |
|---|---|---|---|
| host3 | leaf3 | 192.168.20.13/24 | 192.168.20.1 |
| host4 | leaf4 | 192.168.20.14/24 | 192.168.20.1 |

| Item | Value |
|---|---|
| VLAN | 20 |
| L2VNI | 10020 |
| Anycast gateway IP | 192.168.20.1/24 |
| Anycast gateway MAC | 00:00:00:00:20:01 |
| Route target | 65000:10020 |