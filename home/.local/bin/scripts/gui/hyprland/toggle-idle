#!/usr/bin/env bash
set -euo pipefail

idleprog="hypridle" # or swayidle

pid="$(pidof "$idleprog" || true)"
if [ -n "$pid" ]; then
  # is process suspended?
  if ps -o stat= -p "$pid" | grep T >/dev/null; then
    kill -CONT "$pid"
    notify-send "Idle-Toggle" "Idle timeouts enabled"
  else
    kill -STOP "$pid"
    notify-send "Idle-Toggle" "Idle timeouts disabled"
  fi
else
  notify-send "Idle-Toggle" "$idleprog not running!"
fi
