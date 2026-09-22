# Chezmoi

[Chezmoi][chezmoi] is a dotfile manager that supports templating configs over
different conditions (such as by hostnames), and provides various utils that
help automate the process of managing dotfiles easily.

## Setup

To install chezmoi, run: `pacman -S chezmoi`.

Then create a `~/.config/chezmoi/chezmoi.toml` to tell chezmoi where the dotfiles repo is (put your own path, where you cloned this repo):

```ini
sourceDir = "/home/itsdrike/dots"
```

## Usage

- `chezmoi add ~/.config/xyz` to add `~/.config/xyz` as tracked configuration
- `chezmoi diff` to see all changes between the dotfiles state and installed state
- `chezmoi apply -v` to apply the configuration
- `chezmoi chattr +template ~/.config/xyz` to turn config for `xyz` into a Go template
- `chezmoi edit ~/.config/xyz` to edit the tracked config file

[chezmoi]: https://www.chezmoi.io/
