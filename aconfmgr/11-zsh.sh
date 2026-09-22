AddPackage zsh # Interactive shell; global startup policy is managed below
AddPackage starship # The cross-shell prompt for astronauts
AddPackage zsh-autosuggestions # Fish-like command suggestions for Zsh
AddPackage zsh-completions # Additional completion definitions for Zsh
AddPackage --foreign zsh-fast-syntax-highlighting # Optimized and extended zsh-syntax-highlighting

# Keep per-user Zsh configuration under XDG config directories.
CopyFile /etc/zsh/zshenv
