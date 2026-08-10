# AI Ethernet Fabric

Fabric telementry and adaptive routing link
```
Traffic
   ↓
ECMP chooses path
   ↓
queue / port starts congesting
   ↓
HFT sees short-lived congestion
   ↓
NetQ correlates fabric/path behavior
   ↓
Adaptive Routing can choose a better eligible path
```

WJH vs HFT vs NetQ vs Adaptive Routing
```
WJH
"What happened to this packet?"
"Why did this packet drop?"
        ↓
Local, event, drop reason

HFT
"What happened in these few milliseconds?"
"What happened during this very short burst?"
        ↓
High frequency counters / microburst

NetQ
"Where is the problem in the fabric?"
"Where in the fabric/path is the problem?"
        ↓
Connections cross device, path and time

ECMP
"Which equal-cost path does the hash select?"

Adaptive Routing
"Which path should I use now?"
"Which eligible path is currently healthier?"
        ↓
Dynamic forwarding
```

## Polling for AI fabric
Normal NMS polls every 30 secs which can't capture the microburst issue.
```
0 ms       queue starts filling
0.5 ms     synchronized GPU traffic arrives
1 ms       queue almost full
1.5 ms     ECN/PFC threshold reached
2 ms       burst disappears
30 sec     SNMP polls counter
```

AI fabric cares:
- queue occupancy
- queue watermark
- ECN
- PFC
- buffer occupancy
- path imbalance
- microbursts

## HFT
High-frequency telemetry. 
HFT is not just faster Telementry

Traditional telemetry: coarse time-series

HFT: very fine-grained ASIC telemetry

On Spectrum-4+, a HFT profile can be created:
```
nv set system telemetry hft profile profile1 sample-interval 1000
nv set system telemetry hft profile profile1 counter rx-byte
nv set system telemetry hft profile profile1 counter tx-byte
nv config apply
```

# ECMP and Adaptive Routing
The traffic load can be uneven on the multiple pathes.

Adaptive Routing: ECMP + current network state

Adaptive Routing select forwarding path based on switch dynamic state, including:
- queue occupancy
- port utilization

ECMP asks: Which path did the hash choose?

Adaptive Routing asks: Among eligible paths, which path currently looks better?

In the following situation:
```
             spine01
             Queue ██████████ 90%
            /
leaf01 ----
            \
             Queue ██ 20%
             spine02
```

Adaptive Routing:
```
Path A grade = bad
Path B grade = good

         ↓

prefer Path B
```

## Difference between queue occupancy and port utilization

Port utilization:
```
400G port

current traffic = 360G

utilization = 90%
```

Queue occupancy:
```
Queue capacity
████████████████████

Currently:
████████████████░░░░
```

Queue capacity reflects congestion better than port utilization

Adaptive Routing monitoring on NetQ also shows queue-length histogram and ECMP imbalance data.

## Adaptive Routing ≠ Congestion Control

```
Adaptive Routing
       ↓
Where should traffic go?

ECN / DCQCN
       ↓
How fast should sender send?

PFC
       ↓
Should upstream temporarily stop this priority?
```

Adaptive Routing → choose better path

ECN/DCQCN → control offered load

PFC → loss prevention / pause

