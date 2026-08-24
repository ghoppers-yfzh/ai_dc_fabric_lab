# Network Operator
For normal k8s pod
```
Pod
 |
 | eth0
 v
Primary CNI
 |
 v
Linux network
 |
 v
NIC
```
For GPU distributed training
```
Pod
 |
 +--- eth0 --> Normal Kubernetes network
 |
 +--- net1 --> High-speed network
                   |
                   v
                RDMA NIC
                   |
                   v
              RoCE / IB Fabric
```

Network Operator solves lifecycle/orchestration problem for kubernetes:
- Does Host have NVIDIA NIC installed？
- Is Driver / RDMA stack installed?
- Which NIC can be used by Pod?
- How does Kubernetes Scheduler know the Node has RDMA resource?
- How does Pod get a second highspeed NIC?
- How to allocate SR-IOV VF / RDMA resource?
- How to deploy these componenets on thousands of GPU servers?

## Network Operator ≠ GPU Operator
**GPU Operator** manages: GPU driver, CUDA/GPU software stack, GPU device lifecycle

**Network Operator** manages: NIC driver, RDMA、device plugins, secondary network, SR-IOV .etc


GPU Operator -> GPU

Network Operator -> NIC / RDMA

GPUDirect RDMA：
```
GPU
 │
 │ GPUDirect RDMA
 │
NIC
 │
 └──── RoCE / InfiniBand
```

## What does Operator do?
The traditional way:
```
100 x GPU server

SSH
 ↓
install DOCA-OFED
 ↓
configure SR-IOV
 ↓
install RDMA plugin
 ↓
configure CNI
 ↓
verify
```

The Network Operator:
```
NicClusterPolicy
       |
       v
Network Operator Controller
       |
       +---- DOCA-OFED
       |
       +---- RDMA Device Plugin
       |
       +---- SR-IOV Device Plugin
       |
       +---- Multus
       |
       +---- CNI plugins
       |
       +---- IPAM
```

You declare the desired networking state; the Operator reconciles the cluster toward that state.

```
NicClusterPolicy
      ↓
Operator
      ↓
Kubernetes Nodes
```



# NicClusterPolicy
K8S doesn't know this network operator. NicClusterPolicy defines it so the cluster can use.

The file:
```
spec:
  rdmaSharedDevicePlugin:
    config: |
      {
        "configList": [
          {
            "resourceName": "rdma_shared_device_a",
            "rdmaHcaMax": 63,
            "selectors": {
              "ifNames": ["ens1f0"]
            }
          }
        ]
      }
```
It defines:
```
Find interface ens1f0
        ↓
if it is RDMA capable
        ↓
RDMA Shared Device Plugin
        ↓
advertise Kubernetes resource
        ↓
rdma_shared_device_a
```

## CRD and NicClusterPolicy

After Helm install Network Operator, it will install Kubernetes API expansion, for example `NicClusterPolicy`.

CRD =  Define a new type of Kubernetes object

Then you create:
```
apiVersion: mellanox.com/v1alpha1
kind: NicClusterPolicy
metadata:
  name: nic-cluster-policy
```
This is `CR = Custom Resource`

```
CRD
↓
defines NicClusterPolicy

NicClusterPolicy
↓
one actual desired-state object
```

Where is the Operator:
```
CRD
 │
 │ defines
 ▼
NicClusterPolicy
 │
 │ user creates
 ▼
NicClusterPolicy object
 │
 │ watched by
 ▼
NVIDIA Network Operator
 │
 ├── deploy RDMA plugin
 ├── deploy OFED driver
 ├── deploy SR-IOV components
 └── configure secondary networking
```


## Device Plugiin
For a worker
```
worker01

ens1f0
  |
ConnectX-7
  |
RDMA capable
```

Linux host knows this NIC, but Kubernetes Scheduler doesn't know worker01 has a RDMA capable NIC.

Device Plugin does:
```
ConnectX NIC
      ↓
RDMA Shared Device Plugin
      ↓
kubelet
      ↓
Node allocatable resources
```

rdma/rdma_shared_device_a: 63

Scheduler arranges resouce:
```
resources:
  requests:
    rdma/rdma_shared_device_a: 1
```

Device plugin make hardware to Kubernetes schedulable resource.

## rdmaHcaMax: 63 
In the previous YAML
```
"resourceName": "rdma_shared_device_a",
"rdmaHcaMax": 63
```

It does not mean NIC has 63 physical RDMA NIC. It is the number for shared RDMA resource.

## RDMA Shared Device vs SR-IOV

SR-IOV is a hardware virtualization technology.

PF = Physical Function
VF = Virtual Function

```
Physical NIC
     │
     │
    PF
     │
 +---+---+---+
 │   │   │   │
VF1 VF2 VF3 VF4
```
VFs can be allocated to VMs, Containers, Kubernetes Pods.


|                          | RDMA Shared Device| SR-IOV|
| ------------------------ | -------------------- | ------------------ |
| Hardware                 | PF/HCA shared        | Usually set VF            |
| Pod isolation            | Week                   | Strong                 |
| Device ownership         | shared               | close to dedicated      |
| Configuration complexity | Low                   | High                 |
| Resource                 | shared RDMA resource | VF/device resource |
| Typical idea             | HCA shared by multiple Pod| Every Pod receives VF       |


```
RDMA Shared
= share the HCA

SR-IOV
= slice the NIC
```

## Multus
Device Plugin: Set Pod hardware resource

Multus: Set Pod additional network interface

```
Pod
 |
 +--- eth0
 |     ↓
 |   Calico/Cilium
 |     ↓
 |   Kubernetes network
 |
 +--- net1
       ↓
     Multus
       ↓
     Macvlan/SR-IOV/IPoIB
       ↓
     AI backend network
```

For AI workload:
- eth0 → management / Kubernetes services
- net1 → training / RDMA network


```
                       Pod
                        |
             +----------+----------+
             |                     |
      Network attachment       Resource request
             |                     |
           Multus              Device Plugin
             |                     |
       secondary CNI             kubelet
             |                     |
           net1               RDMA resource
```




Networking path
```
Pod annotation
→ Multus
→ CNI
→ interface
```

Resource path
```
Pod resources.requests
→ kubelet
→ device plugin
→ RDMA/SR-IOV resource
```



Map for the whole compoenet
```
                NicClusterPolicy
                       |
                       v
              Network Operator
                       |
       +---------------+----------------+
       |               |                |
       v               v                v
   DOCA-OFED       Device Plugin    Secondary Network
       |               |                |
       |        +------+-------+        |
       |        |              |        |
       |   RDMA Shared      SR-IOV    Multus
       |        |              |        |
       |        |              |      CNI
       |        |              |        |
       +--------+--------------+--------+
                       |
                       v
                ConnectX / BlueField
```

## Network Attachment vs Resource Request

`Network Attachment` is for set a `net1` in the Poad, gives it an IP so it can transmit traffic.

The logic is:
```
Pod
 │
 │ asks for secondary network
 ▼
Multus
 │
 ▼
CNI
 │
 ▼
create net1
 │
 ▼
Pod gets IP/interface
```

`Resource Request` solve the problem of
- Whether there is RDMA device on worker
- How much can be allocated to the Pod
- Which node should scheduler allocate the Pod to

The logic is:
```
Pod requests RDMA resource
        │
        ▼
Kubernetes Scheduler
        │
        ▼
Which node has this resource?
        │
        ▼
worker01
        │
        ▼
Device Plugin / kubelet
        │
        ▼
allocate RDMA resource
```

# NFD
K8s' hardware inventory / labeling.
For example:
```
worker01
 ↓
NFD scans hardware
 ↓
Node labels
 ↓
"This node has NVIDIA/Mellanox device"
```
values.yaml
```
nfd:
  enabled: true
```

