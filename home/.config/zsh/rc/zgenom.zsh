# Load zgenom (plugin manager for ZSH)
source "${ZDOTDIR}/.zgenom/zgenom.zsh"

# Check for zgenom updates
# This does not increase startup time
zgenom autoupdate

# If the init script doesn't exist yet
if ! zgenom saved; then
    zgenom load akash329d/zsh-alias-finder
    zgenom load clarketm/zsh-completions
    zgenom load zsh-users/zsh-autosuggestions
    zgenom load zdharma-continuum/fast-syntax-highlighting

    # Generate the init script from plugins above
    zgenom save
fi

