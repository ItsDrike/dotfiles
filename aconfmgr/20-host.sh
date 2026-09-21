# This file holds host specific configurations.
#
# That includes sourcing the particular specific configuration for the currently
# running host, but also performing any other operations that differ by the host,
# yet are similar enough for their logic to be able to be performed from a single
# place.
#
# The $HOSTNAME env var is used to select the active host configuration.
# Override it deliberately when evaluating another host's declaration.

config_root="$(dirname -- "${BASH_SOURCE[0]}")"

# Load host-specific configs
# Hard-Fail for any unrecognized machines.
case "$HOSTNAME" in
    orca)
        source "$config_root/hosts/orca.sh"
        ;;
    *)
        echo "No aconfmgr host configuration for this hostname." >&2
        exit 1
        ;;
esac

# Generically create/copy other host-specific files
CopyFileTo "/hosts/$HOSTNAME/etc/fstab" /etc/fstab
