# Concept
Physical Topoloy is about device and cable connection.

Logical Topology is about traffic flow in fabric.

Considerations:
- Availability
- Reliability
- Performance
- Future Growth
- Budget

# Leaf-Spine

Two layers:
```
Host A
  |
Leaf 1
  |
Spine
  |
Leaf 2
  |
Host B
```

- Same path length for traffic between two hosts on different Leaf
- Each Leaf connects every spines
- ECMP
- Stable latency
- Redudency for Spine and link

Three layers:
```
Leaf
  ↓
Spine
  ↓
Super Spine
  ↓
Spine
  ↓
Leaf
```
# Fat tree
Multiple SPINE and uplinks

Oversubscription Ratio
= Downlink Aggregate Bandwidth
  ÷ Uplink Aggregate Bandwidth

## 1:1, non-blocking fabric

Each Leaf:
- 4 server downlinks
- 4 Spine uplinks
- Each link speed is N
```
Downlink = 4 × 4 × N = 16N
Uplink   = 4 × 4 × N = 16N
16N : 16N = 1:1
```

## 2:1

Each leaf:
- 24 server downlinks
- 12 Spine uplinks

4 Leaf:
```
Downlink = 4 × 24 × N = 96N
Uplink   = 4 × 12 × N = 48N
96N : 48N = 2:1
```
## Blocking and non-blokcing
|Type|Ratio|
|---|---|
|Non-blocking|1:1|
|Oversubscribed / Blocking|2:1, 3:1, 3:2|
|Highly Oversubscribed|higher ratio|

# Dragonfly
One big fabic, divided to multiple groups, leaf-spine for each group, Global links between the groups.

```
Group A ───── Group B
   │  \         / │
   │   \       /  │
   │    Group C   │
   |       |      |
   └──── Group D ─┘
```

# 3D Torus

Every switch has two connections on each of the thress dimentions. 6 neighbors in total

Example:
One 36 ports switch has 18 ports for server connection. 18 ports for 6 neighbor swtich connection. 3 links to each neighbor.

# Adaptive Routing
AR, Adaptive routing, knows ECMP, checks for link congestion.

# Credit Loop
InfiniBand uses credit based flow control.
Logic:
```
Receiver has Buffer available
        ↓
Report credit to upper layer
        ↓
Sender get Credit before forwarding
```

Credit loop, each swtich waits for upper layer's credit in a loop. `A → B → C → D → A` 

Normal fowarding path is `Leaf → Spine → Leaf`, when a link/leaf failed, forwarding path becoms `Leaf → Spine → Leaf → Spine → Leaf`. This might cause the credit loop.

## Up/Down Routing
Up/Down routing avoid credit loop issue

```
Permit：Up
Permit：Down
Permit允许：Up → Down
Deny：Down → Up
```

