from __future__ import annotations

import json
import platform
import shutil
import socket
import subprocess
import sys

from runtime import REPORTS, ROOT, RuntimeFailure, command, ensure_local_dirs, write_json

MIN_CPUS = 4
MIN_MEMORY_BYTES = 8 * 1024**3


def port_available(port: int) -> bool:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        try:
            sock.bind(("127.0.0.1", port))
        except OSError:
            return False
    return True


def main() -> int:
    ensure_local_dirs()
    findings: dict[str, object] = {
        "architecture": platform.machine(),
        "python": platform.python_version(),
        "required_cpus": MIN_CPUS,
        "required_memory_bytes": MIN_MEMORY_BYTES,
    }
    if platform.machine() not in {"arm64", "aarch64"}:
        raise RuntimeFailure("This local profile requires native ARM64")
    for binary in ("docker", "openssl", "git"):
        if not shutil.which(binary):
            raise RuntimeFailure(f"Required executable not found: {binary}")

    info_raw = command(["docker", "info", "--format", "{{json .}}"], timeout=15).stdout.strip()
    info = json.loads(info_raw)
    cpus = int(info.get("NCPU", 0))
    memory = int(info.get("MemTotal", 0))
    findings.update({"docker_cpus": cpus, "docker_memory_bytes": memory})
    if cpus < MIN_CPUS:
        raise RuntimeFailure(f"Docker exposes {cpus} CPUs; at least {MIN_CPUS} required")
    if memory < MIN_MEMORY_BYTES:
        raise RuntimeFailure(
            f"Docker exposes {memory / 1024**3:.2f} GiB; at least 8.00 GiB required"
        )

    compose = command(["docker", "compose", "version", "--short"]).stdout.strip()
    findings["docker_compose"] = compose
    if sys.platform == "darwin":
        filevault = subprocess.run(
            ["/usr/bin/fdesetup", "status"], check=False, capture_output=True, text=True
        ).stdout.strip()
        findings["filevault"] = filevault
        if "On" not in filevault:
            raise RuntimeFailure("FileVault must be enabled for local persistent data")

    occupied = [port for port in (1521, 1522, 8443) if not port_available(port)]
    running = command(
        ["docker", "compose", "ps", "--status", "running", "--quiet"], check=False
    ).stdout.strip()
    if occupied and not running:
        raise RuntimeFailure(f"Required loopback ports are occupied: {occupied}")
    findings["ports_available_or_project_running"] = True
    findings["workspace"] = str(ROOT)
    findings["status"] = "PASS"
    write_json(REPORTS / "preflight.json", findings)
    print("Preflight passed")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except RuntimeFailure as exc:
        print(f"Preflight failed: {exc}", file=sys.stderr)
        raise SystemExit(1) from exc
