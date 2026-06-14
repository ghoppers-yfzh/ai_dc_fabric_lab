# Lab 03a Deploy Status

## containerlab inspect
[1m╭[0m[1m─────────────────────────[0m[1m┬[0m[1m────────────────────────[0m[1m┬[0m[1m─────────[0m[1m┬[0m[1m───────────────────[0m[1m╮[0m
[1m│[0m[1m           Name          [0m[1m│[0m[1m       Kind/Image       [0m[1m│[0m[1m  State  [0m[1m│[0m[1m   IPv4/6 Address  [0m[1m│[0m
[1m├[0m[1m─────────────────────────[0m[1m┼[0m[1m────────────────────────[0m[1m┼[0m[1m─────────[0m[1m┼[0m[1m───────────────────[0m[1m┤[0m
│ clab-sonic-basic-host1  │ linux                  │ running │ 172.20.20.12      │
│                         │ alpine:latest          │         │ 3fff:172:20:20::c │
├─────────────────────────┼────────────────────────┼─────────┼───────────────────┤
│ clab-sonic-basic-sonic1 │ sonic-vs               │ running │ 172.20.20.13      │
│                         │ docker-sonic-vs:202511 │         │ 3fff:172:20:20::d │
╰─────────────────────────┴────────────────────────┴─────────┴───────────────────╯

## docker ps
NAMES                     IMAGE                    STATUS
clab-sonic-basic-sonic1   docker-sonic-vs:202511   Up 14 minutes
clab-sonic-basic-host1    alpine:latest            Up 14 minutes
