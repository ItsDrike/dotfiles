# Provide package suggestions when an entered command cannot be found.

if (( $+commands[pkgfile] )); then
    # On Arch Linux, use pkgfile's package index to search for packages that
    # provide the missing command.
    command_not_found_handler() {
        local cmd="$1"
        local repos

        # Print the normal error immediately, since searching the package index
        # may take a noticeable amount of time.
        printf 'zsh: command not found: %s' "$cmd" >&2

        repos="$(pkgfile "$cmd")"

        if [[ -n $repos ]]; then
            # Return to the beginning of the diagnostic line and replace it
            # with the more useful package suggestion.
            printf '\r%s may be found in the following packages:\n' "$cmd" >&2

            while IFS= read -r pkg; do
                printf '  %s\n' "$pkg" >&2
            done <<< "$repos"
        else
            printf '\n' >&2
        fi

        return 127
    }

elif [[ -x /usr/lib/command-not-found ||
        -x /usr/share/command-not-found/command-not-found ]]; then
    # Debian/Ubuntu command-not-found implementation.
    command_not_found_handler() {
        # Check again at invocation time in case the package providing the
        # helper was removed after this shell started.
        if [[ -x /usr/lib/command-not-found ]]; then
            /usr/lib/command-not-found -- "$1"
            return $?
        elif [[ -x /usr/share/command-not-found/command-not-found ]]; then
            /usr/share/command-not-found/command-not-found -- "$1"
            return $?
        else
            printf 'zsh: command not found: %s\n' "$1" >&2
            return 127
        fi
    }
fi
