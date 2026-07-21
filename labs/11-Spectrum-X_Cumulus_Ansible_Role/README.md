# Intialize ansible role structure
```
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-galaxy role init roles/cumulus_inspect
- Role roles/cumulus_inspect was created successfully
ubuntu@oob-mgmt-server:~/ansible_lab$ tree roles/
roles/
└── cumulus_inspect
    ├── README.md
    ├── defaults
    │   └── main.yml
    ├── files
    ├── handlers
    │   └── main.yml
    ├── meta
    │   └── main.yml
    ├── tasks
    │   └── main.yml
    ├── templates
    ├── tests
    │   ├── inventory
    │   └── test.yml
    └── vars
        └── main.yml

9 directories, 8 files
ubuntu@oob-mgmt-server:~/ansible_lab$ 
ubuntu@oob-mgmt-server:~/ansible_lab$ find roles/cumulus_inspect -maxdepth 2 -type f -print
roles/cumulus_inspect/defaults/main.yml
roles/cumulus_inspect/README.md
roles/cumulus_inspect/vars/main.yml
roles/cumulus_inspect/tests/inventory
roles/cumulus_inspect/tests/test.yml
roles/cumulus_inspect/tasks/main.yml
roles/cumulus_inspect/meta/main.yml
roles/cumulus_inspect/handlers/main.yml
ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
# Define default and task
```
ubuntu@oob-mgmt-server:~/ansible_lab$ cat roles/cumulus_inspect/defaults/main.yml
---
inspect_command: "show system"
ubuntu@oob-mgmt-server:~/ansible_lab$ cat roles/cumulus_inspect/tasks/main.yml
---
- name: Validate inspection command
  ansible.builtin.assert:
    that:
      - inspect_command is string
      - inspect_command | length > 0
    fail_msg: >-
      inspect_command must be a non-empty string on
      {{ inventory_hostname }}
    success_msg: >-
      Inspection command validated for
      {{ inventory_hostname }}

- name: Run read-only NVUE inspection command
  nvidia.nvue.command:
    commands:
      - "{{ inspect_command }}"
    apply: false
  register: inspect_result

- name: Display inspection result
  ansible.builtin.debug:
    msg:
      - "Device: {{ inventory_hostname }}"
      - "Management IP: {{ ansible_host }}"
      - "Command: nv {{ inspect_command }}"
      - "{{ inspect_result['message'] }}"
ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
# Create playbook with role calling
```
ubuntu@oob-mgmt-server:~/ansible_lab$ cat inspect_cumulus.yml 
---
- name: Inspect Cumulus Linux leaf switches
  hosts: leaf_sw
  gather_facts: false

  roles:
    - role: cumulus_inspect
ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
# playbook inspect
```
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-playbook --syntax-check inspect_cumulus.yml

playbook: inspect_cumulus.yml
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-playbook inspect_cumulus.yml --list-tasks

playbook: inspect_cumulus.yml

  play #1 (leaf_sw): Inspect Cumulus Linux leaf switches        TAGS: []
    tasks:
      cumulus_inspect : Validate inspection command     TAGS: []
      cumulus_inspect : Run read-only NVUE inspection command   TAGS: []
      cumulus_inspect : Display inspection result       TAGS: []
ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
# Run playbook
```
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-playbook inspect_cumulus.yml   --limit leaf01   --ask-vault-pass
Vault password: 

PLAY [Inspect Cumulus Linux leaf switches] ******************************************************************************************************************************

TASK [cumulus_inspect : Validate inspection command] ********************************************************************************************************************
ok: [leaf01] => {
    "changed": false,
    "msg": "Inspection command validated for leaf01"
}

TASK [cumulus_inspect : Run read-only NVUE inspection command] **********************************************************************************************************
ok: [leaf01]

TASK [cumulus_inspect : Display inspection result] **********************************************************************************************************************
ok: [leaf01] => {
    "msg": [
        "Device: leaf01",
        "Management IP: 192.168.200.6",
        "Command: nv show system",
        "                   operational          applied\n-----------------  -------------------  -------\nuptime             1:10:39                     \nhostname      leaf01               leaf01 \nfqdn               leaf01                      \nproduct-name       Cumulus Linux               \ncontact            \nlocation                                       \ndns                                            \n  domain                                       \ndate-time                                      \n  local-time       2026-07-21 01:37:57         \n  timezone         Etc/UTC              Etc/UTC\nhealth                 \n  status           Not OK                      \nversion                                        \n  product-release  5.16.1                      \nglobal                                         \n  system-mac       44:38:39:22:01:7e    auto   \n  anycast-mac      none                 none   \n"
    ]
}

PLAY RECAP **************************************************************************************************************************************************************
leaf01                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
# Run with specified commands
This will overwrite the defult/main.yml in task which has lower priority
```
ubuntu@oob-mgmt-server:~/ansible_lab$ cat inspect_cumulus.yml 
---
- name: Inspect Cumulus Linux leaf switches
  hosts: leaf_sw
  gather_facts: false

  vars:
    inspect_command: "show bridge domain br_default vlan"

  roles:
    - role: cumulus_inspect
ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
Run playbook again
```
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-playbook inspect_cumulus.yml   --limit leaf01   --ask-vault-pass
Vault password: 

PLAY [Inspect Cumulus Linux leaf switches] ******************************************************************************************************************************

TASK [cumulus_inspect : Validate inspection command] ********************************************************************************************************************
ok: [leaf01] => {
    "changed": false,
    "msg": "Inspection command validated for leaf01"
}

TASK [cumulus_inspect : Run read-only NVUE inspection command] **********************************************************************************************************
ok: [leaf01]

TASK [cumulus_inspect : Display inspection result] **********************************************************************************************************************
ok: [leaf01] => {
    "msg": [
        "Device: leaf01",
        "Management IP: 192.168.200.6",
        "Command: nv show bridge domain br_default vlan",
        "Vlan  Ptp State  Source IP  VNI\n----  ---------  ---------  ---\n10    disabled   0.0.0.0    10 \n20    disabled   0.0.0.0    20 \n30    disabled   0.0.0.030 \n"
    ]
}

PLAY RECAP **************************************************************************************************************************************************************
leaf01                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
# Simple workflow for above
```
Read inventory
    ↓
Choose leaf_sw
    ↓
--limit Run on leaf01 only
    ↓
load role defaults
inspect_command = show system
    ↓
load Playbook vars
inspect_command = show bridge domain br_default vlan
    ↓
Playbook vars have higher priority
    ↓
load roles/cumulus_inspect/tasks/main.yml
    ↓
excute three tasks on leaf01
```

# Excute same role on different inventory group
Create new playbook
```
ubuntu@oob-mgmt-server:~/ansible_lab$ cat inspect_fabric.yml 
---
- name: Inspect VLANs on leaf switches
  hosts: leaf_sw
  gather_facts: false

  roles:
    - role: cumulus_inspect
      vars:
        inspect_command: "show bridge domain br_default vlan"

- name: Inspect interfaces on spine switches
  hosts: spine_sw
  gather_facts: false

  roles:
    - role: cumulus_inspect
      vars:
        inspect_command: "show interface"
ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
# Validate playbook and task
```
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-playbook --syntax-check inspect_fabric.yml

playbook: inspect_fabric.yml
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-playbook inspect_fabric.yml --list-tasks

playbook: inspect_fabric.yml

  play #1 (leaf_sw): Inspect VLANs on leaf switches     TAGS: []
    tasks:
      cumulus_inspect : Validate inspection command     TAGS: []
      cumulus_inspect : Run read-only NVUE inspection command   TAGS: []
      cumulus_inspect : Display inspection result       TAGS: []

  play #2 (spine_sw): Inspect interfaces on spine switches      TAGS: []
    tasks:
      cumulus_inspect : Validate inspection command     TAGS: []
      cumulus_inspect : Run read-only NVUE inspection command   TAGS: []
      cumulus_inspect : Display inspection result       TAGS: []
ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
# Excute on two devices
```
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-playbook inspect_fabric.yml \
  --limit leaf01,spine01 \
  --ask-vault-pass
Vault password: 

PLAY [Inspect VLANs on leaf switches] ***********************************************************************************************************************************

TASK [cumulus_inspect : Validate inspection command] ********************************************************************************************************************
ok: [leaf01] => {
    "changed": false,
    "msg": "Inspection command validated for leaf01"
}

TASK [cumulus_inspect : Run read-only NVUE inspection command] **********************************************************************************************************
ok: [leaf01]

TASK [cumulus_inspect : Display inspection result] **********************************************************************************************************************
ok: [leaf01] => {
    "msg": [
        "Device: leaf01",
        "Management IP: 192.168.200.6",
        "Command: nv show bridge domain br_default vlan",
        "Vlan  Ptp State  Source IP  VNI\n----  ---------  ---------  ---\n10    disabled   0.0.0.0    10 \n20    disabled   0.0.0.0    20 \n30    disabled   0.0.0.030 \n"
    ]
}

PLAY [Inspect interfaces on spine switches] *****************************************************************************************************************************

TASK [cumulus_inspect : Validate inspection command] ********************************************************************************************************************
ok: [spine01] => {
    "changed": false,
    "msg": "Inspection command validated for spine01"
}

TASK [cumulus_inspect : Run read-only NVUE inspection command] **********************************************************************************************************
ok: [spine01]

TASK [cumulus_inspect : Display inspection result] **********************************************************************************************************************
ok: [spine01] => {
    "msg": [
        "Device: spine01",
        "Management IP: 192.168.200.2",
        "Command: nv show interface",
        "Interface  Admin Status  Oper Status  Speed  MTU    Type      Remote Host             Remote Port  Summary                                   \n---------  ------------  -----------  -----  -----  --------  ----------------------  -----------  ------------------------------------------\neth0       up            up           1G  1500   eth       oob-mgmt-switch-leaf-1  swp17        IPv4 Address:             192.168.200.2/24\n                              Address type:                      primary\n    IPv6 Address:  fe80::4638:39ff:fe22:178/64\nlo         up            unknown             65536  loopback                                       IPv4 Address:     10.10.10.101/32\n                                                                                                   IPv4 Address:                  127.0.0.1/8\n                                                                                               Address type:                      primary\n                                                                     Address type:                      primary\n                                           IPv6 Address:                      ::1/128\nmgmt       up            up                  65575  vrf                 IPv4 Address:                  127.0.0.1/8\n                                                                                                   IPv4 Address:                  127.0.1.1/8\n                                                                                                   Address type:primary\n                                                                                                   Address type:                    secondary\n                                                                                  IPv6 Address:                      ::1/128\nswp1       up            up           1G  9216   swp       leaf01                  swp51        IPv6 Address: fe80::4ab0:2dff:fe05:c996/64\nswp2       up            up           1G     9216   swp       leaf02                 swp51        IPv6 Address: fe80::4ab0:2dff:fe08:9fb3/64\nswp3       up            up           1G     9216   swp       leaf03                  swp51    IPv6 Address: fe80::4ab0:2dff:fe1d:e77d/64\nswp4       up            up           1G     9216   swp       leaf04                  swp51        IPv6 Address: fe80::4ab0:2dff:fe11:8128/64\nswp5       up            up           1G     9216   swp       border01                swp51        IPv6 Address: fe80::4ab0:2dff:fe92:34f8/64\nswp6       up            up           1G     9216   swp       border02                swp51        IPv6 Address: fe80::4ab0:2dff:fee4:f009/64\n"
    ]
}

PLAY RECAP **************************************************************************************************************************************************************
leaf01                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
spine01                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
# Init new role for creating SVI
```
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-galaxy role init roles/cumulus_vlan_svi
- Role roles/cumulus_vlan_svi was created successfully
ubuntu@oob-mgmt-server:~/ansible_lab$ find roles/cumulus_vlan_svi -maxdepth 2 -type f -print
roles/cumulus_vlan_svi/defaults/main.yml
roles/cumulus_vlan_svi/README.md
roles/cumulus_vlan_svi/vars/main.yml
roles/cumulus_vlan_svi/tests/inventory
roles/cumulus_vlan_svi/tests/test.yml
roles/cumulus_vlan_svi/tasks/main.yml
roles/cumulus_vlan_svi/meta/main.yml
roles/cumulus_vlan_svi/handlers/main.yml
ubuntu@oob-mgmt-server:~/ansible_lab$ tree roles/cumulus_vlan_svi/
roles/cumulus_vlan_svi/
├── README.md
├── defaults
│   └── main.yml
├── files
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── tasks
│   └── main.yml
├── templates
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml

8 directories, 8 files
ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
# Setup default vars
```
ubuntu@oob-mgmt-server:~/ansible_lab$ cat roles/cumulus_vlan_svi/defaults/main.yml
---
vlan_id: 99
vlan_svi_name: "vlan{{ vlan_id }}"
vlan_svi_description: "Configured by Ansible role on {{ inventory_hostname }}"
ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
# Create new task main.yml
```
ubuntu@oob-mgmt-server:~/ansible_lab$ cat roles/cumulus_vlan_svi/tasks/main.yml 
---
- name: Validate VLAN SVI input variables
  ansible.builtin.assert:
    that:
      - vlan_id | int >= 1
      - vlan_id | int <= 4094
      - vlan_svi_ip is defined
      - vlan_svi_ip | length > 0
    fail_msg: >-
      Invalid VLAN SVI variables on {{ inventory_hostname }}:
      vlan_id={{ vlan_id | default('undefined') }},
      vlan_svi_ip={{ vlan_svi_ip | default('undefined') }}
    success_msg: >-
      VLAN {{ vlan_id }} variables validated for {{ inventory_hostname }}

- name: Display intended VLAN SVI configuration
  ansible.builtin.debug:
    msg:
      - "Device: {{ inventory_hostname }}"
      - "Management IP: {{ ansible_host }}"
      - "VLAN ID: {{ vlan_id }}"
      - "SVI name: {{ vlan_svi_name }}"
      - "SVI address: {{ vlan_svi_ip }}"
      - "Description: {{ vlan_svi_description }}"

- name: Configure VLAN and SVI with NVUE
  nvidia.nvue.command:
    template: |
      set bridge domain br_default vlan {{ vlan_id }}
      set interface {{ vlan_svi_name }} ip address {{ vlan_svi_ip }}
      set interface {{ vlan_svi_name }} description '{{ vlan_svi_description }}'
    apply: true
    assume_yes: true

- name: Query VLAN SVI IPv4 configuration
  nvidia.nvue.command:
    commands:
      - "show interface {{ vlan_svi_name }} ipv4"
    apply: false
  register: vlan_svi_output

- name: Validate applied VLAN SVI address
  ansible.builtin.assert:
    that:
      - vlan_svi_ip in vlan_svi_output['message']
    success_msg: >-
      VLAN {{ vlan_id }} SVI address {{ vlan_svi_ip }}
      is operational on {{ inventory_hostname }}
    fail_msg: >-
      Expected address {{ vlan_svi_ip }} was not found on
      {{ inventory_hostname }} interface {{ vlan_svi_name }}

- name: Display VLAN SVI result
  ansible.builtin.debug:
    msg:
      - "Device: {{ inventory_hostname }}"
      - "{{ vlan_svi_output['message'] }}"
ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
# Create new playbook
```
ubuntu@oob-mgmt-server:~/ansible_lab$ cat manage_vlan99.yml 
---
- name: Configure VLAN 99 on leaf switches
  hosts: leaf_sw
  gather_facts: false
  serial: 1

  roles:
    - role: cumulus_vlan_svi
      vars:
        vlan_id: 99
        vlan_svi_ip: "{{ vlan99_ip }}"
ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
# Check playbook syntax and tasks
```
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-playbook --syntax-check manage_vlan99.yml

playbook: manage_vlan99.yml
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-playbook manage_vlan99.yml --list-tasks

playbook: manage_vlan99.yml

  play #1 (leaf_sw): Configure VLAN 99 on leaf switches TAGS: []
    tasks:
      cumulus_vlan_svi : Validate VLAN SVI input variables      TAGS: []
      cumulus_vlan_svi : Display intended VLAN SVI configuration        TAGS: []
      cumulus_vlan_svi : Configure VLAN and SVI with NVUE       TAGS: []
      cumulus_vlan_svi : Query VLAN SVI IPv4 configuration      TAGS: []
      cumulus_vlan_svi : Validate applied VLAN SVI address      TAGS: []
      cumulus_vlan_svi : Display VLAN SVI result        TAGS: []
ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
# Run playbook on leaf01
```
ubuntu@oob-mgmt-server:~/ansible_lab$ ansible-playbook manage_vlan99.yml \
  --limit leaf01 \
  --ask-vault-pass
Vault password: 

PLAY [Configure VLAN 99 on leaf switches] *******************************************************************************************************************************

TASK [cumulus_vlan_svi : Validate VLAN SVI input variables] *************************************************************************************************************
ok: [leaf01] => {
    "changed": false,
    "msg": "VLAN 99 variables validated for leaf01"
}

TASK [cumulus_vlan_svi : Display intended VLAN SVI configuration] *******************************************************************************************************
ok: [leaf01] => {
    "msg": [
        "Device: leaf01",
        "Management IP: 192.168.200.6",
        "VLAN ID: 99",
        "SVI name: vlan99",
        "SVI address: 10.99.0.6/32",
        "Description: Configured by Ansible role on leaf01"
    ]
}

TASK [cumulus_vlan_svi : Configure VLAN and SVI with NVUE] **************************************************************************************************************
changed: [leaf01]

TASK [cumulus_vlan_svi : Query VLAN SVI IPv4 configuration] *************************************************************************************************************
ok: [leaf01]

TASK [cumulus_vlan_svi : Validate applied VLAN SVI address] *************************************************************************************************************
ok: [leaf01] => {
    "changed": false,
    "msg": "VLAN 99 SVI address 10.99.0.6/32 is operational on leaf01"
}

TASK [cumulus_vlan_svi : Display VLAN SVI result] ***********************************************************************************************************************
ok: [leaf01] => {
    "msg": [
        "Device: leaf01",
        "                operational   applied     \n--------------  ------------  ------------\nforward                       enabled     \nigmp              \n  state                       disabled    \nvrr                                       \n  state                       disabled    \nvrrp                     \n  state                       disabled    \ndhcp-client                               \n  state                       disabled    \n  set-hostname                disabled    \n[address]       10.99.0.6/32  10.99.0.6/32\n[gateway]                                 \n"
    ]
}

PLAY RECAP **************************************************************************************************************************************************************
leaf01                     : ok=6    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

ubuntu@oob-mgmt-server:~/ansible_lab$ 
```
