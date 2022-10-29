#!/bin/sh

readonly PREVIEW_ID="preview"

printf '{"action": "remove", "identifier": "%s"}\n' "$PREVIEW_ID" > "$FIFO_UEBERZUG"

