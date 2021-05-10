# Dotfiles

These are my personal dotfiles. This also include an automated installer for certain packages (Arch Linux specific) and for putting the dotfiles in place.
Source code for this automated script is in `src` directory, and the dotfiles are located in `home` and `root` directories respectively.

You are highly adviced to first go through these dotfiles yourself and adjust them to your liking.

## Sample images

- Prompt (Fully adjustable, either manually [here](home/.config/sh/theme), or using other oh-my-zsh themes and removing the custom theme from `.zshrc`) ![image](https://user-images.githubusercontent.com/20902250/117699472-69ab5d80-b1b4-11eb-85a8-2b039bc1599a.png)
- Vim configuration (Fully adjustable, simply edit [`vimrc`](home/.config/vim/vimrc)) ![image](https://user-images.githubusercontent.com/20902250/106214028-3c6f0c80-61ce-11eb-96a2-3a46c77853e7.png)
- Automatic unknown command package handler ![image](https://user-images.githubusercontent.com/20902250/117700151-2998aa80-b1b5-11eb-8076-619be69eec55.png)

## What does it do

- Automated arch installation script
- Full fledged ZSH configuration without the need to rely on oh-my-zsh
  - oh-my-zsh configuration is also supported, but it is off by default, adjust [`.zshrc`](home/.zshrc) to enable it
  - Even though enabling it is an option, it is not a necessary thing to do, oh-my-zsh has a lot of code that is mostly irrelevant and unused, these dotfiles give you the ability to completely avoid it, if you desire to do so
- Custom [prompt](home/.config/sh/theme), both for oh-my-zsh configuration or for standalone usage
- Custom [VIM configuration](home/.config/vim/vimrc) (designed for nvim, but should work fine with regular vim too)
- Many handy [aliases](home/.config/sh/aliases) and [functions](home/.config/sh/functions) (likely too many, you should adjust that to your needs)
- [XDG configuration](home/.config/sh/environ) to avoid too much cluttering in home directory
- [Automatic handlers](home/.config/sh/handlers) which override default command not found behavior to show the package to which given command belongs (requires pkgfile on Arch Linux)
- Automated package installation for Arch Linux, which includes many handy packages. You should certainly take a look at which packages will be installed and adjust [`packages.yaml`](packages.yaml) before you run it.
- Extensive [vscode settings](home/.config/Code/User/settings.json), note that these are the settings which I like, you will probably want to adjust them to your personal needs, or perhaps even replace them
- [Opensnitch firewall rules](root/etc/opensnitchd/rules), which block most unauthorized traffic and only allow needed things. This also blocks spotify ads.
- Automatic logout for TTY sessions or for root logins after 10 minutes of inactivity
- NetworkManager configuration which assigns new mac for each network

## Requirements

`curl` and `tar`, or `git` to clone the repository itself.
Installation uses `python` and `pip` with some python packages in `requirements.txt` but these will get installed automatically by the `install.sh` script.

## Installation

Clone this repository anywhere you like
`$ git clone https://github.com/ItsDrike/dotfiles`

If you don't want to install git (running straight from newly installed os), you can use `curl`: <br>
`$ curl -LJO https://github.com/ItsDrike/dotfiles/tarball/master` <br>
And extract from `.tar.gz` archive:
`$ tar xvf [archive name]`

## Running the script

**Before you run, you should take a look at the files included and adjust them however you like.** <br>
Make sure you only run the script after you've adjusted everything to your liking, there are many things which aren't needed and might not be desired, make sure to really check every file this will add and remove/adjust those you don't want

- All config files which will be added are in [`home/`](home) and [`root/`](root) directory. Make sure to remove the undesired ones.
- All packages are located in [`packages.yaml`](packages.yaml), Make sure to remove all packages which you don't want to be installed.

When you are prepared, you can run the installer  (assuming you're in the clonned directory):
`$ chmod +x install.sh` (Make installation script executable)
`$ sh install.sh` (run the installation script, which will begin the instalaltion)
