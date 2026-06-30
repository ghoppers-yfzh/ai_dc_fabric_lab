#! /bin/bash

containerlab destroy -t topology.clam.yml --cleanup
sleep 5
containerlab deploy -t topology.clam.yml
