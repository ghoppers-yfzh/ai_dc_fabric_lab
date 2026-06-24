# Lessons Learned

This file collects practical lessons from the labs.

It should grow gradually. Keep the notes short, specific, and based on real lab behavior.

---

## Lab 00 — Platform Validation

- Prove the platform before building larger topologies.
- Save smoke-test output. It becomes useful later when troubleshooting whether a failure is caused by the lab platform or by the actual network design.
- `containerlab destroy --cleanup` is useful when rebuilding a lab from a clean state.

---

## Lab 01 — FRR Leaf-Spine

- Start with one BGP session before validating the whole fabric.
- Direct link reachability, BGP session state, route learning, and end-to-end reachability are different checks.
- Loopback reachability is a stronger success signal than interface-to-interface ping.
- ECMP should be validated explicitly instead of assumed.
- Failure testing should be documented while the topology is still small.

---

## Lab 02 — EVPN/VXLAN

- Underlay and overlay should be validated separately.
- VTEP loopbacks must be reachable before VXLAN can work.
- EVPN control plane visibility does not automatically prove VXLAN data-plane forwarding.
- Start with one L2VNI before adding L3VNI, VRF, anycast gateway, or multiple tenants.
- EVPN/VXLAN is useful for modern fabric learning, but it does not cover RoCEv2 or lossless Ethernet behavior.

---

## Lab 03 — SONiC Containerlab

- SONiC VS is useful for learning the SONiC operational model, but it is not the same as a hardware switch.
- `eth0` is management. Data links start at `eth1`.
- In SONiC, `eth1` maps to `Ethernet0`.
- Linux commands are still useful for validation, especially when a SONiC wrapper command behaves unexpectedly.
- ConfigDB is central to SONiC configuration, but runtime state still needs to be checked.

---

## Lab 04 — SONiC eBGP

- IP configured on `Ethernet0` does not prove the underlying containerlab veth link is passing traffic.
- If cross-ping fails and `ip neigh` shows `FAILED`, check ARP and the Linux-side veth interface before checking BGP.
- In this SONiC VS image, `eth1` needed to be brought up for traffic to pass.
- `show ip interfaces` failed in this image because the wrapper tried to call `sudo`.
- `vtysh` can open even when `bgpd` is not running.
- `bgpd=yes` in `/etc/frr/daemons` is not proof that the `bgpd` process is currently running.
- BGP config loaded correctly only after `bgpd` was started.

---

## Lab 05 — SONiC Leaf-Spine eBGP

- The SONiC leaf-spine underlay follows the same routing logic as the FRR underlay, but the runtime workflow is different.
- Bring up data-side veth links before testing direct pings.
- Start `bgpd` before loading FRR BGP config.
- Validate direct pings before BGP.
- Validate BGP sessions before route learning.
- Validate route learning before loopback-to-loopback pings.
- Leaf-to-leaf loopback ping is the most useful end-to-end success check for this lab.

---

## Cross-Lab Lessons

- Do not automate a workflow until the manual behavior is understood.
- Keep config files reviewable.
- Save validation output after each successful lab.
- Document workarounds honestly instead of hiding them.
- Virtual labs are excellent for control-plane learning, but they do not prove real hardware performance.
- A good lab is not only something that works. It should also explain how it was validated and what it cannot prove.

---

## AI Fabric Reading Lessons

- AI fabric learning should build on the existing routed fabric and EVPN/VXLAN labs, but it should not pretend those labs prove RoCEv2 performance.
- EVPN/VXLAN provides a modern overlay and segmentation model, but it does not directly solve RDMA loss sensitivity or congestion control.
- RoCEv2/lossless Ethernet concepts should be understood as one system: ECN for early warning, DCQCN for sender-side rate control, PFC as the emergency brake, buffer management as braking distance, and telemetry as visibility.
- PFC is useful but risky. Frequent PFC pause is usually a symptom to investigate, not a success signal.
- Virtual labs are useful for control-plane learning and validation discipline, but real PFC/ECN/DCQCN behavior depends on switch ASICs, NICs, queues, and physical traffic patterns.
