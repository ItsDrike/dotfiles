#!/bin/bash
set -euo pipefail

MONITOR_NAME="$1"

systemctl --user stop eww-window@bar1.service
# eww close bar1
