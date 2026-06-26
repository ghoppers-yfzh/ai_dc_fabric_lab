#! /bin/bash

for node in spine1 spine2 leaf1 leaf2; do
    echo "Loading config DB for $node"
    docker exec clab-06-sonic-automation-$node config load /sonic/config/config_db.json -y
done