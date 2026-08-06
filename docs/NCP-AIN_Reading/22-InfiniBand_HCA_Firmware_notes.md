# HCA Hardware
HCA, Host Channel Adapter connects device to IB Fabric

```
Application / NCCL / MPI
          ↓
       RDMA Verbs
          ↓
   Queue Pair / Work Request
          ↓
          HCA
          ↓
 InfiniBand or RoCE Fabric
```

Three layers on HCA
- Driver runs in linux RAM
- Firmware stores/runs on HCA
- Hardware is the ConnectX chip, Flash, port .etc

Firmware instruct the hardware:
- Initilize device
- Handle Queue Pair
- Excute DMA
- Manage port
- Handle datagram
- Uninstall hardware
- Responce to driver request

# Some tools

| Tool| Primary Purpose| Directly Flashes Firmware |
|---|---|---|
| `lspci`| Discovers PCIe devices, adapter models, and PCI BDF addresses|No |
| `ibv_devinfo`| Displays RDMA device information, current firmware version, and port details |        No |
| `mst`| Creates and displays MFT device access paths|No |
| `flint` / `mstflint`| Queries firmware properties and flashes `.bin` firmware images|Yes |
| `mlxfwmanager`| Scans devices, queries firmware information, and performs firmware upgrades  |Yes |
| `mlxfwreset`| Resets the device and activates the newly flashed firmware|No |
| `ibstat`| Checks InfiniBand devices, port status, and firmware versions|No |



PSID, Parameter Set Identification

# Upgrade process
## Step 1, Identify PCIe device
`lspci` and `lspci -nn | grep -Ei 'Mellanox|NVIDIA'`

Dual ports HCA might showing as multiple function whcih belongs to same adapter. 

## Step2, Setup device mapping
Check RDMA device
- `ibv_devices`
- `ibv_devinfo`
- `ibdev2netdev`

Check network port, `ethtool -i <interface>`

Device mapping:
```
PCI BDF
   ↕
MST Device
   ↕
RDMA Device
   ↕
Linux Network Interface
```
Example:
```
03:00.0
   ↕
/dev/mst/mt4123_pciconf0
   ↕
mlx5_0
   ↕
ens3f0np0
```

This is important because one GPU server might has multiple HCA, ports, mlx5_x, PCI function

## Step3, Start MST
Start MST
```
sudo mst start
sudo mst status -v
```
`mst start` loads the access module, create MFT device under `/dev/mst/`

Example:
```
/dev/mst/mt4123_pciconf0
/dev/mst/mt4123_pciconf1
```

## Step4, Check identity
`sudo flint -d /dev/mst/mt4123_pciconf0 query`

And/Or
`sudo mlxfwmanager \
  -d /dev/mst/mt4123_pciconf0 \
  --query`

Record:
```
PSID
Part Number
Current FW Version
Device Type
GUID / MAC
Expansion ROM Version
```

## Step5, Download correct firmware
Confirm the following:
- Product family
- Protocol
- Part Number
- PSID
- OEM or NVIDIA retail


## Step6, Check the image

`sudo flint -i <firmware-image.bin> query`

Example:
```
sudo flint \
  -i fw-ConnectX6-rel-20_42_1000-MCX654106A-HCA.bin \
  query
```

Compare:
```
HCA PSID   == Firmware Image PSID
HCA Family == Firmware Image Family
Target FW  >  Current FW
```

## Step7, Install
`flint -d <device> -i <image.bin> burn`

-d = device
-i = image
b  = burn

Example:
```
flint \
  -d /dev/mst/mt4123_pciconf0 \
  -i fw-ConnectX6-<version>-<model>.bin \
  burn
```

## Step8, Reset
New Image is installed in HCA Flash, however HCA is still running on the old firmware.

```
Firmware Burn
      ↓
HCA Reset
      ↓
Driver Reinitialisation
      ↓
New Firmware Running
```

Check
```
sudo mlxfwreset \
  -d /dev/mst/mt4123_pciconf0 \
  query
```

Reset
```
sudo mlxfwreset \
  -d /dev/mst/mt4123_pciconf0 \
  reset
```

## Verification
`ibstat`
- CA name
- Firmware Version
- Node GUID
- Port GUID
- Port State
- Physical State
- Link Rate

### Firmware identity check
- FW Version
- PSID
- Part Number
- Expansion ROM
```
sudo flint -d /dev/mst/mt4123_pciconf0 query

sudo mlxfwmanager \
  -d /dev/mst/mt4123_pciconf0 \
  --query
```

### RDMA and port
- `ibstat`
- `ibv_devinfo`
- `ibdev2netdev`

Confirm:
- Port State: Active
- Physical State: LinkUp
- Expected link rate
- Correct mlx5 device mapping

### Linux and driver
- `ethtool -i <interface>`
- `ip -br link`
- `devlink dev show`


### Fabric
- iblinkinfo
- ibdiagnet

# Summary
Upgrade process:
- Identify
- Query
- Match
- Burn
- Validate

Tools:
```
lspci / ibv_devinfo
        ↓
mst status
        ↓
flint query / mlxfwmanager --query
        ↓
flint burn
        ↓
mlxfwreset
        ↓
ibstat / RDMA test
```
