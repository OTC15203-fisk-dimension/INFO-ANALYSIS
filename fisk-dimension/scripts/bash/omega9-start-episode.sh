#!/usr/bin/env bash
set -euo pipefail
episode_id="${1:-EP-001}"
env_name="${2:-dev}"
echo "[Omega9] start episode: ${episode_id} env=${env_name}"
