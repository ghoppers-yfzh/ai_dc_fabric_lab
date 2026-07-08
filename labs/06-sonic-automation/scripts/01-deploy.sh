#! /bin/bash

containerlab destroy -t topology.clab.yml --cleanup
sleep 5
containerlab deploy -t topology.clab.yml
