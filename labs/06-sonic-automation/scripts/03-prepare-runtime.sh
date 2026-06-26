#! /bin/bash

for node in spine1 spine2 leaf1 leaf2; do
    echo "Set link up for $node"
    docker exec clab-06-sonic-automation-$node ip link set eth1 up
    docker exec clab-06-sonic-automation-$node ip link set eth2 up
    echo "Start bgpd for $node"
    docker exec clab-06-sonic-automation-$node /usr/lib/frr/bgpd -d -A 127.0.0.1
    docker exec clab-06-sonic-automation-$node ps -ef | grep bgpd
done