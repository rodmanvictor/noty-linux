#!/usr/bin/env bash

set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output_dir="${project_dir}/build/visual-snapshots"
output_path="${1:-${output_dir}/desktop-latest.png}"

if ! command -v spectacle >/dev/null 2>&1; then
    echo "Spectacle is required to capture the live Plasma state." >&2
    exit 1
fi

mkdir -p "$(dirname "${output_path}")"
spectacle --fullscreen --background --nonotify --output "${output_path}"

for _ in $(seq 1 40); do
    if [[ -s "${output_path}" ]]; then
        realpath "${output_path}"
        exit 0
    fi
    sleep 0.05
done

echo "Spectacle did not create ${output_path}." >&2
exit 1
