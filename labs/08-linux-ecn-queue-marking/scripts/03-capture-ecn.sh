#!/usr/bin/env bash
set -euo pipefail

CLIENT_NS="ecn-client"
SERVER_NS="ecn-server"
ROUTER_NS="ecn-router"
SERVER_IP="10.10.2.2"
LAB_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_DIR="${LAB_DIR}/outputs"
PCAP="${OUTPUT_DIR}/ecn-r-eth1.pcap"
SUMMARY="${OUTPUT_DIR}/ecn-summary.md"

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

count_packets() {
    local filter="$1"
    tcpdump -nn -r "${PCAP}" "${filter}" 2>/dev/null | wc -l
}

need_root
need_cmd ip
need_cmd tc
need_cmd iperf3
need_cmd tcpdump

need_ns "${CLIENT_NS}"
need_ns "${ROUTER_NS}"
need_ns "${SERVER_NS}"

mkdir -p "${OUTPUT_DIR}"
rm -f "${PCAP}" "${SUMMARY}"

echo "Starting iperf3 server in ${SERVER_NS}"
ip netns exec "${SERVER_NS}" pkill iperf3 2>/dev/null || true
ip netns exec "${SERVER_NS}" iperf3 -s -D --logfile /tmp/lab08-iperf3-server.log
sleep 1

echo "Starting tcpdump capture on ${ROUTER_NS}:r-eth1"
ip netns exec "${ROUTER_NS}" timeout 25 tcpdump -i r-eth1 -s 128 -nn -w "${PCAP}" ip >/tmp/lab08-tcpdump.log 2>&1 &
TCPDUMP_PID=$!

sleep 2

echo "Running traffic while capturing"
ip netns exec "${CLIENT_NS}" iperf3 -c "${SERVER_IP}" -t 18 -P 8 > "${OUTPUT_DIR}/iperf3-capture-client.txt"

wait "${TCPDUMP_PID}" || true

echo "Counting ECN bits from pcap"

TOTAL_IP=$(count_packets "ip")
ECN_CAPABLE=$(count_packets "ip[1] & 0x03 != 0")
CE_PACKETS=$(count_packets "ip[1] & 0x03 == 3")
ECT0_PACKETS=$(count_packets "ip[1] & 0x03 == 2")
ECT1_PACKETS=$(count_packets "ip[1] & 0x03 == 1")
NOT_ECT_PACKETS=$(count_packets "ip[1] & 0x03 == 0")

{
    echo "# Lab 08 ECN Capture Summary"
    echo
    echo "## Packet Counts"
    echo
    echo '```text'
    echo "Total IPv4 packets: ${TOTAL_IP}"
    echo "Not-ECT packets: ${NOT_ECT_PACKETS}"
    echo "ECT(0) packets: ${ECT0_PACKETS}"
    echo "ECT(1) packets: ${ECT1_PACKETS}"
    echo "ECN-capable packets: ${ECN_CAPABLE}"
    echo "Congestion Experienced packets: ${CE_PACKETS}"
    echo '```'
    echo
    echo "## Router qdisc Counters"
    echo
    echo '```text'
    ip netns exec "${ROUTER_NS}" tc -s qdisc show dev r-eth1
    echo '```'
    echo
    echo "## Files"
    echo
    echo '```text'
    echo "${PCAP}"
    echo "${OUTPUT_DIR}/iperf3-capture-client.txt"
    echo '```'
} > "${SUMMARY}"

echo
echo "Capture complete"
echo "Saved:"
echo "- ${PCAP}"
echo "- ${SUMMARY}"
cat "${SUMMARY}"
