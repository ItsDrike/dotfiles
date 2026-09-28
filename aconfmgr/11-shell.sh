################################################################################
# Shell-agnostic / shared
#
# This section contains extensions or shell related configuration that's not
# strictly tied any any single shell.
################################################################################

AddPackage starship # The cross-shell prompt for astronauts
AdPackage eza # A modern replacement for ls (community fork of exa)
AddPackae zoxide # A smarter cd command for your terminal

################################################################################
# Bash
#
# I don't really use the Bash shell a lot, but I do keep it installed and it is
# useful to be able to have at least some basic confguration for it in case I'd
# need it. Also, bash is pretty much a requirement to have installed on the
# system as scripts often rely on it. It's what /bin/sh points to.
################################################################################

# My global Bash configuration
# - Mostly matches the pacakge defaults
# - Loads environment.d env vars using the systemd loader
CopyFile /etc/bash.bashrc

################################################################################
# Zsh
#
# Zsh is my primary shell that I like using.
################################################################################

AddPackage zsh # Interactive shell; global startup policy is managed below

# My global ZSH configuration
# - Sets zdotdir globally to $HOME/.config/zsh, avoiding cluttering user home dirs
# - Loads environment.d env vars using the systemd loader
CopyFile /etc/zsh/zshenv

# ZSH extensions
AddPackage zsh-autosuggestions # Fish-like command suggestions for Zsh
AddPackage zsh-completions # Additional completion definitions for Zsh
AddPackage --foreign zsh-fast-syntax-highlighting # Optimized and extended zsh-syntax-highlighting
