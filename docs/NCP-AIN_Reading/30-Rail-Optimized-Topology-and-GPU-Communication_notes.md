# Scale-up vs Scale-out
## Scale-up
GPU communication in the same system.

For example, a HGX/DGX system which has lots of GPU

```
        NVSwitch Fabric
       /   |   |   \
    GPU0 GPU1 GPU2 GPU3



GPU0
  │
NVLink
  │
NVSwitch
  │
GPU1
```

## Scale-out

GPU communitcation cross different systems


```
GPU
 │
PCIe / GPUDirect RDMA
 │
HCA / SuperNIC
 │
InfiniBand / RoCE
 │
HCA / SuperNIC
 │
PCIe / GPUDirect RDMA
 │
GPU
```

| Scope                    | Typical technology |
| ------------------------ | ------------------ |
| Scale-up                 | NVLink / NVSwitch  |
| Scale-out                | InfiniBand / RoCE  |
| GPU → NIC optimized path | GPUDirect RDMA     |

# GPU Direct RDMA

GPU Direct RDMA bypass "Unnecessary CPU host-memory bounce buffering."
```
GPU Memory
     ↕
PCIe peer-to-peer
     ↕
NIC / HCA
```

# PCIe topology

For example:
```
CPU Socket 0
   │
PCIe Root Complex
   ├── GPU0
   └── HCA0
```

The GPU to HCA communication goes via the same PCIe hierarchy which is ideal
```
GPU0
  ↓
same PCIe hierarchy
  ↓
HCA0
```

In another example, GPU0 to HCA0 goes `CPU socket > NUMA > PCIe root complex`, which is not ideal:
```
CPU0
 ├── GPU0

CPU1
 └── HCA0
```

NV CMD to check:
- `lspci -tvvv`
- `nvidia-smi topo -m`


# NCCL
NCCL is a `collective communication library` for GPU communication

NCCL implements GPU collective operations such as:

```text
AllReduce
AllGather
ReduceScatter
Broadcast
```


Fast GPUs wait for slow communication, training iteration takes longer

```
GPU0 communication = 8 ms
GPU1 communication = 8 ms
GPU2 communication = 8 ms
GPU3 communication = 25 ms


everybody waits for slow participant
             ↓
iteration ≈ 25 ms
```

# Rail
Rail = across servers, the corresponding network interface/HCA locality is connected consistently into the same fabric plane.

Example, each GPU server has 4 HCA
```
           Server01        Server02        Server03

Rail 0       HCA0 ---------- HCA0 ---------- HCA0
              │              │              │
              +--------- Leaf / TOR 0 -------+

Rail 1       HCA1 ---------- HCA1 ---------- HCA1
              │              │              │
              +--------- Leaf / TOR 1 -------+

Rail 2       HCA2 ---------- HCA2 ---------- HCA2
              │              │              │
              +--------- Leaf / TOR 2 -------+

Rail 3       HCA3 ---------- HCA3 ---------- HCA3
              │              │              │
              +--------- Leaf / TOR 3 -------+



Rail 0
=
node01 HCA0
node02 HCA0
node03 HCA0
node04 HCA0


Node01      Node02      Node03
 |            |           |
 | Rail 0     | Rail 0    |
 +============+===========+

 | Rail 1     | Rail 1    |
 +============+===========+

```

## PCIe BDF
PCIe BDF, Bus:Device.Function

Rail-optimized, for each server:
```
HCA0 BDF = 0000:04:00.0
HCA1 BDF = 0000:09:00.0
```

```
Node01
0000:04:00.0 → TOR-A
0000:09:00.0 → TOR-B

Node02
0000:04:00.0 → TOR-A
0000:09:00.0 → TOR-B

Node03
0000:04:00.0 → TOR-A
0000:09:00.0 → TOR-B

Node04
0000:04:00.0 → TOR-A
0000:09:00.0 → TOR-B
```

When the connection is wrong, the cluster still works, but performance/predictability/topology symmetry are impacted.

To validate, `ibdiagnet --rail_validation`, it check if the PCIe BDF matchesfor the compute-node HCAs connected to the same ToR.

```
Discover HCA
   ↓
Determine server / node
   ↓
Read PCIe BDF
   ↓
Determine connected TOR
   ↓
Group HCAs by TOR
   ↓
Compare BDF
```

Output file: `ibdiagnet2.rails`


Regex filter, only put mathces HCA/Compute Nodes in the rail report/validation:
```
ibdiagnet --rail_validation \
  --rail_validation_opt regex='compute[0-9]+'
```


# Summary

| Technology                    | Scope / Purpose                                     |
| ----------------------------- | --------------------------------------------------- |
| **NVLink**                    | High-speed GPU-to-GPU interconnect                  |
| **NVSwitch**                  | Switching fabric for NVLink GPUs                    |
| **GPUDirect RDMA**            | Direct GPU-memory ↔ RDMA-device data path           |
| **InfiniBand**                | Scale-out RDMA fabric                               |
| **RoCE**                      | RDMA over Ethernet scale-out fabric                 |
| **NCCL**                      | GPU collective communication library                |
| **Rail**                      | Corresponding HCA/network path across compute nodes |
| **Rail-optimized topology**   | Consistent HCA/PCIe locality → TOR connectivity     |
| `ibdiagnet --rail_validation` | Detect rail cabling/BDF inconsistency               |
| `ibdiagnet2.rails`            | Rail-validation detail output                       |




