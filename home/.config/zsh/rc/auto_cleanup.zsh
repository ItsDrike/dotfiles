# This will simply remove some clutter files from the home directory

[ -f ~/.zsh-update ] && mv ~/.zsh-update $ZSH_CACHE/.zsh-update
[ -f ~/.sudo_as_admin_sucessful ] && rm ~/.sudo_as_admin_successful
[ -f ~/.bash_history ] && rm ~/.bash_history

# Make sure ZSH_CACHE dir exists, avoiding zsh to create it's cache files in $HOME
mkdir -p "$ZSH_CACHE"
