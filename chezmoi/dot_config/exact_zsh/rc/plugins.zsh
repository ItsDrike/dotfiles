# This file loads custom ZSH plugins or runs shell configurations exposed by
# various tools.
#
# Note that for commands that install tool shell completions specifically,
# completion.zsh is the preferred location for running these.

if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [ -f /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]; then
  source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

  # The plugin defaults comments to black, which is unreadable in a dark
  # terminal. Keep them muted but legible.
  FAST_HIGHLIGHT_STYLES[comment]='fg=#737aa2'
fi

if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh --cmd j)"
fi

# Kitty normally redirects ZDOTDIR to it's own temporary .zshenv, which
# restores the initial ZDOTDIR and loads Kitty's integration. However, we
# override ZDOTDIR from /etc/zsh/zshenv, and that's sourced before kitty's
# temporary .zshenv is read, bypassing the automatic loader. For this reason,
# we load the integration manully instead.
if [[ -n $KITTY_INSTALLATION_DIR && -n $KITTY_SHELL_INTEGRATION ]]; then
  autoload -Uz -- "$KITTY_INSTALLATION_DIR/shell-integration/zsh/kitty-integration"
  kitty-integration
  unfunction kitty-integration
fi

if (( $+commands[atuin] )); then
  # The self-hosted AI adapter requires a bearer token. Atuin maps nested
  # settings from environment variables using double underscores, so this
  # avoids storing the token in config.toml or the chezmoi source tree.
  if (( $+commands[pass] )); then
    atuin_ai_token="$(pass show homelab/atuin/ai-token 2>/dev/null | head -n 1)"
    if [[ -n $atuin_ai_token ]]; then
      export ATUIN_AI__API_TOKEN="$atuin_ai_token"
    fi
    unset atuin_ai_token
  fi

  # Preserve the native Zsh up-arrow history traversal configured in keybinds.zsh.
  # Ctrl-r remains bound to Atuin's cross-session history search.
  eval "$(atuin init zsh --disable-up-arrow)"
fi
