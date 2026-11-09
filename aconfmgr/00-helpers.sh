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

# _SourceConfigScript TYPE PATH
#
# Sources a configuration script with a nested aconfmgr log entry.
_SourceConfigScript() {
    local type=$1
    local path=$2

    LogEnter 'Sourcing %s %s...\n' "$type" "$(Color C '%q' "$path")"
    source "$path" || {
        LogLeave ''
        return 1
    }
    LogLeave ''
}

# SourceProfile PROFILE
#
# Loads an explicitly selected host profile, emitting an indented aconfmgr log
# entry while it is evaluated. PROFILE is relative to the profiles directory.
SourceProfile() {
    if (( $# != 1 )); then
        FatalError 'Usage: SourceProfile PROFILE\n'
        return 1
    fi

    local profile_root
    local profile

    profile_root="$(dirname -- "${BASH_SOURCE[0]}")/profiles"
    profile="$profile_root/$1"

    _SourceConfigScript profile "$profile"
}

# SourceHost HOST
#
# Loads the selected host configuration. HOST is relative to the hosts
# directory.
SourceHost() {
    if (( $# != 1 )); then
        FatalError 'Usage: SourceHost HOST\n'
        return 1
    fi

    local host_root
    local host

    host_root="$(dirname -- "${BASH_SOURCE[0]}")/hosts"
    host="$host_root/$1"

    _SourceConfigScript host "$host"
}

# SourceModules
#
# Loads shared default configuration modules in deterministic path order.
# Profiles and hosts remain explicitly selected by their respective loaders.
SourceModules() {
    local config_root
    local module_root
    local module
    local -a modules

    config_root="$(dirname -- "${BASH_SOURCE[0]}")"
    module_root="$config_root/modules"

    [[ -d "$module_root" ]] || return 0

    # Recursively find all shell script files ordered according to path name.
    mapfile -d '' -t modules < <(find "$module_root" -type f -name '*.sh' -print0 | LC_ALL=C sort -z)
    for module in "${modules[@]}"; do
        _SourceConfigScript module "$module" || return 1
    done
}

# SourceLocal
#
# Loads the local configuration modules in deterministic path order.
# These contain structured local-only modules/files that intentionally
# declare the config drift for this machine from the aconfmgr defaults.
#
# This is used for intentionally private configs that we do not wish to expose
# from this public repository. This includes sensitive config values containing
# secrets, and values which shouldn't be disclosed for privacy reasons (e.g. a
# package installation declaration for a tool developed specifically by the
# company I'm employed at, and only useful for work in company. Tracking this
# declaration publicly would then leak potentially sensitive information.)
#
# It is additionally also used for temporary reconciliation until the config
# for the local machine matches the expected aconfmgr config. (Adding a new
# machine can require a fair bit of work if we're trying to synchronize it's
# local state with the currently declared common aconfmgr state. This allows us
# to have a private modules directory where we temporarily keep this drift.)
SourceLocal() {
    local config_root
    local module_root
    local module
    local -a modules

    config_root="$(dirname -- "${BASH_SOURCE[0]}")"
    module_root="$config_root/local"

    [[ -d "$module_root" ]] || return 0

    # Recursively find all shell script files ordered according to path name.
    mapfile -d '' -t modules < <(find "$module_root" -type f -name '*.sh' -print0 | LC_ALL=C sort -z)
    for module in "${modules[@]}"; do
        _SourceConfigScript module "$module" || return 1
    done
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
