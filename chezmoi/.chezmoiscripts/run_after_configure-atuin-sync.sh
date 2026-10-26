#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# This script handles configuring Atuin sync server login.
# It needs two kinds of secrets in its configuration:
#
# - Encryption key with which shell history gets encrypted - both local and
#   remote (normally this is auto-initialized as something random, but since we
#   want remote syncing, this key needs to match across all of our machines)
# - Account login to the (self-hosted) sync server - username + password
#
# This script configures these secrets automatically, using `pass`. It expects
# that you have the relevant entries in your pass database already and will
# fail otherwise.
#
# The Atuin AI token is rendered into the private Atuin configuration by its
# Chezmoi template, not handled here.
###############################################################################

PASS_ENCRYPTION_KEY="homelab/atuin/encryption-key-b64"
PASS_SYNC_USERNAME="homelab/atuin/sync-username"
PASS_SYNC_PASSWORD="homelab/atuin/sync-password"

# Chezmoi applies environment.d files during this run, but they do not affect
# its own process environment. Keep pass and GnuPG on their XDG paths during a
# first-machine bootstrap, before the next login session has loaded them.
xdg_data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
export GNUPGHOME="${GNUPGHOME:-$xdg_data_home/gnupg}"
export PASSWORD_STORE_DIR="${PASSWORD_STORE_DIR:-$xdg_data_home/pass}"
unset xdg_data_home

###############################################################################
# Checks
###############################################################################

if ! command -v atuin >/dev/null 2>&1; then
    printf 'Failed to configure Atuin: it is not installed' >&2
    exit 1
fi

if ! command -v pass >/dev/null 2>&1; then
    printf 'Failed to configure Atuin: pass is not installed' >&2
    exit 1
fi

for pass_entry in "$PASS_ENCRYPTION_KEY" "$PASS_SYNC_USERNAME" "$PASS_SYNC_PASSWORD"; do
    if ! pass_value="$(pass show "$pass_entry" | head -n 1)"; then
        printf 'Failed to configure Atuin: pass entry %q is unavailable.\n' "$pass_entry" >&2
        exit 1
    fi

    if [ -z "$pass_value" ]; then
        printf 'Failed to configure Atuin: pass entry %q is empty.\n' "$pass_entry" >&2
        exit 1
    fi

    case "$pass_entry" in
        "$PASS_ENCRYPTION_KEY") encryption_key="$pass_value" ;;
        "$PASS_SYNC_USERNAME") sync_username="$pass_value" ;;
        "$PASS_SYNC_PASSWORD") sync_password="$pass_value" ;;
    esac
done

unset pass_entry pass_value

###############################################################################
# Logic
###############################################################################

# Check if the current atuin key matches the expected key from `pass`. If not,
# run rekey to re-encrypt the local history database with the new key.
#
# If no key was initialized yet, `atuin key` will fail with code 1, in this
# case initialize the key to our value directly.
if local_key="$(atuin key --base64 2>/dev/null)"; then
    if [ "$local_key" != "$encryption_key" ]; then
        atuin store rekey "$encryption_key"
    fi
else
    key_path="$(atuin info | awk -F ': ' '$1 == "key path" { print $2; exit }')"

    if [ -z "$key_path" ]; then
        printf 'Failed to configure Atuin: could not determine key path.\n' >&2
        exit 1
    fi

    if [ ! -e "$key_path" ]; then
        install -d -m 700 "$(dirname "$key_path")"
        printf '%s' "$encryption_key" > "$key_path"
        chmod 600 "$key_path"
    else
        printf "Failed to configure Atuin: existing key file cannot be read.\n" >&2
        exit 1
    fi

    unset key_path
fi

unset local_key

# Next check if atuin has a logged in sync account already, and if not, log in
# with configured credentials.
if ! atuin status >/dev/null 2>&1; then
    atuin login \
        --username "$sync_username" \
        --password "$sync_password" \
        --key "$encryption_key"
fi

unset sync_username sync_password encryption_key
