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

need_root

for ns in "${CLIENT_NS}" "${ROUTER_NS}" "${SERVER_NS}"; do
    if ip netns list | awk '{print $1}' | grep -qx "${ns}"; then
        echo "Cleaning namespace ${ns}"
        ip netns exec "${ns}" pkill iperf3 2>/dev/null || true
        ip netns del "${ns}"
    fi
done

echo "Cleanup complete"
