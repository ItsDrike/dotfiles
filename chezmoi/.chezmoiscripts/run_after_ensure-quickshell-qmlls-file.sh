#!/usr/bin/env bash
set -euo pipefail

# When quickshell detences a .qmlls.ini file next to shell.qml in it's config,
# it automatically replaces it with a dynamic symlink. We ignore the .qmlls.ini
# files from chezmoi, as we don't want to manage these as symlinks. That said,
# we do want quickshell to create these for us, which it only does if the file
# exists. This script checks for its existence in every subdir in the quickshell
# config, and creates a blank file if it wasn't found.
quickshell_dir="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell"
if [ -d "$quickshell_dir" ]; then
    while IFS= read -r -d '' directory; do
        target="$directory/.qmlls.ini"
        if [ ! -e "$target" ] && [ ! -L "$target" ]; then
            touch "$target"
        fi
    done < <(find "$quickshell_dir" -mindepth 1 -maxdepth 1 -type d -print0)
fi
