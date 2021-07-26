#!/bin/sh

readonly PREVIEW_ID="preview"

printf '{"action": "add", "identifier": "%s", "x": %d, "y": %d, "width": %d, "height": %d, "scaler": "contain", "scaling_position_x": 0.5, "scaling_position_y": 0.5, "path": "%s"}\n' \
    "$PREVIEW_ID" "$2" "$3" "$4" "$5" "$1" > "$FIFO_UEBERZUG"

#declare -p -A cmd=([action]=add [identifier]="$PREVIEW_ID" \
#   [x]="$2" [y]="$3" [max_width]="$4" [max_height]="$5" \
#   [path]="$1") > "$FIFO_UEBERZUG"

