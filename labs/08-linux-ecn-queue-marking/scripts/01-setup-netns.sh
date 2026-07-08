#!/usr/bin/env bash
set -euo pipefail

CLIENT_NS="ecn-client"
ROUTER_NS="ecn-router"
SERVER_NS="ecn-server"

need_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "ERROR: run this script with sudo or as root"
        exit 1
    fi
}

need_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "ERROR: missing command: $1"
        exit 1
    fi
}

cleanup_existing() {
    ip netns del "${CLIENT_NS}" 2>/dev/null || true
    ip netns del "${ROUTER_NS}" 2>/dev/null || true
    ip netns del "${SERVER_NS}" 2>/dev/null || true
}

need_root
need_cmd ip
need_cmd tc

cleanup_existing

echo "Creating namespaces"
ip netns add "${CLIENT_NS}"
ip netns add "${ROUTER_NS}"
ip netns add "${SERVER_NS}"

echo "Creating veth links"
ip link add c-eth0 type veth peer name r-eth0
ip link add s-eth0 type veth peer name r-eth1

ip link set c-eth0 netns "${CLIENT_NS}"
ip link set r-eth0 netns "${ROUTER_NS}"
ip link set s-eth0 netns "${SERVER_NS}"
ip link set r-eth1 netns "${ROUTER_NS}"

echo "Configuring IP addresses"
ip netns exec "${CLIENT_NS}" ip addr add 10.10.1.1/24 dev c-eth0
ip netns exec "${ROUTER_NS}" ip addr add 10.10.1.254/24 dev r-eth0
ip netns exec "${ROUTER_NS}" ip addr add 10.10.2.254/24 dev r-eth1
ip netns exec "${SERVER_NS}" ip addr add 10.10.2.2/24 dev s-eth0

echo "Bringing interfaces up"
ip netns exec "${CLIENT_NS}" ip link set lo up
ip netns exec "${CLIENT_NS}" ip link set c-eth0 up

ip netns exec "${ROUTER_NS}" ip link set lo up
ip netns exec "${ROUTER_NS}" ip link set r-eth0 up
ip netns exec "${ROUTER_NS}" ip link set r-eth1 up

ip netns exec "${SERVER_NS}" ip link set lo up
ip netns exec "${SERVER_NS}" ip link set s-eth0 up

echo "Configuring routes"
ip netns exec "${CLIENT_NS}" ip route add default via 10.10.1.254
ip netns exec "${SERVER_NS}" ip route add default via 10.10.2.254

echo "Enabling IPv4 forwarding on router"
ip netns exec "${ROUTER_NS}" sysctl -qw net.ipv4.ip_forward=1

echo "Enabling TCP ECN in client and server namespaces"
ip netns exec "${CLIENT_NS}" sysctl -qw net.ipv4.tcp_ecn=1 || true
ip netns exec "${SERVER_NS}" sysctl -qw net.ipv4.tcp_ecn=1 || true

echo "Configuring HTB + RED ECN on router egress r-eth1"
ip netns exec "${ROUTER_NS}" tc qdisc replace dev r-eth1 root handle 1: htb default 10
ip netns exec "${ROUTER_NS}" tc class replace dev r-eth1 parent 1: classid 1:10 htb rate 5mbit ceil 5mbit
ip netns exec "${ROUTER_NS}" tc qdisc replace dev r-eth1 parent 1:10 handle 10: red \
    limit 100000 min 10000 max 30000 avpkt 1000 burst 20 probability 1.0 ecn

echo
echo "Topology interfaces:"
ip netns exec "${CLIENT_NS}" ip -br addr
ip netns exec "${ROUTER_NS}" ip -br addr
ip netns exec "${SERVER_NS}" ip -br addr

echo
echo "Router qdisc:"
ip netns exec "${ROUTER_NS}" tc -s qdisc show dev r-eth1

echo
echo "Basic reachability test:"
ip netns exec "${CLIENT_NS}" ping -c 3 -W 1 10.10.2.2

echo
echo "Setup complete"
