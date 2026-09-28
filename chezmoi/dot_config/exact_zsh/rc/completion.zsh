# Configure ZSH's programmable completion system.
#
# Zsh provides completion through a combination of:
#
# - shell options that control general completion behavior,
# - completion functions discovered through directories in $fpath,
# - `compinit`, which initializes and registers those completion functions,
# - `zstyle` rules that configure matching, grouping, menus, and caching,
# - optional modules such as zsh/complist for interactive selection,
# - completions generated dynamically by external tools.
#
# Zsh ships most completion implementations as autoloadable functions stored in
# $fpath rather than loading all of them into every shell immediately.
# `compinit` scans those directories, discovers the completion functions, and
# registers which commands they handle. Their implementations remain autoloaded
# until actually needed (when invoked).
#
# `compinit` also stores generated completion metadata in a compdump file so
# later shells can reuse the initialized completion state instead of rebuilding
# everything from scratch.
#
# Third-party packages such as `zsh-completions` can extend completion simply
# by installing additional completion functions into $fpath before `compinit`
# runs. Alternatively, they can call `compdef` directly.

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

# Make `compinit` available once called
autoload -Uz compinit

# Load Zsh's built-in completion-list module. This provides interactive menu
# selection and additional control over displayed completion lists.
#
# We later configure the specific style with zstyle.
zmodload zsh/complist

# Store the compdump under XDG_CACHE_HOME rather than ZDOTDIR, since it is
# generated state rather than part of the actual Zsh configuration.
typeset -g ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
mkdir -p "${ZSH_COMPDUMP:h}"

# Initialize the completion system, register completion functions discovered in
# $fpath, and generate or reuse the compdump cache above.
compinit -d "$ZSH_COMPDUMP"

###############################################################################
# Completion menu and presentation
###############################################################################

# Enable interactive menu selection, allowing completion candidates to be
# selected using the arrow keys. (This behavior is provided by zsh/complist.)
zstyle ':completion:*' menu select

# Group completion candidates by their completion category.
#
# An empty group name tells Zsh to use the category name chosen by the
# completion function itself.
zstyle ':completion:*' group-name ''

# Use the terminal's normal completion-list color handling.
zstyle ':completion:*' list-colors ''

###############################################################################
# Completion matching
###############################################################################

# Include `.` and `..` as directory completion candidates.
#zstyle ':completion:*' special-dirs true

# Try increasingly permissive completion functions if an exact completion
# cannot be found.
#
#   _expand       perform expansions such as parameters and substitutions
#   _complete     perform normal completion
#   _ignored      include matches normally excluded by ignored-pattern rules
#   _approximate  allow approximate matching as a final fallback
zstyle ':completion:::::' completer _expand _complete _ignored _approximate


# Try completion matching strategies from strictest to increasibly more
# permissive partial-word and substring-style matches.
#
# matcher-list entries are tried in order until one produces usable matches:
#
# - normal exact case-sensitive matching
# - case-insensitive matching
# - allow additional chars on the right side of the matched text
# - allow additional chars on both sides of the matched text
zstyle ':completion:*' matcher-list \
   '' \
   'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
   'r:|=*' \
   'l:|=* r:|=*'

###############################################################################
# Completion cache
###############################################################################

# Some completion functions can cache expensive generated candidate data.
# Keep that cache under XDG_CACHE_HOME alongside the compdump.
typeset -g ZSH_COMPCACHE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completion"
mkdir -p "$ZSH_COMPCACHE"

zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$ZSH_COMPCACHE"

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

if (( $+commands[chezmoi] )); then
    eval "$(chezmoi completion zsh)"
fi
