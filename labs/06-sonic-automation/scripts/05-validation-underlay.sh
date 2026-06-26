#!/usr/bin/env bash

set -u

LAB_DIR="$(cd "$(dirname "$0")/.." && pwd)"
IP_ASN_FILE="${LAB_DIR}/ip_asn.json"
OUTPUT_DIR="${LAB_DIR}/outputs"
OUTPUT_FILE="${OUTPUT_DIR}/underlay-validation.md"

CLAB_PREFIX="clab-06-sonic-automation"

mkdir -p "${OUTPUT_DIR}"
: > "${OUTPUT_FILE}"

echo "# SONiC Underlay Validation" | tee -a "${OUTPUT_FILE}"
echo | tee -a "${OUTPUT_FILE}"

for node in $(jq -r '.[].node' "${IP_ASN_FILE}"); do
    container="${CLAB_PREFIX}-${node}"

    echo "## Validate ${node}" | tee -a "${OUTPUT_FILE}"
    echo | tee -a "${OUTPUT_FILE}"

    echo "### Interface addresses" | tee -a "${OUTPUT_FILE}"
    echo "\$ docker exec ${container} ip -br addr" | tee -a "${OUTPUT_FILE}"
    docker exec "${container}" ip -br addr 2>&1 | tee -a "${OUTPUT_FILE}"
    echo | tee -a "${OUTPUT_FILE}"

    echo "### Direct peer ping" | tee -a "${OUTPUT_FILE}"

    jq -r \
        --arg node "${node}" \
        '.[] | select(.node == $node) | .parameters.links[] | [.peer, .peer_ip] | @tsv' \
        "${IP_ASN_FILE}" |
    while IFS=$'\t' read -r peer peer_ip_cidr; do
        peer_ip="${peer_ip_cidr%%/*}"

        echo "- ${node} -> ${peer}: ${peer_ip}" | tee -a "${OUTPUT_FILE}"
        echo "\$ docker exec ${container} ping -c 3 -W 1 ${peer_ip}" | tee -a "${OUTPUT_FILE}"
        docker exec "${container}" ping -c 3 -W 1 "${peer_ip}" 2>&1 | tee -a "${OUTPUT_FILE}"
        echo | tee -a "${OUTPUT_FILE}"
    done

    echo "### BGP summary" | tee -a "${OUTPUT_FILE}"
    echo "\$ docker exec ${container} vtysh -c 'show ip bgp summary'" | tee -a "${OUTPUT_FILE}"
    docker exec "${container}" vtysh -c "show ip bgp summary" 2>&1 | tee -a "${OUTPUT_FILE}"
    echo | tee -a "${OUTPUT_FILE}"

    echo "### BGP routes" | tee -a "${OUTPUT_FILE}"
    echo "\$ docker exec ${container} vtysh -c 'show ip route bgp'" | tee -a "${OUTPUT_FILE}"
    docker exec "${container}" vtysh -c "show ip route bgp" 2>&1 | tee -a "${OUTPUT_FILE}"
    echo | tee -a "${OUTPUT_FILE}"

    echo "### Loopback reachability" | tee -a "${OUTPUT_FILE}"
    
    local_loopback=$(jq -r --arg node "${node}" '.[] | select(.node == $node) | .parameters.loopback' "${IP_ASN_FILE}")
    
    jq -r '.[] | [.node, .parameters.loopback] | @tsv' "${IP_ASN_FILE}" |
    while IFS=$'\t' read -r target_node target_loopback; do
        if [ "${target_node}" = "${node}" ]; then
            continue
        fi
    
        echo "- ${node} (${local_loopback}) -> ${target_node}: ${target_loopback}" | tee -a "${OUTPUT_FILE}"
        echo "\$ docker exec ${container} ping -I ${local_loopback} -c 3 -W 1 ${target_loopback}" | tee -a "${OUTPUT_FILE}"
        docker exec "${container}" ping -I "${local_loopback}" -c 3 -W 1 "${target_loopback}" 2>&1 | tee -a "${OUTPUT_FILE}"
        echo | tee -a "${OUTPUT_FILE}"
    done

    echo "---" | tee -a "${OUTPUT_FILE}"
    echo | tee -a "${OUTPUT_FILE}"
done

echo "Validation output saved to: ${OUTPUT_FILE}"