#!/usr/bin/env bash
set -euo pipefail
agent="${1:-nexus}"
intent="${2:-generate_segment}"
echo "[Omega9] directive agent=${agent} intent=${intent}"
