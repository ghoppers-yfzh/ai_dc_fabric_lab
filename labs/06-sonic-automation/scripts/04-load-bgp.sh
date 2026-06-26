#! /bin/bash

for node in spine1 spine2 leaf1 leaf2; do
    echo "Load BGP config for $node"
    docker exec clab-06-sonic-automation-$node vtysh -f /sonic/config/frr.vtysh
done