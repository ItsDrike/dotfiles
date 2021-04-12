import typing as t

import colorama
import inquirer.shortcuts
import yaml

from src.util.command import run_root_cmd
from src.util.package import InvalidPackage, Package, PackageAlreadyInstalled

colorama.init(autoreset=True)


def obtain_packages() -> t.List[Package]:
    with open("packages.yaml") as f:
        yaml_file = yaml.safe_load(f)

    pacman_packages = yaml_file["pacman"]
    aur_packages = yaml_file["aur"]
    git_packages = yaml_file["git"]

    packages = []
    packages += Package.safe_load(pacman_packages)
    packages += Package.safe_load(git_packages, git=True)
    packages += Package.safe_load(aur_packages, aur=True)

    return packages


def install_packages() -> None:
    packages = obtain_packages()
    if inquirer.shortcuts.confirm("Do you wish to perform system upgrade first? (Recommended)", default=True):
        run_root_cmd("pacman -Syu")

    for package in packages:
        try:
            print(f"{colorama.Fore.CYAN}Installing {package}")
            package.install()
        except PackageAlreadyInstalled:
            print(f"{colorama.Style.DIM}Package {package} is already installed, skipping")
        except InvalidPackage as e:
            print(f"{colorama.Fore.RED}{str(e)}")


if __name__ == "__main__":
    install_packages()
