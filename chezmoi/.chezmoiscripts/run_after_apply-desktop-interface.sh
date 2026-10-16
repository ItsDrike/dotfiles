#!/usr/bin/env bash
set -euo pipefail

# Keep the managed GSettings interface values in sync whenever Chezmoi applies
# this repository. A missing dconf binary is tolerated during bootstrap; a
# later Chezmoi apply, after the desktop packages are installed, imports them.
if command -v dconf >/dev/null 2>&1; then
    dconf load /org/gnome/desktop/interface/ < "$CHEZMOI_SOURCE_DIR/.chezmoitemplates/dconf/desktop-interface.ini"
fi
