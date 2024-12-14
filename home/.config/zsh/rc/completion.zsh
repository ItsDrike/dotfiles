# Autocompletion behavior of ZSH

autoload -Uz compinit
zmodload -i zsh/complist                # load completion list

if [[ -n "$(print ${ZDOTDIR:-$HOME}/.zcompdump(Nmh+5))" ]]; then
  # Re-check for new completions, re-creating .zcompdump if necessary.
  # This check can be quite slow and it's rare that we actually have new completions to load.
  # For that reason, we only do this if the compdump file is older than 5 hours.
  compinit
else
  # This will omit the check for new completions,
  # only re-creating .zcompdump if it doesn't yet exist.
  compinit -C
fi

zstyle ':completion:*' menu select      # select completions with arrow keys
zstyle ':completion:*' group-name ''    # group results by category
zstyle ':completion:::::' completer _expand _complete _ignored _approximate # enable approximate matches for completion

# Autocompletion for various tools
if command -v uv >/dev/null 2>&1; then
  eval "$(uv generate-shell-completion zsh)"
fi
if command -v uvx >/dev/null 2>&1; then
  eval "$(uvx --generate-shell-completion zsh)"
fi
