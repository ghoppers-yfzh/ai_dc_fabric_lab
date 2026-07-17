# Agenda
- CMD type and workflows
- NVUE REST API
- Production-ready and Ansible automation

# NVUE CLI


Different types
- Monitoring
- Configuration management
- Action
- Configuration

Don't run both NVUE and linux commands to config switch

## Monitoring

- nv show acl
- nv show action
- nv show bridge
- nv show evpn

## Configuration management
- nv config apply
- nv config save
- nv config diff pending applied
- nv config replace config2.yml
- nv config history
- nv config detach
- nv config show

## Action
- nv action about
- nv action boot-next
- nv action change
- nv action clear
- nv action upload
- nv action delete

## Configuration
- nv set interface swp1 link spped 40G
- nv set router bgp autonomous-system 65000
- nv set nve vxlan source address 172.16.31.1
- nv unset mlag peer-ip
- nv unset interface swp3 ip address
- nv set interface swp3 -h

# NVUE workflow

1. Use the 'nv set/unset' cmd to stage or remove config change
2. Use the 'nv config diff' cmd to review staged changes
3. Use the 'nv config apply' or 'nv config detach' cmd to commit or detach staged changes

Commands:
'''
# Check current running config - default in yaml
nv config show
# Check current running config in NVUE commands format
nv config show -o commands
# Check config history
nv config history
# Compare against the applied configuration, 4 is the seq of the previous config version
nv config diff applied 4
# Apply a previous config version seq 3
nv config apply 3
# Filter show command output for state=up interface
nv show interface --filter state=up
# Reset config for factory default
nv config replace /usr/lib/python3/dist-packages/cue_config_v1/initial.yaml
nv config apply

# NVUE Rest API

```
      API Client                       CLI
         |                              |
HTTP Reverse Proxy Server       Bash NV CLI Client
          \                             /
           \                           /
            \                         /
                NVUE REST API Server
                NVUE Service
```
API type to NVUE CLI type
GET    --   nv show
POST   --   nv action / nv config
PATCH  --   nv set / nv config apply
DELETE --   nv unset

Examples for API calls:
# Basic auth
curl -u 'cumulus:PASSWD' -k -X GET https://192.168.200.2:8765/nvue_v1/interface/swp1/link/stats
# Get current config state with revision for 'startup', 'pending', 'operational', 'applied'
curl -k -u cumulus:PASSWD -X GET "https://192.168.200.2:8765/nvue_v1/?rev=applied&filled=false"


# Ansible automation
Architecture
'''
Control server
      |
Inventory file     
                     ------- Target node1
                    /
   Playbook     ---SSH ------- Target node2
                    \
                     ------- Target node3
'''
Concept Recap
- Inventory # Descript Hosts and Groups
- Modules   # Work unit dispacted to target node
- Task
- Playbook  # Run tasks

Ansible Galaxy can install NVIDIA NVUE collection
