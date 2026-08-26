# BlueField

BlueField is more than a NIC

```
                 BlueField
                    |
        +-----------+-----------+
        |                       |
   ConnectX NIC              Arm CPU
   networking              + services
   hardware                + DOCA apps
        |
   acceleration
   RDMA / RoCE
   eSwitch
   packet processing
```

BlueField covers:
- NIC capability
- embeded Arm system
- hardware acceleration engines


# DPU vs SuperNIC

```
Host Server
    |
   PCIe
    |
+------------------------+
| BlueField DPU          |
|                        |
| ConnectX networking    |
| Arm CPU                |
| acceleration engines   |
|                        |
| OVS / security         |
| storage offload        |
| network services       |
+------------------------+
        |
      Network
```

Tasks for DPU:
- virtual switching
- security
- firewall / isolation
- storage networking
- network processing
- infrastructure services

DPU = infrastructure offload


For SuperNIC:
- high-performance accelerated network path
- GPU cluster connectivity
- RoCE / networking acceleration

Working path in AI cluster
```
GPU
 |
PCIe
 |
SuperNIC
 |
400G / 800G Ethernet
 |
Spectrum-X fabric
 |
SuperNIC
 |
GPU
```


BlueField DPU SKU → DPU mode default

BlueField SuperNIC SKU → NIC mode default

# NIC mode vs DPU mode
The question is, who owns the NIC resource and datapath

## NIC mode
Host control the NIC
```
Host CPU / Host OS
        |
        | controls
        ↓
     BlueField
        |
   ConnectX-like NIC
        |
      Network
```

External host >> directly uses BlueField >> BlueField behaves like ConnectX NIC


## DPU mode
Embedded Arm system owns/manages NIC resources and datapath.

```
        Host OS
           |
         PCIe
           |
   +-------+-------+
   |   BlueField   |
   |               |
   |    Arm OS     |
   |       |       |
   |   controls    |
   |       ↓       |
   | NIC resources |
   |   / datapath  |
   +-------+-------+
           |
        Network
```


Mode changes should be treated as maintenance operations. The control ownership will be changed.

Related:
- device reset
- firmware state
- BMC
- UEFI
- power cycle
- driver behavior
- host connectivity

# DOCA
DOCA is the whole software framework

The current NVIDIA definations for DOCA framework:
```
DOCA Framework
│
├── DOCA SDK
│   ├── libraries
│   ├── APIs
│   └── development framework
│
├── Drivers / networking software
│
└── BlueField platform software
```

The DOCA Host is installed on the host, ubuntu server for example.

## DOCA profiles
There are different DOCA installation profiles:
- doca-all
- doca-networking
- doca-ofed
- doca-roce
- doca-host-basic


| Profile           | Description                      |
| ----------------- | ---------------------------- |
| `doca-all`        | Full DOCA stack                    |
| `doca-networking` | Accelerated networking, ConnectX for example    |
| `doca-ofed`       | MLNX_OFED driver/tools |
| `doca-roce`       | Only for Ethernet + RoCE/RDMA    |
| `doca-host-basic` | Even smaller networking footprint   |


Use cases:
| Scenarios | Profiles|
| --- | --- |
| I have a BlueField DPU and want full DOCA capability. | doca-all |
| I have ConnectX and mainly need accelerated networking. | doca-networking |
| We previously used MLNX_OFED. I want equivalent drivers/tools, not additional DOCA functions. | doca-ofed |
| This host only needs Ethernet RDMA / RoCE. | doca-roce |

# Operational workflow

Mental path:
1. Hardware
2. Firmware
3. Operating mode
4. Host software
5. Driver/RDMA
6. Performance

## Step1 What hardware do I have?

`lspci | grep -i -E 'mellanox|nvidia'`

## Step2 Can MFT see the hardware?

`sudo mst start` and `sudo mst status`

```
PCI device
    ↓
MST device mapping
    ↓
firmware tools
```

## Step3 What firmware is running?
`sudo mlxfwmanager` or `flint` or `mstflint`

This checks the firmware version and status.

## Step4 Does Linux RDMA stack see it?
`ibv_devinfo` checks:
- RDMA device name?
- Firmware?
- Port?
- State?
- Link layer?

link_layer can be:
- Ethernet
- InfiniBand


## Some other checks

`rdma link` checks RDMA device to Linux network interface mapping

`ethtool -i ens5f0np0` checks the following:
- driver
- version
- firmware-version
- bus-info

`ib_write_bw` and `ib_write_lat` check bandwidth and latency


The logic:
```
lspci
  ↓
Hardware exists

mst / mlxfwmanager
  ↓
Firmware manageable

ethtool
  ↓
Driver attached

ibv_devinfo
  ↓
RDMA device healthy

rdma link
  ↓
RDMA ↔ netdev relationship

ib_write_bw / ib_write_lat
  ↓
Actual RDMA functionality/performance
```

## Check BlueField Mode
Example:
```
curl -k -u root:'<PASSWORD>' \
  -X GET \
  https://<bmc_ip>/redfish/v1/Systems/Bluefield/Oem/Nvidia
```

Note: Mode is a BlueField platform state which is not host Linux interface config.

# Summary

DPU vs SuperNIC

```
                 BlueField
                    |
          +---------+---------+
          |                   |
       DPU SKU           SuperNIC SKU
          |                   |
     DPU Mode              NIC Mode
      default              default
          |                   |
     Arm active          host controls NIC
          |
Arm controls NIC /
datapath
```

DOCA profile selection:
```

Full BlueField
    → doca-all

Networking focused
    → doca-networking

MLNX_OFED-like
    → doca-ofed

RoCE only
    → doca-roce
```

Operational troubleshooting:
```
lspci
   ↓ hardware

mst / mlxfwmanager
   ↓ firmware

ethtool
   ↓ Linux driver

ibv_devinfo / rdma link
   ↓ RDMA

ib_write_bw / ib_write_lat
   ↓ performance
```

