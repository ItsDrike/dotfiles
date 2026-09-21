# _SystemdQuote VALUE
#
# Prints VALUE quoted for use as one value in a systemd unit file. Escapes
# backslashes, double quotes, and systemd specifier prefixes.
_SystemdQuote() {
    local value=$1

    value=${value//\\/\\\\}
    value=${value//\"/\\\"}
    value=${value//%/%%}

    printf '"%s"' "$value"
}

# Persist SOURCE TARGET
#
# Makes SOURCE available at TARGET through a bind-mount unit enabled by
# local-fs.target. SOURCE must already exist below /persist or /data; this
# helper never creates or adopts persistent data. TARGET contents are ignored
# by aconfmgr, while the generated unit remains managed.
#
# The mount is active on the next boot. After aconfmgr apply, run
# `systemctl daemon-reload` and start the generated unit to activate it now.
Persist() {
    if (( $# != 2 )); then
        printf 'Usage: Persist SOURCE TARGET\n' >&2
        return 1
    fi

    local source="$1"
    local target="$2"
    local unit
    local unit_file
    local value
    local variable
    local path

    # Remove trailing slashes
    for variable in source target; do
        value=${!variable}

        while [[ "$value" != / && "$value" == */ ]]; do
            value=${value%/}
        done

        printf -v "$variable" '%s' "$value"
    done

    # Force absolute and normalized persist paths.
    # There is no reason there should be a relative reference in here.
    for path in "$source" "$target"; do
        case "$path" in
            /)
                printf 'Persist paths must not be root\n' >&2
                return 1
                ;;
            *$'\n'*|*$'\r'*|*'//'*|*/./*|*/../*|*/.|*/..)
                printf 'Persist paths must be normalized: %s\n' "$path" >&2
                return 1
                ;;
            /*)
                ;;
            *)
                printf 'Persist paths must be absolute: %s\n' "$path" >&2
                return 1
                ;;
        esac
    done

    # Sanity check on source
    # (prevents accidentally swapping target <-> source and ensures correct sources)
    case "$source" in
        /persist/* | /data/*) ;;
        *)
            printf 'Persist source must be below /persist or /data: %s\n' "$source" >&2
            return 1
    esac

    # Require the source to exist while evaluating the configuration. This catches
    # misspellings and missing persistent data before systemd attempts the mount.
    if [[ ! -e "$source" ]]; then
        printf 'Persist source does not exist: %s\n' "$source" >&2
        return 1
    fi

    # Persisted files shouldn't themselves be tracked by aconfmgr
    IgnorePath "$target"
    IgnorePath "$target/*"

    # Dynamically construct a systemd .mount unit
    unit="$(systemd-escape --path --suffix=mount "$target")"
    unit_file="$(CreateFile "/etc/systemd/system/$unit")"

    printf '%s\n' \
        '[Unit]' \
        "RequiresMountsFor=$(_SystemdQuote "$source")" \
        "AssertPathExists=$(_SystemdQuote "$source")" \
        'Before=local-fs.target' \
        '' \
        '[Mount]' \
        "What=$(_SystemdQuote "$source")" \
        "Where=$(_SystemdQuote "$target")" \
        'Type=none' \
        'Options=bind' \
        '' \
        '[Install]' \
        'WantedBy=local-fs.target' >"$unit_file"

    CreateLink \
        "/etc/systemd/system/local-fs.target.wants/$unit" \
        "../$unit"
}
