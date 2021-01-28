#!/usr/bin/env zsh
# af-magic.zsh-theme
# Repo: https://github.com/andyfleming/oh-my-zsh
# Direct Link: https://github.com/andyfleming/oh-my-zsh/blob/master/themes/af-magic.zsh-theme

# settings
typeset +H return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"
typeset +H GRAY="$FG[237]"
typeset +H RED="$FG[196]"
typeset +H YELLOW="$FG[226]"
typeset +H BLUE="$FG[032]"
typeset +H PURPLE="$FG[105]"

# Primary Prompt
[ "$EUID" -eq 0 ] && PS1="$RED%n@%m " || PS1="$GRAY%n@%m " # user@machine (red/gray based on root)
PS1+="$BLUE%~" # cwd
PS1+='$(git_prompt_info)$(hg_prompt_info)' # git,hg
PS1+=" $PURPLE%(!.#.»)%{$reset_color%} " # final symbol

# Next line prompt
PS2="%{$RED%}\ %{$reset_color%}"

# Right side prompt
RPS1="${return_code}"
(( $+functions[virtualenv_prompt_info] )) && RPS1+="$(virtualenv_prompt_info)"

# git settings
ZSH_THEME_GIT_PROMPT_PREFIX="$FG[075]($FG[078]"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY="$my_orange*%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="$FG[075])%{$reset_color%}"

# hg settings
ZSH_THEME_HG_PROMPT_PREFIX="$FG[075]($FG[078]"
ZSH_THEME_HG_PROMPT_CLEAN=""
ZSH_THEME_HG_PROMPT_DIRTY="$my_orange*%{$reset_color%}"
ZSH_THEME_HG_PROMPT_SUFFIX="$FG[075])%{$reset_color%}"

# virtualenv settings
ZSH_THEME_VIRTUALENV_PREFIX=" $FG[075]["
ZSH_THEME_VIRTUALENV_SUFFIX="]%{$reset_color%}"
