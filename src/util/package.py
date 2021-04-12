import os
import typing as t
from pathlib import Path

import colorama
import inquirer.shortcuts

from src.util.command import run_cmd, run_root_cmd

colorama.init(autoreset=True)


class InvalidPackage(Exception):
    pass


class PackageAlreadyInstalled(Exception):
    pass


def is_installed(pkg: str) -> bool:
    """Check if the package is already installed in the system"""
    return run_cmd(f"pacman -Qi {pkg}", capture_out=True).returncode != 1


def pacman_install(package: str) -> None:
    """Install given `package`"""
    run_root_cmd(f"pacman -S {package}")


def yay_install(package: str) -> None:
    """Install give package via `yay` (from AUR)"""
    run_cmd(f"yay -S {package}")


def git_install(url: str) -> None:
    """Clone a git repository with given `url`"""
    dir_name = Path(url.split("/")[-1].replace(".git", ""))
    if dir_name.exists():
        print(f"{colorama.Style.DIM}Git repository {dir_name} already exists")

    ret_code = run_cmd(f"git clone {url}").returncode
    if ret_code == 128:
        print(f"{colorama.Fore.RED}Unable to install git repository {url}")
        return

    if not Path(dir_name, "PKGBUILD").exists:
        print(f"{colorama.Fore.YELLOW}Git repository {dir_name} doesn't contain PKGBUILD, only downloaded.")
        return

    if inquirer.shortcuts.confirm("Do you wish to run makepkg on the downloaded git repository?"):
        cwd = os.getcwd()
        os.chdir(dir_name)
        run_cmd("makepkg -si")
        os.chdir(cwd)
        run_cmd(f"rm -rf {dir_name}")
    else:
        os.makedirs("download")
        run_cmd(f"mv {dir_name} download/")
        print(f"{colorama.Style.DIM}Your git repository was cloned into `download/{dir_name}`")


class Package:
    def __init__(self, name: str, aur: bool = False, git: bool = False):
        self.name = name
        self.aur = aur
        self.git = git

        if self.git:
            self._resolve_git_package()

    def _resolve_git_package(self) -> None:
        """Figure out `git_url` variable from `name`."""
        if "/" not in self.name:
            raise InvalidPackage("You need to specify both author and repository name for git packages (f.e. `ItsDrike/dotfiles`)")

        if "http://" in self.name or "https://" in self.name:
            self.git_url = self.name
        else:
            self.git_url = f"https://github.com/{self.name}"

    def install(self) -> None:
        if not self.git and is_installed(self.name):
            raise PackageAlreadyInstalled(f"Package {self} is already installed")

        if self.aur:
            if not is_installed("yay"):
                raise InvalidPackage(f"Package {self} can't be installed (missing `yay` - AUR installation software), alternatively, you can use git")
            yay_install(self.name)
        elif self.git:
            git_install(self.git_url)
        else:
            pacman_install(self.name)

    def __repr__(self) -> str:
        if self.git:
            if self.name == self.git_url:
                return f"<Git package: {self.name}>"
            return f"<Git package: {self.name} ({self.git_url})>"
        elif self.aur:
            return f"<Aur package: {self.name}>"
        return f"<Package: {self.name}>"

    @classmethod
    def safe_load(cls, packages: t.List[str], aur: bool = False, git: bool = False) -> t.List["Package"]:
        loaded_packages = []
        for package in packages:
            try:
                loaded_packages.append(cls(package, aur=aur, git=git))
            except InvalidPackage as e:
                print(f"{colorama.Fore.RED}{str(e)}")

        return loaded_packages
