# Load shared default configuration modules in deterministic path order. Profiles
# remain explicitly selected by host configurations; this loader handles only
# modules that apply to every configured host.
_SourceModules() {
    local config_root
    local module_root
    local module

    config_root="$(dirname -- "${BASH_SOURCE[0]}")"
    module_root="$config_root/modules"

    # Keep this entry point inert until the module migration begins.
    [[ -d "$module_root" ]] || return 0

    while IFS= read -r -d '' module; do
	echo ":::: Sourcing $module" >&2
        source "$module" || return 1
    done < <(find "$module_root" -type f -name '*.sh' -print0 | LC_ALL=C sort -z)
}

_SourceModules
unset -f _SourceModules
