# Chezmoi

[Chezmoi][chezmoi] is a dotfile manager that supports templating configs over
different conditions (such as by hostnames), and provides various utils that
help automate the process of managing dotfiles easily.

> [!NOTE]
> The configs in here are primarily designed for myself. I keep them
> open-source and available to anyone as a reference of what's possible or
> something to link people to when they ask me how I configure something. The
> chezmoi file structure is easy to understand and follow, so if you're just
> exploring the repo for interesting configs, or specifically searching for how
> I configure tool X, you're in the right place.
>
> If you're looking to apply this config as a whole as-is, you will find that
> to be a bit more difficult, as this is something it was not designed for for
> anyone other than me. This is because the config holds some encrypted files,
> and also relies on certain tools being installed and containing some local
> state which is private by nature and I do not make the insturctions for
> reproducing it all that obvious sometimes. I sync these untracked private
> data manually across my devices and they are what allows this config to be
> applied. You can work around this and reproduce most of the configs after
> setting some things up and replacing the encrypted files if you really wish
> to. The sections below document some of it, but do not rely on them always
> being fully up-to-date with the actual configs, or overly detailed on how to
> do this exactly.

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

## Secrets

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

### Other secrets

Additionally, some of the templates / scripts that chezmoi runs invoke `pass`
and expect it to contain certain secret values. It is therefore required that
you reproduce equivalent values in your own `pass` database. Without these,
chezmoi will fail to build the templates / run the scripts. You will generally
see where the failure occurs and therefor which command failed and what you
need to add.

[chezmoi]: https://www.chezmoi.io/
