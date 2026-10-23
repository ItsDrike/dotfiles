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

### Encryption

This repository contains some encrypted files, which I consider private and did
not want to include in plaintext directly, either because they directly contain
secrets, or because they contain sensitive information which I did not wish to
leak.

I use `gpg` with my personal GPG key to handle encryption. This means that in
addition to the above edit to `chezmoi.toml`, to add support for encryption,
it is also necessary to include:

```ini
encryption = "gpg"

[gpg]
recipient = "136F5E08AFF7F6DD3E9227A0FA2745890B7048C0"
args = ["--quiet"]
```

If you wish to directly apply my configuration, you would need to possess this
GPG key to successfully decrypt the encrypted files which are a part of this
chezmoi config. You can however skip all encrypted entries and apply the
configuration without them, which will, for the most part, work without issues:

```bash
chezmoi apply --exclude encrypted
```

Although I would recommend inspecting which of my files were encrypted (all
files starting with `encrypted_`, you can search for them with `fd encrypted_`)
and creating your own versions.

## Usage

- `chezmoi add ~/.config/xyz` to add `~/.config/xyz` as tracked configuration
- `chezmoi diff` to see all changes between the dotfiles state and installed state
- `chezmoi apply -v` to apply the configuration
- `chezmoi chattr +template ~/.config/xyz` to turn config for `xyz` into a Go template
- `chezmoi edit ~/.config/xyz` to edit the tracked config file

[chezmoi]: https://www.chezmoi.io/
