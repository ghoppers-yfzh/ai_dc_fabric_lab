# What is OFED
OpenFabrics Enterprise Distribution

It is a RDMA stack installed on the server, including
- Driver
- RDMA kernel module
- User space
- RDMA Verbs API
- Mgmt and diagnostic tools
- Performance test tools

```
Application
NCCL / MPI / Storage / Database
                 |
                 v
RDMA API
libibverbs / librdmacm / UCX
                 |
                 v
User-space Provider
libmlx5
                 |
                 v
Linux RDMA Core
ib_core / rdma_cm
                 |
                 v
NVIDIA Driver
mlx5_ib / mlx5_core
                 |
                 v
ConnectX HCA / BlueField
                 |
                 v
InfiniBand or Ethernet/RoCE Fabric
```
OFED bridges applications, linux kernel and HCA hardware.

Linux provides RDMA driver and rdma-core, Inbox Driver.

NVIDIA's version, MLNX_OFED

# What is DOCA
DOCA is NVIDIA's software framework for BlueField, ConnectX, DPU and SuperNIC.
It includes
- DOCA libraries
- DOCA Flow
- DPA
- Acceleration libraries
- Networking services
- Security, storage, telementry components
- SDK

## DOCA-Host
DOCA-Host is a software packet installed on host server.

```
ConnectX / BlueField / SuperNIC
              |
              v
          DOCA-Host
              |
              v
     Choose different Installation Profiles
```

DOCA-OFED is a profile in DOCA-Host, it is a replacement for MLNX_OFED

Four different DOCA-Host Profiles:
doca-roce       = RoCE Only
doca-ofed       = Orignial MLNX_OFED
doca-networking = Full NVIDIA network 
doca-all        = Full DOCA


# Installation

Check process
```
# Current OFED version
ofed_info -s

# OS
cat /etc/os-release

# Kernel
uname -r

# Architecture
dpkg --print-architecture
uname -m

# NVIDIA/Mellanox adapters
lspci -nn | grep -Ei 'Mellanox|NVIDIA'

# Kernel headers
test -e /lib/modules/$(uname -r)/build \
  && echo "Kernel headers found" \
  || echo "Kernel headers missing"

# Compiler
gcc --version

# Secure Boot
mokutil --sb-state
```

Installation process
```
sudo dpkg -i <doca-host-repo-file>.deb
sudo apt update
sudo apt install -y doca-ofed

# When required for the selected deployment
sudo apt install -y mlnx-fw-updater

sudo /etc/init.d/openibd restart
sudo mst restart
```

Restart after installation `sudo /etc/init.d/openibd restart`

Validations:
- `ofed_info -s` validates OFED version
- `lspci -nn | grep -Ei 'Mellanox|NVIDIA'` validates PCI device
- `lsmod | grep mlx5` validates driver
- `rdma link`, `ibv_devices`, `ibv_devinfo` validate RDMA devices
- `ibstat` and `ibstatus` validate IB env
- `rdma link`, `ethtool -i <interface>`, `ip link show <interface>` check RoCE env

# Summary
OFED is not IB Fabric mgmt tool, it is installed on server.

```
DOCA
└── DOCA-Host
    ├── doca-roce
    ├── doca-ofed
    ├── doca-networking
    └── doca-all
```

In the data path
```
NCCL
  ↓
UCX / RDMA Verbs
  ↓
DOCA-OFED
  ↓
ConnectX / BlueField
  ↓
RoCEv2 or InfiniBand Fabric
```

Installation process
```
Inspect
→ Select
→ Remove/Upgrade
→ Install
→ Reload/Reboot
→ Validate
```
