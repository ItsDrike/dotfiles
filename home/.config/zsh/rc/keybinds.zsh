# shellcheck disable=SC2030,SC2031,SC2015
# Set default keybindings (mostly from oh-my-zsh)

# Make sure that the terminal is in application mode when zle is active, since
# only then values from $terminfo are valid
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init() {
    echoti smkx
  }
  function zle-line-finish() {
    echoti rmkx
  }
  zle -N zle-line-init
  zle -N zle-line-finish
fi

# Use emacs keybindings
bindkey -e

# Start typing + [Up-Arrow] - fuzzy find history forward
if [ -n "${terminfo[kcuu1]}" ]; then
  autoload -U up-line-or-beginning-search
  zle -N up-line-or-beginning-search
  bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
fi
# Start typing + [Down-Arrow] - fuzzy find history backward
if [ -n "${terminfo[kcud1]}" ]; then
  autoload -U down-line-or-beginning-search
  zle -N down-line-or-beginning-search
  bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
fi

# [Home] - Go to beginning of line
[ -n "${terminfo[khome]}" ] && bindkey "${terminfo[khome]}" beginning-of-line || bindkey "^[[H" beginning-of-line
# [End] - Go to end of line
[ -n "${terminfo[kend]}" ] && bindkey "${terminfo[kend]}"  end-of-line || bindkey "^[[F"  end-of-line

# [Shift-Tab] - move through the completion menu backwards
[ -n "${terminfo[kcbt]}" ] && bindkey "${terminfo[kcbt]}" reverse-menu-complete

# [Backspace] - delete backward
bindkey '^?' backward-delete-char
# [Delete] - delete forward
[ -n "${terminfo[kdch1]}" ] && bindkey "${terminfo[kdch1]}" delete-char || bindkey "^[[3~" delete-char
# [Ctrl-Delete] - delete whole forward-word
bindkey '^[[3;5~' kill-word

# [Ctrl-RightArrow] - move forward one word
bindkey '^[[1;5C' forward-word
# [Ctrl-LeftArrow] - move backward one word
bindkey '^[[1;5D' backward-word

# [Ctrl-r] - Search backward incrementally for a specified string. The string may begin with ^ to anchor the search to the beginning of the line.
bindkey '^r' history-incremental-search-backward
# [PageUp] - Up a line of history
[ -n "${terminfo[kpp]}" ] && bindkey "${terminfo[kpp]}" up-line-or-history
# [PageDown] - Down a line of history
[ -n "${terminfo[knp]}" ] && bindkey "${terminfo[knp]}" down-line-or-history

# [Space] - do history expansion on space
bindkey ' ' magic-space

# [ctrl+space] Accept suggestion from zsh-autosuggestions plugin
bindkey '^ ' autosuggest-accept

