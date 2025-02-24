#!/bin/bash
set -euo pipefail

MONITORS_AMT="$(hyprctl monitors -j | jq length)"

if [ "$MONITORS_AMT" -lt 1 ]; then
  >&2 echo "You seem to have 0 monitors..."
  exit 1
fi

if [ "$MONITORS_AMT" -eq 2 ]; then
  systemctl --user start eww-window@bar1.service
  #eww open bar1
fi

if [ "$MONITORS_AMT" -eq 1 ]; then
  if eww active-windows | grep "bar1"; then
    systemctl --user stop eww-window@bar1.service
    #eww close bar1
  fi
fi

if [ "$MONITORS_AMT" -gt 2 ]; then
  >&2 echo "Unexpected monitor configuration (more than 2 monitors)"
  exit 1
fi
