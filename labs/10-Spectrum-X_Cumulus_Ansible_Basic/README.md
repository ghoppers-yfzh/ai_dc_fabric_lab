# LAB
## env check

Check and install NVIDIA NVUE collection
```
ubuntu@oob-mgmt-server:~$ ansible-galaxy collection list | grep -E 'nvidia.nvue|ansible.netcommon|ansible.utils'
ansible.netcommon                        6.1.3  
ansible.utils                            4.1.0  
ubuntu@oob-mgmt-server:~$ ansible-galaxy collection install nvidia.nvue
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Downloading https://galaxy.ansible.com/api/v3/plugin/ansible/content/published/collections/artifacts/nvidia-nvue-1.2.9.tar.gz to /home/ubuntu/.ansible/tmp/ansible-local-22896ac0q0lw/tmpvxsv3sz4/nvidia-nvue-1.2.9-vcy7hdec
Installing 'nvidia.nvue:1.2.9' to '/home/ubuntu/.ansible/collections/ansible_collections/nvidia/nvue'
nvidia.nvue:1.2.9 was installed successfully
'ansible.netcommon:6.1.3' is already installed, skipping.
'ansible.utils:4.1.0' is already installed, skipping.
ubuntu@oob-mgmt-server:~$ ansible-galaxy collection list | grep -E 'nvidia.nvue|ansible.netcommon|ansible.utils'
nvidia.nvue                              1.2.9  
ansible.netcommon                        6.1.3  
ansible.utils                            4.1.0  
ubuntu@oob-mgmt-server:~$ 
```
Check device name and ip
```
ubuntu@oob-mgmt-server:~$ grep -Ei 'spine|leaf' /etc/hosts
192.168.200.6 leaf01 leaf01.simulation
192.168.200.7 leaf02 leaf02.simulation
192.168.200.8 leaf03 leaf03.simulation
192.168.200.9 leaf04 leaf04.simulation
192.168.200.2 spine01 spine01.simulation
192.168.200.3 spine02 spine02.simulation
192.168.200.4 spine03 spine03.simulation
192.168.200.5 spine04 spine04.simulation
192.168.200.6 leaf01
192.168.200.7 leaf02
192.168.200.8 leaf03
192.168.200.9 leaf04
192.168.200.2 spine01
192.168.200.3 spine02
192.168.200.4 spine03
192.168.200.5 spine04
```
Create hosts and ansible.cfg file
```
ubuntu@oob-mgmt-server:~/ansible_lab$ cat hosts 
[spine_sw]
spine01 ansible_host=192.168.200.2
spine02 ansible_host=192.168.200.3
spine03 ansible_host=192.168.200.4
spine04 ansible_host=192.168.200.5

[leaf_sw]
leaf01 ansible_host=192.168.200.6
leaf02 ansible_host=192.168.200.7
leaf03 ansible_host=192.168.200.8
leaf04 ansible_host=192.168.200.9

[all:vars]
ansible_user=cumulus
ansible_password=Cumu1usLinux!
ansible_port=22
ansible_python_interpreter=/usr/bin/python3ubuntu@oob-mgmt-server:~/ansible_lab$ cat ansible.cfg 
[defaults]
inventory = ./hosts
host_key_checking = False
deprecation_warnings = False
interpreter_python = auto_silentubuntu@oob-mgmt-server:~/ansible_lab$ 
```
Check ansible config
```
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible --version
ansible [core 2.17.13]
  config file = /home/ubuntu/ansible_lab/ansible.cfg
  configured module search path = ['/home/ubuntu/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/ubuntu/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.10.12 (main, May 27 2025, 17:12:29) [GCC 11.4.0] (/usr/bin/python3)
  jinja version = 3.0.3
  libyaml = True
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-inventory --graph
@all:
  |--@ungrouped:
  |--@spine_sw:
  |  |--spine01
  |  |--spine02
  |  |--spine03
  |  |--spine04
  |--@leaf_sw:
  |  |--leaf01
  |  |--leaf02
  |  |--leaf03
  |  |--leaf04
```
Validate Ansible SSH
```
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible leaf01 -m ansible.builtin.ping
leaf01 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible all -m ansible.builtin.ping
leaf01 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
spine01 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
spine02 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
spine03 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
spine04 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
leaf02 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
leaf04 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
leaf03 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
Create firs playbook
```
ubuntu@oob-mgmt-server:~/ansible_lab$ cat get_nvue_interface.yml 
---
- name: Read interface information from leaf01
  hosts: leaf01
  gather_facts: false

  collections:
    - nvidia.nvue

  tasks:
    - name: Query all interfaces
      nvidia.nvue.command:
        commands:
          - "show interface"
        apply: false
      register: nvue_output

    - name: Display interface information
      ansible.builtin.debug:
        msg: "{{ nvue_output['message'] }}"ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
Validate and run playbook
```
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-playbook --syntax-check get_nvue_interface.yml

playbook: get_nvue_interface.yml
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-playbook get_nvue_interface.yml

PLAY [Read interface information from leaf01] *****************************************************************************************

TASK [Query all interfaces] ***********************************************************************************************************
ok: [leaf01]

TASK [Display interface information] **************************************************************************************************
ok: [leaf01] => {
    "msg": "Interface      Admin Status  Oper Status  Speed  MTU    Type      Remote Host             Remote Port        Summary                                   \n-------------  ------------  -----------  -----  -----  --------  ----------------------  -----------------  ------------------------------------------\nbond1          up            up           1G     9216   bond                                                                                           \nbond2          up            up           1G     9216   bond                                                                                           \nbond3          up            up           1G     9216   bond                                                                                           \nbr_default     up            up                  9216   bridge                                               IPv6 Address:  fe80::4638:39ff:fe22:17e/64\neth0           up            up           1G     1500   eth       oob-mgmt-switch-leaf-1  swp5               IPv4 Address:             192.168.200.6/24\n                                                                                                             Address type:                      primary\n                                                                                                             IPv6 Address:  fe80::4638:39ff:fe22:174/64\nlo             up            unknown             65536  loopback                                             IPv4 Address:                 10.0.1.12/32\n                                                                                                             IPv4 Address:                10.10.10.1/32\n                                                                                                             IPv4 Address:                  127.0.0.1/8\n                                                                                                             Address type:                      primary\n                                                                                                             Address type:                      primary\n                                                                                                             Address type:                      primary\n                                                                                                             IPv6 Address:                      ::1/128\nmgmt           up            up                  65575  vrf                                                  IPv4 Address:                  127.0.0.1/8\n                                                                                                             IPv4 Address:                  127.0.1.1/8\n                                                                                                             Address type:                      primary\n                                                                                                             Address type:                    secondary\n                                                                                                             IPv6 Address:                      ::1/128\npeerlink       up            up           2G     9216   bond                                                                                           \npeerlink.4094  up            up                  9216   sub                                                  IPv6 Address: fe80::4ab0:2dff:fea0:7e37/64\nswp1           up            up           1G     9216   swp       server01.simulation     48:b0:2d:fb:0c:5b                                            \nswp2           up            up           1G     9216   swp       server02.simulation     48:b0:2d:82:e9:54                                            \nswp3           up            up           1G     9216   swp       server03.simulation     48:b0:2d:ab:52:15                                            \nswp49          up            up           1G     9216   swp       leaf02                  swp49                                                        \nswp50          up            up           1G     9216   swp       leaf02                  swp50                                                        \nswp51          up            up           1G     9216   swp       spine01                 swp1               IPv6 Address: fe80::4ab0:2dff:fe44:d8ba/64\nswp52          up            up           1G     9216   swp       spine02                 swp1               IPv6 Address: fe80::4ab0:2dff:fe65:942f/64\nswp53          up            up           1G     9216   swp       spine03                 swp1               IPv6 Address: fe80::4ab0:2dff:fe5b:b46e/64\nswp54          up            up           1G     9216   swp       spine04                 swp1               IPv6 Address: fe80::4ab0:2dff:fe86:d7ed/64\nvxlan48        up            up                  9216   vxlan                                                IPv6 Address: fe80::20c7:daff:fe66:5270/64\n"
}

PLAY RECAP ****************************************************************************************************************************
leaf01                     : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
Create second playbook inspect_leaf_vlans.yml
```
ubuntu@oob-mgmt-server:~/ansible_lab$ cat inspect_leaf_vlans.yml 
---
- name: Inspect VLANs on all leaf switches
  hosts: leaf_sw
  gather_facts: false

  collections:
    - nvidia.nvue

  tasks:
    - name: Query bridge VLANs
      nvidia.nvue.command:
        commands:
          - "show bridge domain br_default vlan"
        apply: false
      register: vlan_output

    - name: Display bridge VLANs
      ansible.builtin.debug:
        msg:
          - "Device: {{ inventory_hostname }}"
          - "Management IP: {{ ansible_host }}"
          - "{{ vlan_output['message'] }}"ubuntu@oob-mgmt-server:~/ansible_lab$ 
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-playbook --syntax-check inspect_leaf_vlans.yml 

playbook: inspect_leaf_vlans.yml
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-playbook inspect_leaf_vlans.yml --limit leaf01

PLAY [Inspect VLANs on all leaf switches] *********************************************************************************************

TASK [Query bridge VLANs] *************************************************************************************************************
ok: [leaf01]

TASK [Display bridge VLANs] ***********************************************************************************************************
ok: [leaf01] => {
    "msg": [
        "Device: leaf01",
        "Management IP: 192.168.200.6",
        "Vlan  Ptp State  Source IP  VNI\n----  ---------  ---------  ---\n10    disabled   0.0.0.0    10 \n20    disabled   0.0.0.0 20 \n30    disabled   0.0.0.0    30 \n"
    ]
}

PLAY RECAP ****************************************************************************************************************************
leaf01                     : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
Use nvue.command to create vlan100 on leaf1 and validate
```
ubuntu@oob-mgmt-server:~/ansible_lab$ cat configure_leaf01_vlan100.yml
---
- name: Configure VLAN 100 on leaf01
  hosts: leaf01
  gather_facts: false

  collections:
    - nvidia.nvue

  tasks:
    - name: Create VLAN 100 and its SVI
      nvidia.nvue.command:
        commands:
          - "set bridge domain br_default vlan 100"
          - "set interface vlan100 ip address 100.100.100.100/24"
          - "set interface vlan100 description 'Configured by Ansible lab'"
        apply: true
        assume_yes: true

    - name: Query VLAN 100 interface
      nvidia.nvue.command:
        commands:
          - "show interface vlan100"
        apply: false
      register: interface_output

    - name: Query bridge VLANs
      nvidia.nvue.command:
        commands:
          - "show bridge domain br_default vlan"
        apply: false
      register: vlan_output

    - name: Display verification results
      ansible.builtin.debug:
        msg:
          - "{{ interface_output['message'] }}"
          - "{{ vlan_output['message'] }}"ubuntu@oob-mgmt-server:~/ansible_lab$ 
ubuntu@oob-mgmt-server:~/ansible_lab$ 
ubuntu@oob-mgmt-server:~/ansible_lab$ 
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-playbook configure_leaf01_vlan100.yml 

PLAY [Configure VLAN 100 on leaf01] ***************************************************************************************************

TASK [Create VLAN 100 and its SVI] ****************************************************************************************************
changed: [leaf01]

TASK [Query VLAN 100 interface] *******************************************************************************************************
ok: [leaf01]

TASK [Query bridge VLANs] *************************************************************************************************************
ok: [leaf01]

TASK [Display verification results] ***************************************************************************************************
ok: [leaf01] => {
    "msg": [
        "                           operational                  applied                  \n-------------------------  ---------------------------  -------------------------\ntype                       svi                          svi                      \nbase-interface             br_default                   br_default               \nvrf                                                     default                  \nvlan                       100                          100                      \nrouter                                                                           \n  pbr                                                                            \n    [map]                                                                        \n  ospf                                                                           \n    state                                               disabled                 \n  pim                                                                            \n    state                                               disabled                 \n  ospf6                                                                          \n    state                                               disabled                 \nptp                                                                              \n  state                    disabled                     disabled                 \n[acl]                                                                            \nneighbor                                                                         \n  [ipv4]                                                                         \n  [ipv6]                                                                         \nsflow                                                                            \n  state                                                 enabled                  \ndescription                Configured by Ansible lab    Configured by Ansible lab\nipv4                                                                             \n  forward                                               enabled                  \n  igmp                                                                           \n    state                                               disabled                 \n  vrr                                                                            \n    state                                               disabled                 \n  vrrp                                                                           \n    state                                               disabled                 \n  dhcp-client                                                                    \n    state                                               disabled                 \n    set-hostname                                        disabled                 \n  [address]                100.100.100.100/24           100.100.100.100/24       \n  [gateway]                                                                      \nipv6                                                                             \n  forward                                               enabled                  \n  neighbor-discovery                                                             \n    state                                               enabled                  \n    router-advertisement                                                         \n      state                                             disabled                 \n    home-agent                                                                   \n      state                                             disabled                 \n    [rdnss]                                                                      \n    [dnssl]                                                                      \n    [prefix]                                                                     \n  vrr                                                                            \n    state                                               disabled                 \n  vrrp                                                                           \n    state                                               disabled                 \n  dhcp-client                                                                    \n    state                                               disabled                 \n    set-hostname                                        disabled                 \n  [address]                fe80::4638:39ff:fe22:17e/64                           \n  [gateway]                                                                      \n  state                                                 enabled                  \nlink                                                                             \n  mac-address              44:38:39:22:01:7e                                     \n  mtu                      9216                         9216                     \n  [flag]                   broadcast                                             \n  [flag]                   multicast                                             \n  [flag]                   up                                                    \n  [flag]                   lower-up                                              \n  state                    up                           up                       \n  protodown                disabled                                              \n  oper-status              up                                                    \n  admin-status             up                                                    \n  oper-status-last-change  2026/07/20 01:27:39.076                               \ncounters                                                                         \n  link                                                                           \n    carrier-transitions    1                                                     \n    carrier-up-count       1                                                     \n    carrier-down-count     0                                                     \nifindex                    20                                                    \n",
        "Vlan  Ptp State  Source IP  VNI\n----  ---------  ---------  ---\n10    disabled   0.0.0.0    10 \n20    disabled   0.0.0.0    20 \n30    disabled   0.0.0.0    30 \n100   disabled   0.0.0.0       \n"
    ]
}

PLAY RECAP ****************************************************************************************************************************
leaf01                     : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
Validate vlan100 on leaf1
```
ubuntu@oob-mgmt-server:~/ansible_lab$ ssh cumulus@leaf01 \
  "nv show interface vlan100; echo; nv show bridge domain br_default vlan"
Warning: Permanently added 'leaf01' (ECDSA) to the list of known hosts.
##################################################################################### 
#  Welcome to NVIDIA Cumulus VX (TM) 5.16.0                                            # 
#  NVIDIA Cumulus VX (TM) is a community supported virtual appliance designed       # 
#  for experiencing, testing and prototyping NVIDIA Cumulus' latest technology.     # 
#  For any questions or technical support, visit our community site at:             # 
#  https://www.nvidia.com/en-us/support                                             # 
#####################################################################################
                           operational                  applied                  
-------------------------  ---------------------------  -------------------------
type                       svi                          svi                      
base-interface             br_default                   br_default               
vrf                                                     default                  
vlan                       100                          100                      
router                                                                           
  pbr                                                                            
    [map]                                                                        
  ospf                                                                           
    state                                               disabled                 
  pim                                                                            
    state                                               disabled                 
  ospf6                                                                          
    state                                               disabled                 
ptp                                                                              
  state                    disabled                     disabled                 
[acl]                                                                            
neighbor                                                                         
  [ipv4]                                                                         
  [ipv6]                                                                         
sflow                                                                            
  state                                                 enabled                  
description                Configured by Ansible lab    Configured by Ansible lab
ipv4                                                                             
  forward                                               enabled                  
  igmp                                                                           
    state                                               disabled                 
  vrr                                                                            
    state                                               disabled                 
  vrrp                                                                           
    state                                               disabled                 
  dhcp-client                                                                    
    state                                               disabled                 
    set-hostname                                        disabled                 
  [address]                100.100.100.100/24           100.100.100.100/24       
  [gateway]                                                                      
ipv6                                                                             
  forward                                               enabled                  
  neighbor-discovery                                                             
    state                                               enabled                  
    router-advertisement                                                         
      state                                             disabled                 
    home-agent                                                                   
      state                                             disabled                 
    [rdnss]                                                                      
    [dnssl]                                                                      
    [prefix]                                                                     
  vrr                                                                            
    state                                               disabled                 
  vrrp                                                                           
    state                                               disabled                 
  dhcp-client                                                                    
    state                                               disabled                 
    set-hostname                                        disabled                 
  [address]                fe80::4638:39ff:fe22:17e/64                           
  [gateway]                                                                      
  state                                                 enabled                  
link                                                                             
  mac-address              44:38:39:22:01:7e                                     
  mtu                      9216                         9216                     
  [flag]                   broadcast                                             
  [flag]                   multicast                                             
  [flag]                   up                                                    
  [flag]                   lower-up                                              
  state                    up                           up                       
  protodown                disabled                                              
  oper-status              up                                                    
  admin-status             up                                                    
  oper-status-last-change  2026/07/20 01:27:39.076                               
counters                                                                         
  link                                                                           
    carrier-transitions    1                                                     
    carrier-up-count       1                                                     
    carrier-down-count     0                                                     
ifindex                    20                                                    

Vlan  Ptp State  Source IP  VNI
----  ---------  ---------  ---
10    disabled   0.0.0.0    10 
20    disabled   0.0.0.0    20 
30    disabled   0.0.0.0    30 
100   disabled   0.0.0.0       
ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
Validate ansible idempotency: After the first apply, config is in expected result, re-run won't make change


Add vlan99 value to hosts and validate
```
ubuntu@oob-mgmt-server:~/ansible_lab$ cat hosts
[spine_sw]
spine01 ansible_host=192.168.200.2
spine02 ansible_host=192.168.200.3
spine03 ansible_host=192.168.200.4
spine04 ansible_host=192.168.200.5

[leaf_sw]
leaf01 ansible_host=192.168.200.6 vlan99_ip=10.99.0.6/32
leaf02 ansible_host=192.168.200.7 vlan99_ip=10.99.0.7/32
leaf03 ansible_host=192.168.200.8 vlan99_ip=10.99.0.8/32
leaf04 ansible_host=192.168.200.9 vlan99_ip=10.99.0.9/32

[all:vars]
ansible_user=cumulus
ansible_password=Cumu1usLinux!
ansible_port=22
ansible_python_interpreter=/usr/bin/python3ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-inventory --host leaf01
{
    "ansible_host": "192.168.200.6",
    "ansible_password": "Cumu1usLinux!",
    "ansible_port": 22,
    "ansible_python_interpreter": "/usr/bin/python3",
    "ansible_user": "cumulus",
    "vlan99_ip": "10.99.0.6/32"
}
ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
Config VLAN99 IP on multiple switches
```
ubuntu@oob-mgmt-server:~/ansible_lab$ cat configure_leafs_vlan99.yml 
---
- name: Configure VLAN 99 on leaf switches
  hosts: leaf_sw
  gather_facts: false
  serial: 1

  collections:
    - nvidia.nvue

  tasks:
    - name: Display intended configuration
      ansible.builtin.debug:
        msg:
          - "Device: {{ inventory_hostname }}"
          - "Management IP: {{ ansible_host }}"
          - "VLAN 99 IP: {{ vlan99_ip }}"

    - name: Configure VLAN 99
      nvidia.nvue.command:
        template: |
          set bridge domain br_default vlan 99
          set interface vlan99 ip address {{ vlan99_ip }}
          set interface vlan99 description 'Configured by Ansible on {{ inventory_hostname }}'
        apply: true
        assume_yes: true

    - name: Query VLAN 99 interface
      nvidia.nvue.command:
        commands:
          - "show interface vlan99 ipv4"
        apply: false
      register: vlan99_output

    - name: Display VLAN 99 result
      ansible.builtin.debug:
        msg:
          - "Device: {{ inventory_hostname }}"
          - "{{ vlan99_output['message'] }}"
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-playbook configure_leafs_vlan99.yml --limit leaf01

PLAY [Configure VLAN 99 on leaf switches] *********************************************************************************************

TASK [Display intended configuration] *************************************************************************************************
ok: [leaf01] => {
    "msg": [
        "Device: leaf01",
        "Management IP: 192.168.200.6",
        "VLAN 99 IP: 10.99.0.6/32"
    ]
}

TASK [Configure VLAN 99] **************************************************************************************************************
ok: [leaf01]

TASK [Query VLAN 99 interface] ********************************************************************************************************
ok: [leaf01]

TASK [Display VLAN 99 result] *********************************************************************************************************
ok: [leaf01] => {
    "msg": [
        "Device: leaf01",
        "                operational   applied       pending     \n--------------  ------------  ------------  ------------\nforward                       enabled       enabled     \nigmp                                                    \n  state                       disabled      disabled    \nvrr                                                     \n  state                       disabled      disabled    \nvrrp                                                    \n  state                       disabled      disabled    \ndhcp-client                                             \n  state                       disabled      disabled    \n  set-hostname                disabled      disabled    \n[address]       10.99.0.6/32  10.99.0.6/32  10.99.0.6/32\n[gateway]                                               \n"
    ]
}

PLAY RECAP ****************************************************************************************************************************
leaf01                     : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ubuntu@oob-mgmt-server:~/ansible_lab$ 
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-playbook configure_leafs_vlan99.yml

PLAY [Configure VLAN 99 on leaf switches] *********************************************************************************************

TASK [Display intended configuration] *************************************************************************************************
ok: [leaf01] => {
    "msg": [
        "Device: leaf01",
        "Management IP: 192.168.200.6",
        "VLAN 99 IP: 10.99.0.6/32"
    ]
}

TASK [Configure VLAN 99] **************************************************************************************************************
ok: [leaf01]

TASK [Query VLAN 99 interface] ********************************************************************************************************
ok: [leaf01]

TASK [Display VLAN 99 result] *********************************************************************************************************
ok: [leaf01] => {
    "msg": [
        "Device: leaf01",
        "                operational   applied       pending     \n--------------  ------------  ------------  ------------\nforward                       enabled       enabled     \nigmp                                                    \n  state                       disabled      disabled    \nvrr                                                     \n  state                       disabled      disabled    \nvrrp                                                    \n  state                       disabled      disabled    \ndhcp-client                                             \n  state                       disabled      disabled    \n  set-hostname                disabled      disabled    \n[address]       10.99.0.6/32  10.99.0.6/32  10.99.0.6/32\n[gateway]                                               \n"
    ]
}

PLAY [Configure VLAN 99 on leaf switches] *********************************************************************************************

TASK [Display intended configuration] *************************************************************************************************
ok: [leaf02] => {
    "msg": [
        "Device: leaf02",
        "Management IP: 192.168.200.7",
        "VLAN 99 IP: 10.99.0.7/32"
    ]
}

TASK [Configure VLAN 99] **************************************************************************************************************
changed: [leaf02]

TASK [Query VLAN 99 interface] ********************************************************************************************************
ok: [leaf02]

TASK [Display VLAN 99 result] *********************************************************************************************************
ok: [leaf02] => {
    "msg": [
        "Device: leaf02",
        "                operational   applied     \n--------------  ------------  ------------\nforward                       enabled     \nigmp                                      \n  state                       disabled    \nvrr                                       \n  state                       disabled    \nvrrp                                      \n  state                       disabled    \ndhcp-client                               \n  state                       disabled    \n  set-hostname                disabled    \n[address]       10.99.0.7/32  10.99.0.7/32\n[gateway]                                 \n"
    ]
}

PLAY [Configure VLAN 99 on leaf switches] *********************************************************************************************

TASK [Display intended configuration] *************************************************************************************************
ok: [leaf03] => {
    "msg": [
        "Device: leaf03",
        "Management IP: 192.168.200.8",
        "VLAN 99 IP: 10.99.0.8/32"
    ]
}

TASK [Configure VLAN 99] **************************************************************************************************************
changed: [leaf03]

TASK [Query VLAN 99 interface] ********************************************************************************************************
ok: [leaf03]

TASK [Display VLAN 99 result] *********************************************************************************************************
ok: [leaf03] => {
    "msg": [
        "Device: leaf03",
        "                operational   applied     \n--------------  ------------  ------------\nforward                       enabled     \nigmp                                      \n  state                       disabled    \nvrr                                       \n  state                       disabled    \nvrrp                                      \n  state                       disabled    \ndhcp-client                               \n  state                       disabled    \n  set-hostname                disabled    \n[address]       10.99.0.8/32  10.99.0.8/32\n[gateway]                                 \n"
    ]
}

PLAY [Configure VLAN 99 on leaf switches] *********************************************************************************************

TASK [Display intended configuration] *************************************************************************************************
ok: [leaf04] => {
    "msg": [
        "Device: leaf04",
        "Management IP: 192.168.200.9",
        "VLAN 99 IP: 10.99.0.9/32"
    ]
}

TASK [Configure VLAN 99] **************************************************************************************************************
changed: [leaf04]

TASK [Query VLAN 99 interface] ********************************************************************************************************
ok: [leaf04]

TASK [Display VLAN 99 result] *********************************************************************************************************
ok: [leaf04] => {
    "msg": [
        "Device: leaf04",
        "                operational   applied     \n--------------  ------------  ------------\nforward                       enabled     \nigmp                                      \n  state                       disabled    \nvrr                                       \n  state                       disabled    \nvrrp                                      \n  state                       disabled    \ndhcp-client                               \n  state                       disabled    \n  set-hostname                disabled    \n[address]       10.99.0.9/32  10.99.0.9/32\n[gateway]                                 \n"
    ]
}

PLAY RECAP ****************************************************************************************************************************
leaf01                     : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
leaf02                     : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
leaf03                     : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
leaf04                     : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ubuntu@oob-mgmt-server:~/ansible_lab$ 
```

Verify vlan99, there is no serial: 1, all being worked on together.

```
ubuntu@oob-mgmt-server:~/ansible_lab$ cat verify_leafs_vlan99.yml 
---
- name: Verify VLAN 99 on leaf switches
  hosts: leaf_sw
  gather_facts: false

  collections:
    - nvidia.nvue

  tasks:
    - name: Query VLAN 99 IPv4 configuration
      nvidia.nvue.command:
        commands:
          - "show interface vlan99 ipv4"
        apply: false
      register: vlan99_output

    - name: Display expected and actual configuration
      ansible.builtin.debug:
        msg:
          - "Device: {{ inventory_hostname }}"
          - "Expected address: {{ vlan99_ip }}"
          - "{{ vlan99_output['message'] }}"ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-playbook verify_leafs_vlan99.yml

PLAY [Verify VLAN 99 on leaf switches] ************************************************************************************************

TASK [Query VLAN 99 IPv4 configuration] ***********************************************************************************************
ok: [leaf02]
ok: [leaf03]
ok: [leaf04]
ok: [leaf01]

TASK [Display expected and actual configuration] **************************************************************************************
ok: [leaf01] => {
    "msg": [
        "Device: leaf01",
        "Expected address: 10.99.0.6/32",
        "                operational   applied       pending     \n--------------  ------------  ------------  ------------\nforward                    enabled       enabled     \nigmp                                                    \n  state disabled      disabled    \nvrr                                                     \n  state                       disabled      disabled    \nvrrp                                                    \n  state                       disabled      disabled    \ndhcp-client                                             \n  state                       disabled      disabled    \n  set-hostname  disabled      disabled    \n[address]       10.99.0.6/32  10.99.0.6/32  10.99.0.6/32\n[gateway]         \n"
    ]
}
ok: [leaf03] => {
    "msg": [
        "Device: leaf03",
        "Expected address: 10.99.0.8/32",
        "                operational   applied     \n--------------  ------------  ------------\nforward                       enabled    \nigmp                                      \n  state                       disabled    \nvrr \n  state                       disabled    \nvrrp                                      \n  state                       disabled    \ndhcp-client                               \n  state                       disabled    \n  set-hostname                disabled    \n[address]       10.99.0.8/32  10.99.0.8/32\n[gateway]                                 \n"
    ]
}
ok: [leaf04] => {
    "msg": [
        "Device: leaf04",
        "Expected address: 10.99.0.9/32",
        "                operational   applied     \n--------------  ------------  ------------\nforward                       enabled    \nigmp                                      \n  state                       disabled    \nvrr \n  state                       disabled    \nvrrp                                      \n  state                       disabled    \ndhcp-client                               \n  state                       disabled    \n  set-hostname                disabled    \n[address]       10.99.0.9/32  10.99.0.9/32\n[gateway]                                 \n"
    ]
}
ok: [leaf02] => {
    "msg": [
        "Device: leaf02",
        "Expected address: 10.99.0.7/32",
        "                operational   applied     \n--------------  ------------  ------------\nforward                       enabled    \nigmp                                      \n  state                       disabled    \nvrr \n  state                       disabled    \nvrrp                                      \n  state                       disabled    \ndhcp-client                               \n  state                       disabled    \n  set-hostname                disabled    \n[address]       10.99.0.7/32  10.99.0.7/32\n[gateway]                                 \n"
    ]
}

PLAY RECAP ****************************************************************************************************************************
leaf01                     : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
leaf02                     : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
leaf03                     : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
leaf04                     : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
Rollback vlan99
```
ubuntu@oob-mgmt-server:~/ansible_lab$ cat rollback_leafs_vlan99.yml 
---
- name: Remove VLAN 99 from leaf switches
  hosts: leaf_sw
  gather_facts: false
  serial: 1

  collections:
    - nvidia.nvue

  tasks:
    - name: Remove VLAN 99 SVI and bridge VLAN
      nvidia.nvue.command:
        commands:
          - "unset interface vlan99"
          - "unset bridge domain br_default vlan 99"
        apply: true
        assume_yes: true

    - name: Query bridge VLANs
      nvidia.nvue.command:
        commands:
          - "show bridge domain br_default vlan"
        apply: false
      register: bridge_output

    - name: Check vlan99 Linux interface
      ansible.builtin.command:
        cmd: ip link show vlan99
      register: vlan99_check
      changed_when: false
      failed_when: false

    - name: Display rollback result
      ansible.builtin.debug:
        msg:
          - "Device: {{ inventory_hostname }}"
          - "{{ bridge_output['message'] }}"
          - "vlan99 check return code: {{ vlan99_check.rc }}"
          - "{{ vlan99_check.stderr | default('') }}"ubuntu@oob-mgmt-server:~/ansible_lab$ 
ubuntu@oob-mgmt-server:~/ansible_lab$ 
ubuntu@oob-mgmt-server:~/ansible_lab$ 
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-playbook rollback_leafs_vlan99.yml

PLAY [Remove VLAN 99 from leaf switches] **********************************************************************************************

TASK [Remove VLAN 99 SVI and bridge VLAN] *********************************************************************************************
changed: [leaf01]

TASK [Query bridge VLANs] *************************************************************************************************************
ok: [leaf01]

TASK [Check vlan99 Linux interface] ***************************************************************************************************
ok: [leaf01]

TASK [Display rollback result] ********************************************************************************************************
ok: [leaf01] => {
    "msg": [
        "Device: leaf01",
        "Vlan  Ptp State  Source IP  VNI\n----  ---------  ---------  ---\n10    disabled   0.0.0.0    10 \n20    disabled   0.0.0.0 20 \n30    disabled   0.0.0.0    30 \n",
        "vlan99 check return code: 1",
        "Device \"vlan99\" does not exist."
    ]
}

PLAY [Remove VLAN 99 from leaf switches] **********************************************************************************************

TASK [Remove VLAN 99 SVI and bridge VLAN] *********************************************************************************************
changed: [leaf02]

TASK [Query bridge VLANs] *************************************************************************************************************
ok: [leaf02]

TASK [Check vlan99 Linux interface] ***************************************************************************************************
ok: [leaf02]

TASK [Display rollback result] ********************************************************************************************************
ok: [leaf02] => {
    "msg": [
        "Device: leaf02",
        "Vlan  Ptp State  Source IP  VNI\n----  ---------  ---------  ---\n10    disabled   0.0.0.0    10 \n20    disabled   0.0.0.0 20 \n30    disabled   0.0.0.0    30 \n",
        "vlan99 check return code: 1",
        "Device \"vlan99\" does not exist."
    ]
}

PLAY [Remove VLAN 99 from leaf switches] **********************************************************************************************

TASK [Remove VLAN 99 SVI and bridge VLAN] *********************************************************************************************
changed: [leaf03]

TASK [Query bridge VLANs] *************************************************************************************************************
ok: [leaf03]

TASK [Check vlan99 Linux interface] ***************************************************************************************************
ok: [leaf03]

TASK [Display rollback result] ********************************************************************************************************
ok: [leaf03] => {
    "msg": [
        "Device: leaf03",
        "Vlan  Ptp State  Source IP  VNI\n----  ---------  ---------  ---\n10    disabled   0.0.0.0    10 \n20    disabled   0.0.0.0 20 \n30    disabled   0.0.0.0    30 \n",
        "vlan99 check return code: 1",
        "Device \"vlan99\" does not exist."
    ]
}

PLAY [Remove VLAN 99 from leaf switches] **********************************************************************************************

TASK [Remove VLAN 99 SVI and bridge VLAN] *********************************************************************************************
changed: [leaf04]

TASK [Query bridge VLANs] *************************************************************************************************************
ok: [leaf04]

TASK [Check vlan99 Linux interface] ***************************************************************************************************
ok: [leaf04]

TASK [Display rollback result] ********************************************************************************************************
ok: [leaf04] => {
    "msg": [
        "Device: leaf04",
        "Vlan  Ptp State  Source IP  VNI\n----  ---------  ---------  ---\n10    disabled   0.0.0.0    10 \n20    disabled   0.0.0.0 20 \n30    disabled   0.0.0.0    30 \n",
        "vlan99 check return code: 1",
        "Device \"vlan99\" does not exist."
    ]
}

PLAY RECAP ****************************************************************************************************************************
leaf01                     : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
leaf02                     : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
leaf03                     : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
leaf04                     : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
Some notes:
- changed_when: false # command disply task changed even it is just a show command, set this to false so it won't show as changed
- ansible.builtin.assert # valiate conditions

```
ubuntu@oob-mgmt-server:~/ansible_lab$ cat validate_inventory.yml 
---
- name: Validate inventory against actual devices
  hosts: all
  gather_facts: false

  tasks:
    - name: Read device hostname
      ansible.builtin.command:
        cmd: hostname
      register: hostname_result
      changed_when: false

    - name: Read management interface address
      ansible.builtin.command:
        cmd: ip -4 -brief address show eth0
      register: management_result
      changed_when: false

    - name: Validate hostname and management address
      ansible.builtin.assert:
        that:
          - hostname_result.stdout == inventory_hostname
          - ansible_host in management_result.stdout
        success_msg: >-
          {{ inventory_hostname }} passed:
          hostname={{ hostname_result.stdout }},
          management={{ ansible_host }}
        fail_msg: >-
          {{ inventory_hostname }} failed:
          actual hostname={{ hostname_result.stdout }},
          expected hostname={{ inventory_hostname }},
          expected management IP={{ ansible_host }},
          actual interface={{ management_result.stdout }}
```
Validate result:
```
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-playbook validate_inventory.yml

PLAY [Validate inventory against actual devices] **************************************************************************************

TASK [Read device hostname] ***********************************************************************************************************
ok: [spine01]
ok: [spine02]
ok: [spine04]
ok: [spine03]
ok: [leaf01]
ok: [leaf03]
ok: [leaf04]
ok: [leaf02]

TASK [Read management interface address] **********************************************************************************************
ok: [spine01]
ok: [spine04]
ok: [leaf01]
ok: [spine03]
ok: [spine02]
ok: [leaf02]
ok: [leaf03]
ok: [leaf04]

TASK [Validate hostname and management address] ***************************************************************************************
ok: [spine01] => {
    "changed": false,
    "msg": "spine01 passed: hostname=spine01, management=192.168.200.2"
}
ok: [spine02] => {
    "changed": false,
    "msg": "spine02 passed: hostname=spine02, management=192.168.200.3"
}
ok: [spine03] => {
    "changed": false,
    "msg": "spine03 passed: hostname=spine03, management=192.168.200.4"
}
ok: [spine04] => {
    "changed": false,
    "msg": "spine04 passed: hostname=spine04, management=192.168.200.5"
}
ok: [leaf02] => {
    "changed": false,
    "msg": "leaf02 passed: hostname=leaf02, management=192.168.200.7"
}
ok: [leaf01] => {
    "changed": false,
    "msg": "leaf01 passed: hostname=leaf01, management=192.168.200.6"
}
ok: [leaf03] => {
    "changed": false,
    "msg": "leaf03 passed: hostname=leaf03, management=192.168.200.8"
}
ok: [leaf04] => {
    "changed": false,
    "msg": "leaf04 passed: hostname=leaf04, management=192.168.200.9"
}

PLAY RECAP ****************************************************************************************************************************
leaf01                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
leaf02                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
leaf03                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
leaf04                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
spine01                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
spine02                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
spine03                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
spine04                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
Restructure hosts file into inventory dir
```
ubuntu@oob-mgmt-server:~/ansible_lab$ cat > ansible.cfg <<'EOF'
[defaults]
inventory = ./inventory/hosts.ini
host_key_checking = False
deprecation_warnings = False
interpreter_python = auto_silent
EOF
ubuntu@oob-mgmt-server:~/ansible_lab$ find inventory -type f -maxdepth 3 -print
find: warning: you have specified the global option -maxdepth after the argument -type, but global options are not positional, i.e., -maxdepth affects tests specified before it as well as those specified after it.  Please specify global options before other arguments.
inventory/hosts.ini
inventory/group_vars/all.yml
inventory/host_vars/leaf01.yml
inventory/host_vars/leaf03.yml
inventory/host_vars/leaf02.yml
inventory/host_vars/leaf04.yml
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-inventory --graph
@all:
  |--@ungrouped:
  |--@spine_sw:
  |  |--spine01
  |  |--spine02
  |  |--spine03
  |  |--spine04
  |--@leaf_sw:
  |  |--leaf01
  |  |--leaf02
  |  |--leaf03
  |  |--leaf04
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-inventory --host leaf01
{
    "ansible_host": "192.168.200.6",
    "ansible_password": "Cumu1usLinux!",
    "ansible_port": 22,
    "ansible_python_interpreter": "/usr/bin/python3",
    "ansible_user": "cumulus",
    "vlan99_ip": "10.99.0.6/32"
}
ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
Validate again
```
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-playbook validate_inventory.yml

PLAY [Validate inventory against actual devices] **************************************************************************************

TASK [Read device hostname] ***********************************************************************************************************
ok: [spine04]
ok: [spine02]
ok: [spine01]
ok: [spine03]
ok: [leaf01]
ok: [leaf02]
ok: [leaf04]
ok: [leaf03]

TASK [Read management interface address] **********************************************************************************************
ok: [spine01]
ok: [spine02]
ok: [spine04]
ok: [spine03]
ok: [leaf01]
ok: [leaf02]
ok: [leaf03]
ok: [leaf04]

TASK [Validate hostname and management address] ***************************************************************************************
ok: [spine01] => {
    "changed": false,
    "msg": "spine01 passed: hostname=spine01, management=192.168.200.2"
}
ok: [spine02] => {
    "changed": false,
    "msg": "spine02 passed: hostname=spine02, management=192.168.200.3"
}
ok: [spine04] => {
    "changed": false,
    "msg": "spine04 passed: hostname=spine04, management=192.168.200.5"
}
ok: [spine03] => {
    "changed": false,
    "msg": "spine03 passed: hostname=spine03, management=192.168.200.4"
}
ok: [leaf01] => {
    "changed": false,
    "msg": "leaf01 passed: hostname=leaf01, management=192.168.200.6"
}
ok: [leaf03] => {
    "changed": false,
    "msg": "leaf03 passed: hostname=leaf03, management=192.168.200.8"
}
ok: [leaf02] => {
    "changed": false,
    "msg": "leaf02 passed: hostname=leaf02, management=192.168.200.7"
}
ok: [leaf04] => {
    "changed": false,
    "msg": "leaf04 passed: hostname=leaf04, management=192.168.200.9"
}

PLAY RECAP ****************************************************************************************************************************
leaf01                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
leaf02                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
leaf03                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
leaf04                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
spine01                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
spine02                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
spine03                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
spine04                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
Use ansible vault to protect password
```
ubuntu@oob-mgmt-server:~/ansible_lab$ mkdir -p inventory/group_vars/all
ubuntu@oob-mgmt-server:~/ansible_lab$ cat > inventory/group_vars/all/vars.yml <<'EOF'
---
ansible_user: cumulus
ansible_password: "{{ vault_ansible_password }}"
ansible_port: 22
ansible_python_interpreter: /usr/bin/python3
EOF
ubuntu@oob-mgmt-server:~/ansible_lab$ umask 077
ubuntu@oob-mgmt-server:~/ansible_lab$ cat > /tmp/ansible-vault.yml <<'EOF'
---
vault_ansible_password: Cumu1usLinux!
EOF
ubuntu@oob-mgmt-server:~/ansible_lab$ ls -l /tmp/ansible-vault.yml
-rw------- 1 ubuntu ubuntu 42 Jul 20 01:59 /tmp/ansible-vault.yml
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-vault encrypt \
  /tmp/ansible-vault.yml \
  --output inventory/group_vars/all/vault.yml
New Vault password: 
Confirm New Vault password: 
Encryption successful
ubuntu@oob-mgmt-server:~/ansible_lab$ rm -f /tmp/ansible-vault.yml
ubuntu@oob-mgmt-server:~/ansible_lab$ head -n 3 inventory/group_vars/all/vault.yml
$ANSIBLE_VAULT;1.1;AES256
62616461636162326638626231623264323666393065373034333262303038616663653465373931
6137333734633962356461346635393939343764373766620a323439633532333931636131626435
ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
Run with vault pass
```
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible all -m ansible.builtin.ping --ask-vault-pass
Vault password: 
spine02 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
spine03 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
leaf01 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
spine01 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
spine04 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
leaf02 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
leaf03 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
leaf04 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
