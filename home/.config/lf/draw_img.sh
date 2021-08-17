#!/bin/sh

path="$1"
x="$2"
y="$3"
width="$4"
height="$5"
PREVIEW_ID="preview"

if [ -n "$FIFO_UEBERZUG" ]; then
    printf '{"action": "add", "identifier": "%s", "x": %d, "y": %d, "width": %d, "height": %d, "scaler": "contain", "scaling_position_x": 0.5, "scaling_position_y": 0.5, "path": "%s"}\n' \
        "$PREVIEW_ID" "$x" "$y" "$width" "$height" "$path" > "$FIFO_UEBERZUG"
else
    # Ueberzug isn't avialable, try to use pixterm
    if command -v pixterm > /dev/null; then
        pixterm -s 2 -tr "$x" -tc "$width" "$path"
    else
        >&2 echo "ueberzug not running, pixterm fallback not found!"
        exit 1
    fi
fi
