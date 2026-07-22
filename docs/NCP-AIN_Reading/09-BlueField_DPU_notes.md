# BlueField main components 
- BlueField DPU
- BlueField SuperNIC

# BlueField DPU
Data center infrastructure on a Chip

It the past the infrastructure services(network, storage data processing .etc) are processed by CPU. 

DPU seperates and isolates these service from host CPU. Use prupose-built hardware to accelerate these. 

BlueField integrated several accelerator on network, security and storage. 

## DPU structure

```
BlueField DPU
├── High-speed NIC
├── ARM CPU cores
├── Packet processing pipeline
├── Crypto accelerators
├── Storage accelerators
├── Memory
└── Independent operating environment
```

Before DPU:
```
Host CPU
├── Application
├── Virtual switching
├── Firewall
├── Encryption
└── Storage processing
```

With DPU
```
Host CPU
└── Application

DPU
├── Virtual switching
├── Firewall
├── Encryption
└── Storage processing
```

## DPU isolation
Differentc with normal SmartNIC
Host and DPU is in different trust domain.
```
+---------------- Host Domain ----------------+
| Host OS                                     |
| Applications                                |
| Containers / VMs                            |
+---------------------------------------------+

+---------------- DPU Domain -----------------+
| Infrastructure OS                           |
| Network policy                              |
| Firewall                                    |
| Storage control                             |
| Telemetry                                   |
+---------------------------------------------+
```
DPU's security policy still works when the HOST OS is under attack.

```
NIC
= Network adapter

SmartNIC
= Network adapter+, handles some tasks 

DPU
= Small infrastructure service host + high speed network adapter

SuperNIC
= High proformence smart NIC for AI GPU
```

# BlueField SuperNIC
Focus on AI cluster high speed communication
```
GPU Node A
     ↕
AI Fabric
     ↕
GPU Node B
```
SuperNIC's core tasks:
- RoCE
- High speed GPU-to-GPU communication
- Congestion control
- Telemetry
- Packet reordering
- Programmable I/O path

## Difference between SuperNIC and DPU

BlueField DPU focus on infra service
```
Host / Tenant
     ↓
DPU
├── Network virtualization
├── Security
├── Encryption
├── Storage virtualization
├── Infrastructure management
└── Telemetry
     ↓
External network / storage
```
- Cloud infrastructure
- Tenant isolation
- Security
- Storage
- Virtual networking
- Host infrastructure offload

BlueField SuperNIC focus on AI compute network
```
GPU
 ↓
SuperNIC
 ↓
RoCE Ethernet Fabric
 ↓
SuperNIC
 ↓
GPU
```
- GPU-to-GPU traffic
- RoCE
- AI backend network
- High throughput
- Low latency
- Congestion-aware networking

# DOCA
NVIDIA DOCA originally stands for Data Center Infrastructure-on-a-Chip Architecture.

DOCS is BlueField's development and operational platform
- CUDA gives software access to GPU
- DOCA gives software access to DPU

DOCA software stack
```
DOCA Applications
        ↑
DOCA Services
        ↑
DOCA Libraries
        ↑
DOCA Drivers
        ↑
BlueField Hardware
```

DOCA Deivers, identify and control BlueField HW.
```
Software
   ↓
Driver
   ↓
Hardware
```

DOCA Libraries, API
- Crypto
- RegEx
- IPsec
- Compression/GZIP
```
application
    ↓
DOCA API
    ↓
hardware accelerator
```

DOCA Services

- Telemetry
- Time synchronization
- Orchestration
- Host-based networking

DOCA Applications
- Firewall
- Network function
- Storage service
- Security inspection
- Telemetry application
- AI data analysis
- Telecom application

DOCA Runtime, for operational and deployment
```
DOCA Runtime
├── Drivers
├── Runtime libraries
├── Management tools
├── Configuration utilities
└── Telemetry agents
```

DOCA Devel, for development
```
DOCA Devel
├── Everything in Runtime
├── Headers
├── Compiler tools
├── SDK
├── Sample code
├── Benchmarks
└── Reference applications
```

# BlueField in AI DC
Full path
```
GPU
 ↓
BlueField SuperNIC / ConnectX NIC
 ↓
Leaf Switch
 ↓
Spine Switch
 ↓
Leaf Switch
 ↓
BlueField SuperNIC / ConnectX NIC
 ↓
GPU
```

Task for differentc parts in Spectrum-X system
- GPU # Execute AI computation
- SuperNIC # Connect GPU server to AI fabric
- Spectrum Switch # Forward traffic across fabric
- DPU # Offload host infrastructure services
- DOCA # Develop and operate DPU-accelerated services

For memory
```
Application / AI Framework
          ↓
         CPU
          ↓
         GPU
          ↓
   BlueField SuperNIC
          ↓
  Ethernet / RoCE Fabric
          ↓
   BlueField SuperNIC
          ↓
         GPU

Meanwhile:

DPU
├── Network offload
├── Security offload
├── Storage offload
├── Isolation
└── Infrastructure services

DOCA
└── Software framework controlling DPU capabilities
```
