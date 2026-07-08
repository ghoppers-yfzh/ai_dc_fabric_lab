# AI Infrastructure Logical Planes

This diagram shows an AI infrastructure environment as a set of logical planes.

It is not tied to one vendor or one physical topology. The goal is to provide a reusable architecture view for design discussion, validation planning, and troubleshooting.

```mermaid
flowchart TB
    users[External Users / Applications]
    ingress[API Ingress / Load Balancer / Gateway]

    subgraph mgmt[Management Plane]
        ssh[SSH / Admin Access]
        monitoring[Monitoring / Logging / Telemetry]
        sot[Source of Truth / Inventory]
        registry[Image Registry]
    end

    subgraph k8s[Kubernetes / Platform Control Plane]
        api[Kubernetes API]
        dns[DNS]
        scheduler[Scheduler]
        ingressctrl[Ingress Controller]
    end

    subgraph compute[Compute Plane]
        gpu1[GPU Worker 01]
        gpu2[GPU Worker 02]
        gpuN[GPU Worker N]
    end

    subgraph roce[Ethernet / RoCE Fabric]
        leaf1[RoCE Leaf]
        leaf2[RoCE Leaf]
        spine1[RoCE Spine]
        spine2[RoCE Spine]
    end

    subgraph ib[InfiniBand Fabric]
        ibleaf1[IB Leaf]
        ibleaf2[IB Leaf]
        ibspine[IB Spine]
        sm[Subnet Manager / UFM]
    end

    subgraph storage[Storage Plane]
        nvme[NVMe-oF Target]
        obj[Object Storage / Model Artifacts]
    end

    users --> ingress
    ingress --> ingressctrl
    ingressctrl --> api

    api --> gpu1
    api --> gpu2
    api --> gpuN

    gpu1 --- leaf1
    gpu2 --- leaf2
    gpuN --- leaf2
    leaf1 --- spine1
    leaf1 --- spine2
    leaf2 --- spine1
    leaf2 --- spine2

    gpu1 --- ibleaf1
    gpu2 --- ibleaf2
    gpuN --- ibleaf2
    ibleaf1 --- ibspine
    ibleaf2 --- ibspine
    sm --- ibleaf1
    sm --- ibleaf2
    sm --- ibspine

    gpu1 --> nvme
    gpu2 --> nvme
    gpuN --> nvme
    gpu1 --> obj
    gpu2 --> obj
    gpuN --> obj

    monitoring -. observes .-> mgmt
    monitoring -. observes .-> k8s
    monitoring -. observes .-> compute
    monitoring -. observes .-> roce
    monitoring -. observes .-> ib
    monitoring -. observes .-> storage

    sot -. documents .-> compute
    sot -. documents .-> roce
    sot -. documents .-> ib
    registry --> gpu1
    registry --> gpu2
    registry --> gpuN
```

## How to Use This Diagram

Use this diagram to explain that AI infrastructure is not only a GPU problem.

A production-like AI platform usually needs:

- a management plane for access, inventory, images, and observability
- a platform control plane for workload scheduling and service exposure
- a compute plane for GPU workers
- one or more high-performance fabrics for GPU communication
- a storage plane for model artifacts, checkpoints, and datasets
- validation that connects network state to workload behavior

## Validation Mapping

| Plane | Example Validation |
|---|---|
| Management | SSH access, inventory accuracy, image registry access |
| Kubernetes / platform | node readiness, CNI, service and ingress reachability |
| Compute | GPU visibility, NIC visibility, NUMA/topology awareness |
| RoCE fabric | MTU, QoS, PFC, ECN, RDMA tests, NIC counters |
| InfiniBand fabric | Subnet Manager, GUID/LID discovery, P_Key, UFM events |
| Storage | model load test, checkpoint read/write, NVMe-oF path validation |
| Observability | logs, counters, alerts, topology and failure-domain views |
