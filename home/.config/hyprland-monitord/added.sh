#!/bin/bash
set -euo pipefail

MONITOR_ID="$1"
MONITOR_NAME="$2"
MONITOR_DESCRIPTION="$3"

systemctl --user start eww-window@bar1.service
#eww open bar1
