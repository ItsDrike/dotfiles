# Configure Zsh's command-line editor and terminal key bindings.
#
# ZLE means "Zsh Line Editor". It is the part of Zsh responsible for editing
# the command currently being typed at the prompt, including cursor movement,
# history navigation, completion, deleting text, and custom interactive
# widgets.
#
# ZLE supports multiple keymaps. The two common editing styles are:
#
#  * emacs: conventional shell/readline-style bindings such as Ctrl-A, Ctrl-E,
#           Ctrl-W, etc.
#
#  * vi:    modal editing similar to vi/vim/neovim. `viins` is insert mode and
#           `vicmd` is command mode.
#
# Most of the bindings below describe physical terminal keys such as Home,
# Delete, arrows, and PageUp. They are installed in all common keymaps so that
# switching between Emacs and vi editing later does not require rewriting the
# rest of this file.
#
# Reference:
# - <http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html>
# - <http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Zle-Builtins>
# - <http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Standard-Widgets>

###############################################################################
# Configuration
###############################################################################

# Select the default ZLE editing style.
#
# Valid values:
#   emacs
#   vi
KEYBIND_MODE="emacs"

###############################################################################
# ZLE and terminal setup
###############################################################################

# Load Zsh's terminfo interface.
#
# Terminfo describes capabilities and key sequences for the terminal identified
# by $TERM. Using it is preferable to hard-coding escape sequences when a
# corresponding terminfo capability exists.
zmodload zsh/terminfo

case "$KEYBIND_MODE" in
  emacs)
    bindkey -e
   ;;
  vi)
    bindkey -v

     # Zsh waits briefly after receiving ESC because ESC may either mean
     # "leave vi insert mode" or be the beginning of a terminal escape
     # sequence. Reduce that delay so entering vi command mode feels
     # responsive.
     KEYTIMEOUT=1
     ;;
  *)
     print -ru2 -- "Unknown KEYBIND_MODE: $KEYBIND_MODE"
     bindkey -e
     ;;
esac

# Terminals represent special keys such as arrows and Home/End as escape
# sequences sent to the shell.
#
# Some terminals can use different escape sequences depending on whether they
# are in their normal keyboard mode or in "application" mode. The terminfo
# entries used by the bindings below are intended to match application mode.
#
# While Zsh's interactive line editor (ZLE), is active, tell the terminal to
# switch into application mode so the sequences it sends match the bindings we
# configure. When ZLE finishes, restore the terminal's normal mode so programs
# started from the shell can manage the terminal state themselves.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
  zle-line-init() {
    # Tell the terminal to enter application keyboard/keypad mode.
    echoti smkx
  }

  zle-line-finish() {
    # Restore the terminal's normal keyboard/keypad mode.
    echoti rmkx
  }

  zle -N zle-line-init
  zle -N zle-line-finish
fi


# Enter terminal application mode while ZLE is active. In this mode, special
# keys emit the sequences described by the corresponding terminfo capabilities.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
    zle-line-init() {
        echoti smkx
    }

    zle-line-finish() {
        echoti rmkx
    }

    zle -N zle-line-init
    zle -N zle-line-finish
fi

###############################################################################
# Helper ZLE widgets
###############################################################################

# Search history using the text already typed at the beginning of the line.
#
# For example, typing: "git" and pressing Up repeatedly walks backward through
# commands beginning with "git" instead of simply selecting the immediately
# preceding history entry.
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Edit the current command line using $VISUAL, then $EDITOR, and finally vi as
# Zsh's fallback.
autoload -Uz edit-command-line
zle -N edit-command-line

###############################################################################
# Terminal special keys
#
# Keys such as arrows, Home, End, Delete, PageUp, and Shift-Tab usually do not
# correspond to a single character byte. Instead, the terminal sends a
# multi-byte escape sequence when they are pressed.
#
# Whenever possible, use terminfo to discover the sequence expected for the
# current $TERM rather than hard-coding one.
###############################################################################

# Install a binding in each commonly used editing keymap.
#
# `emacs` is used by Emacs-style editing.
# `viins` is vi insert mode.
# `vicmd` is vi command mode.
#
# This keeps physical keys such as arrows, Home, and Delete working consistently
# regardless of which editing style is selected above.
bindkey-common() {
    local sequence="$1"
    local widget="$2"

    bindkey -M emacs "$sequence" "$widget"
    bindkey -M viins "$sequence" "$widget"
    bindkey -M vicmd "$sequence" "$widget"
}

# Up / Down: prefix-based history search.
#
# Bind both the widely used xterm-compatible sequences and the
# terminal-specific sequences advertised by terminfo. They are often identical,
# but supporting both makes this more tolerant of unusual terminal
# configurations.
bindkey-common '^[[A' up-line-or-beginning-search
bindkey-common '^[[B' down-line-or-beginning-search

[[ -n ${terminfo[kcuu1]} ]] &&
    bindkey-common "${terminfo[kcuu1]}" up-line-or-beginning-search

[[ -n ${terminfo[kcud1]} ]] &&
    bindkey-common "${terminfo[kcud1]}" down-line-or-beginning-search

# PageUp / PageDown: move through shell history normally.
#
# This is the usual history search in the sense that it doesn't do prefix
# matching, just walks the history entires in order.
[[ -n ${terminfo[kpp]} ]] &&
    bindkey-common "${terminfo[kpp]}" up-line-or-history

[[ -n ${terminfo[knp]} ]] &&
    bindkey-common "${terminfo[knp]}" down-line-or-history

# Home / End: move to the beginning or end of the current command line.
if [[ -n ${terminfo[khome]} ]]; then
    bindkey-common "${terminfo[khome]}" beginning-of-line
else
    bindkey-common '^[[H' beginning-of-line
fi

if [[ -n ${terminfo[kend]} ]]; then
    bindkey-common "${terminfo[kend]}" end-of-line
else
    bindkey-common '^[[F' end-of-line
fi

# Shift-Tab: cycle backwards through available completion candidates.
#
# (Tab is bound to cycle forward by default already)
[[ -n ${terminfo[kcbt]} ]] &&
    bindkey-common "${terminfo[kcbt]}" reverse-menu-complete

# Backspace (delete backward) / Delete (delete forward).
bindkey-common '^?' backward-delete-char

if [[ -n ${terminfo[kdch1]} ]]; then
    bindkey-common "${terminfo[kdch1]}" delete-char
else
    bindkey-common '^[[3~' delete-char
fi

###############################################################################
# Modified terminal special keys
#
# Combinations such as Ctrl-Right, Ctrl-Left, and Ctrl-Delete are also sent as
# multi-byte terminal escape sequences.
#
# Unlike the basic special keys above, terminfo generally does not provide
# portable capabilities for these modifier combinations, so we bind the common
# xterm-compatible sequences directly.
###############################################################################

# Ctrl-Delete: Delete the whole forward-word
bindkey-common '^[[3;5~' kill-word

# Ctrl+RightArrow: Move forward one word
bindkey-common '^[[1;5C' forward-word

# Ctrl+LeftArrow: Move backward one word
bindkey-common '^[[1;5D' backward-word

###############################################################################
# Direct ZLE shortcuts
#
# These bindings use ordinary character or control-byte sequences rather than
# terminal-specific special-key escape sequences.
#
# For example, Ctrl-R is normally sent as the single control byte 0x12, while
# Space is simply the literal space character. These can therefore be bound
# directly without consulting terminfo.
###############################################################################

# Ctrl-R: incremental backward history search.
#
# This searches anywhere in previous commands rather than only commands sharing
# the current prefix.
bindkey-common '^R' history-incremental-search-backward

# Space: perform history expansion before inserting the space.
#
# For example, `!!` may be expanded to the previous command when Space is
# pressed.
bindkey-common ' ' magic-space

# Ctrl-Space: accept the current suggestion from zsh-autosuggestions.
#
# The widget is provided by zsh-autosuggestions. The binding may be configured
# before the plugin is loaded, but the widget must exist by the time the key is
# actually used.
bindkey-common '^ ' autosuggest-accept

# Ctrl-X Ctrl-E: open the current command line in $VISUAL/$EDITOR.
bindkey-common '^X^E' edit-command-line

###############################################################################
# Cleanup
###############################################################################

unset KEYBIND_MODE
unfunction bindkey-common

