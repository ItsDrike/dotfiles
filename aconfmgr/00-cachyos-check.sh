# CachyOS repositories are a prerequisite, not aconfmgr managed policy.
# Aconfmgr can't reliably bootstrap CachyOS.
if ! pacman -Qq cachyos-keyring >/dev/null 2>&1; then
    printf '%s\n' \
        'CachyOS repositories must be configured before applying this configuration.' \
        '' \
        'Bootstrap them with:' \
        '  curl -LO https://mirror.cachyos.org/cachyos-repo.tar.xz' \
        '  tar -xf cachyos-repo.tar.xz && cd cachyos-repo' \
        '  sudo ./cachyos-repo.sh' \
        '' \
        'See docs/04_CACHYOS.md in this repository for details.' >&2
    exit 1
fi
