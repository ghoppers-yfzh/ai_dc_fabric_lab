#!/usr/bin/env bash
set -euo pipefail

CLIENT_NS="ecn-client"
SERVER_NS="ecn-server"
ROUTER_NS="ecn-router"
SERVER_IP="10.10.2.2"
OUTPUT_DIR="$(cd "$(dirname "$0")/.." && pwd)/outputs"

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

need_ns() {
    if ! ip netns list | awk '{print $1}' | grep -qx "$1"; then
        echo "ERROR: missing namespace: $1"
        echo "Run scripts/01-setup-netns.sh first"
        exit 1
    fi
}

need_root
need_cmd ip
need_cmd tc
need_cmd iperf3

need_ns "${CLIENT_NS}"
need_ns "${ROUTER_NS}"
need_ns "${SERVER_NS}"

mkdir -p "${OUTPUT_DIR}"

echo "# qdisc before traffic" > "${OUTPUT_DIR}/qdisc-before.md"
echo '```text' >> "${OUTPUT_DIR}/qdisc-before.md"
ip netns exec "${ROUTER_NS}" tc -s qdisc show dev r-eth1 >> "${OUTPUT_DIR}/qdisc-before.md"
echo '```' >> "${OUTPUT_DIR}/qdisc-before.md"

echo "Starting iperf3 server in ${SERVER_NS}"
ip netns exec "${SERVER_NS}" pkill iperf3 2>/dev/null || true
ip netns exec "${SERVER_NS}" iperf3 -s -D --logfile /tmp/lab08-iperf3-server.log
sleep 1

echo "Running iperf3 client from ${CLIENT_NS} to ${SERVER_IP}"
ip netns exec "${CLIENT_NS}" iperf3 -c "${SERVER_IP}" -t 20 -P 4 | tee "${OUTPUT_DIR}/iperf3-client.txt"

echo "# qdisc after traffic" > "${OUTPUT_DIR}/qdisc-after.md"
echo '```text' >> "${OUTPUT_DIR}/qdisc-after.md"
ip netns exec "${ROUTER_NS}" tc -s qdisc show dev r-eth1 >> "${OUTPUT_DIR}/qdisc-after.md"
echo '```' >> "${OUTPUT_DIR}/qdisc-after.md"

echo
echo "Traffic test complete"
echo "Saved:"
echo "- ${OUTPUT_DIR}/qdisc-before.md"
echo "- ${OUTPUT_DIR}/qdisc-after.md"
echo "- ${OUTPUT_DIR}/iperf3-client.txt"
