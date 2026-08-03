# Subnet Manger
Three tasks for SM in operation phase
- Master election # One master at a time
- Failure monitoring # Check master, swtich, port and link failure
- Fabric convergence # Recalculate the LFT after topology change

Only one Master SM, other SM nodes in standby

## Master SM election
- SM priority
- Port GUID

SM priority is a 4-bit value, 0-15.
0 is the highest and 15 is the lowest

For same priority, compare GUID, smaller GUID wins.

```
Highest Priority wins
        ↓
If tied
        ↓
Lowest GUID wins
```

## SMinfor and SM states
SMinfor includes:
- GUID for SM's port
- Priority
- SM State
- Activity Count
- Information about Master/Standby monitor

Standby SM will check Master's SMInfo periodiclly.

SM states:
- 0, NOTACTIVE # SM is not in the current management
- 1, DISCOVERING # SM is discovering Fabric
- 2, STANDBY # SM is Standby
- 3, MASTER # SM is Master

## Failover
Master failure

```
SM-A Priority 14 → MASTER
SM-B Priority 13 → STANDBY
    |
    V
SM-A ✕
SM-B can't detect Master
    |
    V
SM-B:
STANDBY
   ↓
DISCOVERING / takeover
   ↓
MASTER
```
After failover, the new Master will try to reserve the original LID by:
1. Load the GUID to LID DB
2. Recover from node's current state, in  `PortInfo.BaseLID`
The new master will try to keep the current state.


## Handover
SM with higher priority

Starts with
SM-A Priority 10 → MASTER

SM-B starts with Priority 14

SM-A → STANDBY
SM-B → MASTER

## Control plane vs Data plane
When SM fails, the current traffic forwarding is not impacted.
Because SM doesn't do forwarding, only dispatch LFT.
However any new connection still requires SM.

## Avoide double failover

double failover:
```
SM-A Master
   ↓ failure
SM-B Master
   ↓ SM-A recover and holds hihger Priority
SM-A Master

One Failover + one Handover
```

Master SM priority to avoide double failover

```
SM-A configured priority = 14
SM-B configured priority = 13
Master SM Priority       = 15
```
When SM-B becomes Master, it's Master Priority is set to 15.
When SM-A recovers, the Master remains on SM-B

# Monitoring Fabric
When Fabric is in operational status, the SM keeps excuting sweeping.
Sweeping checks fabric state periodically.
- Light sweep
- Heavy sweep

## Light sweep
By default SM run light sweep every 10 sec.
Light sweep checks:
- Switch port state
- Any port up/down
- Any new node
- Any new SM
- Any SM master/standby change
- Any topology change
```
Light Sweep
    ↓
Load switchport state
    ↓
Any change?
   / \
 No   Yes
 │      │
 End   trigger Heavy Sweep
```


## Trap
Switch/port send InfiniBand Trap to SM.

```
Link Down
    ↓
Switch sends Trap
    ↓
Master SM receiver Trap
    ↓
Trigger action
```

## Heavy Sweep
Rediscover and calculate fabric
Following event triggers Heavy Sweep
1. Light Seeep detects change
2. Recieve Trap
3. Manual trigger by admin
4. SM believe the fabric state needs rebuild

Flow:
```
Discover topology
        ↓
Read NodeInfo / PortInfo
        ↓
Build topology database
        ↓
Check / assign LIDs
        ↓
Calculate paths
        ↓
Program switch LFTs
        ↓
Configure nodes and ports
```

# Failure
## SM failure, data path still works
- Orignial LFT still works
- Physical path works
- Current session works

## Link / switch failure
When a link fails, the traffic on the path is interrupted.
SM will recalculate the path and comminication recovers.
The traffic doesn't go though the failure area is not impacted.

# OFED tools
## sminfo
Check current Master SM
output:
- sm lid
- sm guid
- activity count
- priority
- state

## smpquery ND <LID>
ND is node description

smpquery ND 1: Check LID 1's node description

For checking master SM's node:
```
sminfo
  ↓
Get Master SM LID
  ↓
smpquery ND <SM_LID>
  ↓
Locate Master SM running node
```

## saquery -s
Check all the SM in Subnet administration DB.
List:
- Master
- Standby
- GUID
- LID
- Priority
- State


```
# 1. Check Master SM
sminfo

# 2. Check Master SM node
smpquery ND <sm_lid>

# 3. Check Standby SM
saquery -s

# 4. Check Fabric port and LID
ibstat
iblinkinfo

# 5. Check topology
ibnetdiscover

# 6. Check port error or path problem
ibdiagnet
```

