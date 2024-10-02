# This file loads custom ZSH plugins or runs shell configurations 
# exposed by various plugins. This often includes custom autocompletions, 
# but also whatever other functionalities that these may contain.

if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh --cmd z)"
fi

if command -v eww >/dev/null 2>&1; then
  eval "$(eww shell-completions --shell zsh)"
fi
