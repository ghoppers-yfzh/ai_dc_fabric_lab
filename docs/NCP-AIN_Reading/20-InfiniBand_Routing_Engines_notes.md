# IB Routing Engines
Several InfiniBand routing engines may be configured on a network such as Min Hop, Up Down, Down Up, Fat Tree and more (see opensm). Up/Down (UpDn)  and Fat Tree are the most commonly used InfiniBand routing algorithms for Clos/fat tree networks.

```
Physical Topology
        ↓
Subnet Manager discovers topology
        ↓
Routing Engine calculates paths
        ↓
SM generates each switch's LFT
        ↓
LFT: Destination LID → Egress Port
```


# Min-hop
By default, system uses min-hop algorithm, it supports multiple different topology

Two phases:
1. Calculate the min hop to each node on every switch
2. Choose the port with min hop and generate the LFT

UpDn might return back to MinHop if root node can't be found.



# UpDn
Set ranks for switches

```
             Spine 1       Spine 2
             Rank 0        Rank 0
                \           /
                 \         /
                Leaf 1   Leaf 2
                Rank 1   Rank 1
                   |       |
                 Hosts   Hosts
```
Root is rank 0, moving towards root, is up, the other way is down.
Packet can not go up after going down.

Legit path:
- Up → Up → Down → Down
- Up → Down
- Down → Down
- Up → Up

# Fat Tree routing engine
Fat tree engine understand switch rank, upstream/downswtream port group.
It can set different source routing to different spines.

Different with the Ethernet ECMP which is on each routing nodes, Fat tree engine calculate the routes globally.

# Torus-2QoS
OpenSM's Torus-2QoS is designed for large scale 2D/3D Torus Fabric, need Qos enabled.
Torus-2QoS utilises dementions and VL/QoS.

# Dragonfly+
Dragonfly+ includes multiple groups
```
Group A
  Leaf + Spine island

Group B
  Leaf + Spine island

Group C
  Leaf + Spine island
```
Each group is a small tree fabric. Global links connect groups.

Global Link is the minimal Path between group A and group B.

When conguestion happens on the global link between GroupA and GroupB, it can pass over GroupC.
`Group A → Group C → Group B`, this is called `Min Hop + 1`

## Adaptive Routing
Adaptive routing is important for Dragonfly+, because of the limitation of glabal links between groups.

Adaptive routing calculate the routing based on current congestion state.
```
Direct path is free
    → Minimal Path

Direct path is congested
    → Non-minimal Path via intermediate group
```

## Virtual Lane Increment
```
Source Group
   |
   | VL0
   v
Intermediate Group
   |
   | switch to VL1
   v
Destination Group
```
VL changes after passing the intermediate group `VL0 resources → VL1 resources`

# Config UpDn
1. locate the SPINE swtich GUID by `ibswitches`
```
Switch : 0x506b4b0300abcdef ports 36 "IBSP07"
Switch : 0x506b4b0300123456 ports 36 "IBSP08"
Switch : 0x506b4b0300789012 ports 36 "IBLF01"
```
2. Create Root GUID file `/etc/opensm/root_guid.conf`, fill in the SPINE GUID, one line for each GUID
```
0x506b4b0300abcdef
0x506b4b0300123456
```
3. Config OpenSM `/etc/opensm/opensm.conf`
Set 
```
root_guid_file /etc/opensm/root_guid.conf
routing_engine updn
```
For creating config file `sudo opensm -c /etc/opensm/opensm.conf`

Specify config file `opensm -F /etc/opensm/opensm.conf`

4. Restart service `sudo service opensmd restart`

5. Validate status 
- `systemctl status opensm`
- `systemctl status opensmd`
- Check logs `grep -i updn /var/log/opensm.log` # UPDN tables configured on all switches
- Check Root GUID `grep -Ei 'root|rank' /var/log/opensm.log`
- Check switch LFT `ibroute <switch-lid>`

# Summary
```
Topology-aware routing
        =
Shortest/available paths
        +
Traffic distribution
        +
Deadlock avoidance
        +
Failure handling
```


## Routing Engine Summary

| Routing Engine | Suitable Topology | Primary Goal | Prevents Credit Loops | Load-Balancing Focus |
| --- | --- | --- | --- | --- |
| `minhop` | General-purpose or unknown topology | Select the minimum-hop path | No |              Limited |
| `updn` | Tree, Fat Tree, or hierarchical topology with loops | Restrict path direction using switch ranks | Yes | Moderate |
| `ftree` | Symmetric or near-symmetric Fat Tree | Optimize path distribution across the Fat Tree | Yes | Strong |
| `torus-2QoS` | 2D or 3D Torus | Provide deadlock-free routing for Torus topologies | Yes |    Topology-specific |
| `dfp` / `dfp2` | Dragonfly+ | Support minimal and non-minimal paths with adaptive congestion avoidance | Yes, using mechanisms such as VL separation | Strong |

### Easy-to-Remember Version

```text
MinHop   = Choose the shortest path only
UpDn     = Choose a short path, but never go Up again after going Down
Fat Tree = UpDn rules + Fat Tree load balancing
Torus    = Use dimensions and VLs to handle routing in a Torus
DFP      = Route by groups and allow detours when the direct path is congested
```



