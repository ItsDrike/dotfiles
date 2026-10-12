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
