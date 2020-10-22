import typing as t
import yaml

from src.util.package import Package, PackageAlreadyInstalled, InvalidPackage
from src.util.install import Install
from src.util.user import Print, Input


def obtain_packages() -> t.List[Package]:
    with open("packages.yaml") as f:
        yaml_file = yaml.safe_load(f)

    pacman_packages = yaml_file["pacman"]
    aur_packages = yaml_file["aur"]
    git_packages = yaml_file["git"]

    packages = []
    for package in pacman_packages:
        packages.append(Package(package))
    for package in git_packages:
        packages.append(Package(package, git=True))
    for package in aur_packages:
        packages.append(Package(package, aur=True))

    return packages


def install_packages() -> None:
    packages = obtain_packages()
    if Input.yes_no("Do you wish to perform system upgrade first? (Recommended)"):
        Install.upgrade_pacman()
    for package in packages:
        try:
            Print.action(f"Installing {package}")
            package.install()
        except PackageAlreadyInstalled:
            Print.cancel(f"Package {package} is already installed.")
        except InvalidPackage as e:
            Print.warning(e)


if __name__ == "__main__":
    install_packages()
