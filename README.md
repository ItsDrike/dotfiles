# Dotfiles

These are my personal dotfiles. They're split into `home/` and `root/` folders where the home folder holds all files
that should be put directly into your `$HOME` directory, while all of the files in the root folder can be put directly
into `/`

You are highly advised to first go through these dotfiles yourself and adjust them to your liking.


## Sample images

- Custom prompt (defined [here](home/.config/shell/theme)).
  - Colorscheme showcase: ![image](https://user-images.githubusercontent.com/20902250/117699472-69ab5d80-b1b4-11eb-85a8-2b039bc1599a.png)
  - Command timing showcase: ![image](https://user-images.githubusercontent.com/20902250/129356038-f1373183-ee50-4cc9-a602-a1215b5d1e5f.png)
- Neovim configuration written in lua: ![Screenshot_2021-12-06_14-31-37](https://user-images.githubusercontent.com/20902250/144854879-f35de259-cea1-4415-9a3b-b093fe008836.png)
- Automatic unknown command package handler: ![image](https://user-images.githubusercontent.com/20902250/129359888-629a4f28-64bd-4c90-8e87-de75a9b8997d.png)
- `lf` file manager previews with ueberzug: ![image](https://user-images.githubusercontent.com/20902250/129359042-b0594788-bc14-4294-bba2-8cba8e30cd94.png)

## Features

- Full fledged ZSH configuration without the need to rely on oh-my-zsh
  - oh-my-zsh configuration is also supported, but it is off by default, adjust [`.zshrc`](home/.config/zsh/.zshrc) to
    enable it
  - Even though enabling it is an option, it is not a necessary thing to do, oh-my-zsh has a lot of code that is mostly
    irrelevant and unused, these dotfiles give you the ability to completely avoid it, if you desire to do so
- Custom [prompt](home/.config/shell/theme), both for oh-my-zsh configuration or for standalone usage
- Custom [NVIM configuration](home/.config/nvim)
  - When you open nvim for the first time, it will automatically try to install Packer plugin manager
  - It is compatible with TTY usage, in which case the color support is downgraded and use of special fonts is
    disabled.
  - The configuration is split into multiple smaller files to keep everything clearn and avoid clutter in the main
    configuration file (`init.lua`). It also allows for us to quickly disable certain parts of the config.
  - The whole configuration is written in lua rather than vimscript. This allows us to do some nicer things, however
    it also means that this config will NOT work for regular vim, it's only meant to be used for neovim.
- Many handy [aliases](home/.config/shell/aliases) and [functions](home/.config/shell/functions) (likely too many, you
  should adjust that to your needs)
- [Many pre-defined environmental variables](home/.config/shell/environ), these include
  - XDG paths configuration to avoid too much cluttering in home directory
  - Colorful man pages using LESS_TERMCAP, or if `bat` is installed, using it as MANPAGER
- [Automatic handlers](home/.config/shell/handlers) which override default command not found behavior to show the
  package to which given command belongs (requires pkgfile on Arch Linux)
- List of useful packages that I often install on most of my systems. (These are the package names for arch linux, but
  you should be able to find these for any distro, perhaps with a bit different name) located in
  [`packages.yaml`](packages.yaml)
- [Opensnitch firewall rules](root/etc/opensnitchd/rules), which block most unauthorized traffic and only allow needed
  things. This also blocks spotify ads.
- Automatic logout for TTY sessions or for root logins after 10 minutes of inactivity
- NetworkManager configuration which assigns new mac for each network
- `lf` file manager configuration with support for ueberzug image previews within the terminal
- Tons of handy scripts for automating common tasks
  - [`incremental-backup`](root/usr/local/bin/incremental-backup): Easy way to utilize rsync for all backups, without
    the need for external software
  - [`auto-chroot`](root/usr/local/bin/auto-chroot): Quick way to chroot into any other linux system, without typing
    the very repetitive mount and umount commands
  - [`tamper-check`](root/usr/local/bin/tamper-check): Script that uses checksums to verify that given files weren't
    adjusted in any way.
  - [`brightness`](home/.local/bin/scripts/brightness): Script to quickly change screen brightness, you may need to
    adjust the BRIGHTNESS_FILE, this can be different from machine to machine
  - [`setbg`](home/.local/bin/scripts/setbg): Quick way to set desktop background to specific image, or random image,
    or previously used image
  - Many smaller dmenu scripts to make life easier



## Installation
Clone this repository anywhere you like
`$ git clone https://github.com/ItsDrike/dotfiles`

If you don't want to install git (running straight from newly installed OS), you can use `curl`: <br>
`$ curl -LJO https://github.com/ItsDrike/dotfiles/tarball/master` <br>
And extract from `.tar.gz` archive:
`$ tar xvf [archive name]`

## Attribution

The open-source community has an incredible amount of resources that people have offered to others free of charge and
we all depend on many of these sources. This project is no different and there were many open-source projects that were
utilized in some parts of this project. For that reason, I'd like to thank all of these projects and their
contributors for keeping their content open and available to everyone. This is the list of projects that helped me
build this repository to the stage it's in now. Many of the aliases, config files and other resources aren't my
original creations, but rather just small improvements and adjustments to get everything set in the way I like. Below
is the list of all projects which helped the existence of this repository:
- [Lukesmith's dotfiles/voidrice](https://github.com/LukeSmithxyz/voidrice)
- [BrodieRobertson's dotfiles](https://github.com/BrodieRobertson/dotfiles)
- [BrodieRobertson's scripts](https://github.com/BrodieRobertson/scripts)
- [Derek Taylor's dotfiles](https://gitlab.com/dwt1/dotfiles)

