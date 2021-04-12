import sys

import colorama
import inquirer.shortcuts

from src.arch_install import install_arch
from src.dotfiles_install import install_dotfiles
from src.package_install import install_packages
from src.util.command import run_cmd

colorama.init(autoreset=True)


if inquirer.shortcuts.confirm("Do you wish to perform Arch install? (Directly from live ISO)"):
    run_cmd("clear")
    print(f"{colorama.Fore.BLUE}Running Arch Installation")
    root_mountpoint = install_arch()
    print(f"{colorama.Fore.GREEN}Arch installation complete")
    print(f"{colorama.Fore.CYAN}To install packages and dotfiles, move this whole directory to the new installation and run it from there.")
    sys.exit()

if inquirer.shortcuts.confirm("Do you wish to perform package installation (from packages.yaml)"):
    install_packages()

if inquirer.shortcuts.confirm("Do you wish to install dotfiles? (from home and root folders)"):
    install_dotfiles()
