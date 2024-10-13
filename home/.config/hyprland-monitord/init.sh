#!/bin/bash
set -euo pipefail

MONITORS_AMT="$(hyprctl monitors -j | jq length)"

if [ "$MONITORS_AMT" -lt 1 ]; then
  >&2 echo "You seem to have 0 monitors..."
  exit 1
fi

if [ "$MONITORS_AMT" -eq 2 ]; then
  eww open bar1
fi

if [ "$MONITORS_AMT" -eq 1 ]; then
  eww active-windows | grep "bar1" && eww close bar1
fi

if [ "$MONITORS_AMT" -gt 2 ]; then
  >&2 echo "Unexpected monitor configuration (more than 2 monitors)"
  exit 1
fi
