#save_aliases=$(alias -L)
# History in cache directory
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

# Export oh-my-zsh location as $ZSH
export ZSH="$HOME/.config/oh-my-zsh"

# Set theme
#ZSH_THEME="agnoster"
#ZSH_THEME="bira"
#ZSH_THEME="gnzh"
#ZSH_THEME="rkj-repos"i
ZSH_THEME="af-magic"

# How often should zsh be updated
export UPDATE_ZSH_DAYS=5

# Enable command auto-correction
ENABLE_CORRECTION="false"

# Run oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Load plugins
plugins=(
	git
	python
	pylint
	pyenv
	autopep8
	zsh-autosuggestions
)

if [ -f "$HOME/.config/sh/zsh/.zsh_config" ]; then
	source "$HOME/.config/sh/zsh/.zsh_config"
fi

#neofetch --cpu_temp C --gtk2 off --gtk3 off --color_blocks on --pixterm
