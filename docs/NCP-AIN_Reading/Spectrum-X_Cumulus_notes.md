# Cumulus Basics
cumulus-linux-5.x.y-mlx-amd64
- 5: major release
- x: minor release
- y: maintenance release
- mlx: platform
- amd64: architecture

## Installation
ONIE auto provisioning.
MGMT to LAN and get IP via DHCP.
DHCP option 114 provides image location which is on a web server
ONIE will get the image, install on the switch and reboot

## Package management
The linux way
sudo -E apt-get update
- ISSU supported
- Cross major release upgrade is not supported
- Upgrade only support two newer release from the current

Commands:
```
# check installed packages
nv show platform software installed
# update all the installed packages to the latest version
nv action upgrade system packages to latest use-vrf default dry-run
# Check if reboot is required
nv show system reboot required
# Setup package source
nv action fetch system packages key http://<url>/debian-archive-bookworm-stable.asc
```
## Login and init setup

Login method
- Console # default baud rate 115200
- Out of band - eth0 # This is the management port
- Inband - SSH # password auth or key auth

Account
- root # No default password, direct login disabled
- cumulus # default password: cumulus

Commands:
```
# Setup eth0 dhcp
nv set interface eth0 ip address dhcp
nv config apply
# Setup timezone
nv set system timezone US/Eastern
nv config apply
```

## Factory Reset
Basic command 'nv action reset system factory-default'
Options:
- keep basic # Retains password policy, mgmt intf config, local user and roles, SSH config
- keep all-config # Retains all config
- keep only-files # Retains all system files and log files

## ZTP
Zero touch provisioning

ZTP excution order
1. Search local dir '/var/lib/cumulus/ztp for ztp script
2. Check for ztp script on an inserted USB drive
3. Attempts to retrieve a ZTP script via DHCP, the script must include the 'CUMULUS-AUTOPROVISIONING' marker

Commands:
```
# Enable ZTP for the next boot
nv action enable system ztp
# Disable ZTP for the next boot
nv action disable system ztp
# Manual run ztp from web server
nv action run system ztp url https://myserver/mypath/cumulus-ztp.sh
# Manual run ztp from local dir
nv action run system ztp url /home/cumulus/cumulus-ztp.sh
```
Some notes:
- The script must includes 'CUMULUS-AUTOPROVISIONING'
- All script output is logged in '/var/log/autoprovision'
- The script must return an exit code 0 upon success.

