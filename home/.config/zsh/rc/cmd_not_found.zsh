if command -v pkgfile > /dev/null; then
    # Command not found hook that uses `pkgfile` package
    # to search through the package index in order to find
    # a package which includes given command, which was resolved
    # and not found, if there are no such packages, only print
    # command not found message
    command_not_found_handler() {
        cmd="$1"
        printf 'zsh: command not found: %s' "$cmd" # print command not found asap, then search for packages
        repos="$(pkgfile "$cmd")"
        if [ -n "$repos" ]; then
            printf '\r%s may be found in the following packages:\n' "$cmd"
            echo "$repos" | while read -r pkg; do
                printf '  %s\n' "$pkg"
            done
        else
            printf '\n'
        fi
        return 127
    }
elif [ -x /usr/lib/command-not-found ] || [ -x /usr/share/command-not-found/command-not-found ]; then
    # Ubuntu handle for bash default command-not-found
    # it works similarely to the above arch alternative,
    # this is based on the original bash implementation
    command_not_found_handler() {
        # check because cmd not found could've been removed in the meantime
        if [ -x /usr/lib/command-not-found ]; then
            /usr/lib/command-not-found -- "$1"
            return $?
        elif [ -x /usr/share/command-not-found/command-not-found ]; then
            /usr/share/command-not-found/command-not-found -- "$1"
            return $?
        else
            printf "%s: command not found\n" "$1" >&2
            return 127
        fi
    }
fi

