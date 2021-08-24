#!/bin/sh

# Automatically start the applications in $HOME/.config/autostart

AUTOSTART_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
find "$AUTOSTART_DIR" -name '*.desktop' -exec ~/.local/bin/scripts/deskopen "{}" \;
