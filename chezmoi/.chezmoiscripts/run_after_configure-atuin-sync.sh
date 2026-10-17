#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# This script handles configuring Atuin secrets / login. Generally, Atuin needs
# three secrets in its configuration:
#
# - Encryption key with which shell history gets encrypted - both local and
#   remote (normally this is auto-initialized as something random, but since we
#   want remote syncing, this key needs to match across all of our machines)
# - Account login to the (self-hosted) sync server - username + password
# - A configured api token for the (self-hosted) Atuin AI Server
#
# This script configures these secrets automatically, using `pass`. It expects
# that you have the relevant entries in your pass database already and will
# fail otherwise.
#
# Note that the AI token is actually handled from the shell startup (from this
# pass entry), by exporting ATUIN_AI__API_TOKEN. This script only checks the
# existence of the relevant pass secret.
###############################################################################

PASS_ENCRYPTION_KEY="homelab/atuin/encryption-key-b64"
PASS_SYNC_USERNAME="homelab/atuin/sync-username"
PASS_SYNC_PASSWORD="homelab/atuin/sync-password"
PASS_AI_TOKEN="homelab/atuin/ai-token"

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

for pass_entry in "$PASS_ENCRYPTION_KEY" "$PASS_SYNC_USERNAME" "$PASS_SYNC_PASSWORD" "$PASS_AI_TOKEN"; do
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
        "$PASS_AI_TOKEN") ai_token="$pass_value" ;;
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

unset ai_token sync_username sync_password encryption_key
