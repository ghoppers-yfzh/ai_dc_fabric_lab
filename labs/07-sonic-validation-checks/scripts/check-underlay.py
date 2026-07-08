#!/usr/bin/env python3

import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import Any


def run_command(command: list[str], timeout: int = 20) -> tuple[int, str]:
    """Run a command and return return code and combined output."""
    try:
        result = subprocess.run(
            command,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            timeout=timeout,
            check=False,
        )
        return result.returncode, result.stdout
    except subprocess.TimeoutExpired as exc:
        output = exc.stdout or ""
        output += f"\nERROR: command timed out after {timeout} seconds\n"
        return 124, output


def strip_cidr(ip_with_cidr: str) -> str:
    """Convert 10.0.11.0/31 to 10.0.11.0."""
    return ip_with_cidr.split("/", 1)[0]


def docker_exec(container: str, inner_command: list[str], timeout: int = 20) -> tuple[int, str]:
    """Run a command inside a container."""
    return run_command(["docker", "exec", container, *inner_command], timeout=timeout)


def load_json(path: Path) -> list[dict[str, Any]]:
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def node_map(data: list[dict[str, Any]]) -> dict[str, dict[str, Any]]:
    return {item["node"]: item for item in data}


def add_result(results: list[dict[str, Any]], passed: bool, name: str, command: list[str], output: str) -> None:
    results.append(
        {
            "passed": passed,
            "name": name,
            "command": " ".join(command),
            "output": output.strip(),
        }
    )


def write_summary(output_file: Path, results: list[dict[str, Any]]) -> None:
    output_file.parent.mkdir(parents=True, exist_ok=True)

    with output_file.open("w", encoding="utf-8") as f:
        f.write("# Lab 07 SONiC Underlay Check Summary\n\n")

        passed_count = sum(1 for item in results if item["passed"])
        failed_count = sum(1 for item in results if not item["passed"])

        f.write("## Result\n\n")
        if failed_count == 0:
            f.write("RESULT: PASS\n\n")
        else:
            f.write("RESULT: FAIL\n\n")

        f.write(f"- Passed: {passed_count}\n")
        f.write(f"- Failed: {failed_count}\n\n")

        f.write("## Checks\n\n")
        for item in results:
            status = "PASS" if item["passed"] else "FAIL"
            f.write(f"### {status} - {item['name']}\n\n")
            f.write("Command:\n\n")
            f.write("```bash\n")
            f.write(item["command"] + "\n")
            f.write("```\n\n")

            if item["output"]:
                f.write("Output:\n\n")
                f.write("```text\n")
                f.write(item["output"] + "\n")
                f.write("```\n\n")


def check_container(node: str, container: str, results: list[dict[str, Any]]) -> None:
    command = ["docker", "inspect", container]
    rc, output = run_command(command, timeout=10)
    add_result(
        results,
        rc == 0,
        f"{node} container exists",
        command,
        output,
    )


def check_direct_peer_ping(node: str, container: str, link: dict[str, str], results: list[dict[str, Any]]) -> None:
    peer = link["peer"]
    peer_ip = strip_cidr(link["peer_ip"])
    command = ["docker", "exec", container, "ping", "-c", "3", "-W", "1", peer_ip]
    rc, output = run_command(command, timeout=15)
    add_result(
        results,
        rc == 0,
        f"{node} -> {peer} direct peer ping ({peer_ip})",
        command,
        output,
    )


def check_bgp_summary(node: str, container: str, expected_peer_ips: list[str], results: list[dict[str, Any]]) -> None:
    command = ["docker", "exec", container, "vtysh", "-c", "show ip bgp summary"]
    rc, output = run_command(command, timeout=20)

    missing_peers = [peer_ip for peer_ip in expected_peer_ips if peer_ip not in output]
    passed = rc == 0 and not missing_peers

    if missing_peers:
        output += "\nMissing expected BGP peers: " + ", ".join(missing_peers) + "\n"

    add_result(
        results,
        passed,
        f"{node} BGP summary contains expected peers",
        command,
        output,
    )


def check_bgp_routes(node: str, container: str, remote_loopbacks: list[str], results: list[dict[str, Any]]) -> None:
    command = ["docker", "exec", container, "vtysh", "-c", "show ip route bgp"]
    rc, output = run_command(command, timeout=20)

    missing_routes = [f"{loopback}/32" for loopback in remote_loopbacks if f"{loopback}/32" not in output]
    passed = rc == 0 and not missing_routes

    if missing_routes:
        output += "\nMissing expected BGP routes: " + ", ".join(missing_routes) + "\n"

    add_result(
        results,
        passed,
        f"{node} BGP routes contain remote loopbacks",
        command,
        output,
    )


def check_loopback_ping(
    node: str,
    container: str,
    local_loopback: str,
    target_node: str,
    target_loopback: str,
    results: list[dict[str, Any]],
) -> None:
    command = [
        "docker",
        "exec",
        container,
        "ping",
        "-I",
        local_loopback,
        "-c",
        "3",
        "-W",
        "1",
        target_loopback,
    ]
    rc, output = run_command(command, timeout=15)

    add_result(
        results,
        rc == 0,
        f"{node} ({local_loopback}) -> {target_node} loopback ({target_loopback})",
        command,
        output,
    )


def main() -> int:
    script_dir = Path(__file__).resolve().parent
    lab07_dir = script_dir.parent
    repo_root = lab07_dir.parent.parent

    default_ip_asn_file = repo_root / "labs" / "06-sonic-automation" / "ip_asn.json"
    default_output_file = lab07_dir / "outputs" / "check-underlay-summary.md"

    parser = argparse.ArgumentParser(
        description="Check SONiC underlay reachability using Lab 06 ip_asn.json."
    )
    parser.add_argument(
        "--ip-asn-file",
        default=str(default_ip_asn_file),
        help="Path to Lab 06 ip_asn.json.",
    )
    parser.add_argument(
        "--clab-prefix",
        default="clab-06-sonic-automation",
        help="Containerlab container prefix.",
    )
    parser.add_argument(
        "--output-file",
        default=str(default_output_file),
        help="Markdown output file.",
    )

    args = parser.parse_args()

    ip_asn_file = Path(args.ip_asn_file)
    output_file = Path(args.output_file)

    if not ip_asn_file.exists():
        print(f"ERROR: cannot find {ip_asn_file}")
        return 1

    data = load_json(ip_asn_file)
    nodes = node_map(data)
    results: list[dict[str, Any]] = []

    all_loopbacks = {
        node_name: item["parameters"]["loopback"]
        for node_name, item in nodes.items()
    }

    for node_name, item in nodes.items():
        container = f"{args.clab_prefix}-{node_name}"
        parameters = item["parameters"]
        local_loopback = parameters["loopback"]
        links = parameters["links"]

        check_container(node_name, container, results)

        for link in links:
            check_direct_peer_ping(node_name, container, link, results)

        expected_peer_ips = [strip_cidr(link["peer_ip"]) for link in links]
        check_bgp_summary(node_name, container, expected_peer_ips, results)

        remote_loopbacks = [
            loopback
            for target_node, loopback in all_loopbacks.items()
            if target_node != node_name
        ]
        check_bgp_routes(node_name, container, remote_loopbacks, results)

        for target_node, target_loopback in all_loopbacks.items():
            if target_node == node_name:
                continue

            check_loopback_ping(
                node_name,
                container,
                local_loopback,
                target_node,
                target_loopback,
                results,
            )

    write_summary(output_file, results)

    failed_count = sum(1 for item in results if not item["passed"])

    print(f"Validation summary saved to: {output_file}")
    if failed_count == 0:
        print("RESULT: PASS")
        return 0

    print(f"RESULT: FAIL ({failed_count} failed checks)")
    return 1


if __name__ == "__main__":
    sys.exit(main())
