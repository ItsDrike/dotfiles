###############################################################################
# Configure ZSH's programmable completion system.
#
# ZSH ships its completion logic as autoloadable functions stored in $fpath
# dirs, rather than loading all of them into every shell by default. compinit
# scans $fpath, discovers these completion functions and registers which
# commands they handle, leaving their implementations to be autoloaded only
# when they are actually needed (invoked).
#
# compinit stores the resulting completion setup in a compdump file so later
# shells can reuse it instead of rebuilding the completion state from scratch.
#
# Additional 3rd party completions can be included by installing the
# zsh-completions package. It places it's own completion definitions into
# $fpath, so compinit will pick them up automatically.
###############################################################################

###############################################################################
# Completion Behavior
###############################################################################

# Automatically list candidates when completion is ambiguous.
setopt AUTO_LIST

# Insert the first completion immediately when completion is ambiguous, then
# cycle through the available matches on subsequent completion attempts.
#
# This takes precedence over AUTO_MENU, so AUTO_MENU does not need to be set.
setopt MENU_COMPLETE

# When completing a parameter whose value refers to a directory, append `/`
# rather than a space.
setopt AUTO_PARAM_SLASH

# Move the cursor to the end of the completed word after completion inserts a
# full match.
setopt ALWAYS_TO_END

###############################################################################
# Completion Initialization
###############################################################################

autoload -Uz compinit

# Also load a built-in ZSH module with additional list/menu functionality when
# picking completions. We later configure the specific style with zstyle.
zmodload zsh/complist

# Enable interactive menu selection, allowing completion candidates to be
# selected using the arrow keys. This behavior is provided by zsh/complist.
zstyle ':completion:*' menu select

# Group completion candidates by their completion category.
zstyle ':completion:*' group-name ''

# Try increasingly permissive completion strategies if an exact completion
# cannot be found, including expansion, ignored matches, and approximate
# matching.
zstyle ':completion:::::' completer _expand _complete _ignored _approximate

# Override the location of the zcompdump cache, putting it into XDG_CACHE_HOME
# rather than ZDOTDIR, as it is generated state and not part of the actual ZSH
# configuration.
typeset -g ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
mkdir -p "${ZSH_COMPDUMP:h}"

# Generate the completion logic and zcompdump
compinit -d "$ZSH_COMPDUMP"

###############################################################################
# Dynamically generated completions
#
# Some tools generate their Zsh completion definitions at runtime rather than
# installing `_command` completion functions into $fpath.
#
# These generally need to run after `compinit`, because the generated code
# usually calls `compdef` directly to register its completions.
###############################################################################

if (( $+commands[uv] )); then
    eval "$(uv generate-shell-completion zsh)"
fi

if (( $+commands[uvx] )); then
    eval "$(uvx --generate-shell-completion zsh)"
fi
