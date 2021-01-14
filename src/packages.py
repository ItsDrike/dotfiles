import typing as t
import yaml

from src.util.package import Package, PackageAlreadyInstalled, InvalidPackage
from src.util import install
from src.util.user import Print, Input


def obtain_packages() -> t.List[Package]:
    with open("packages.yaml") as f:
        yaml_file = yaml.safe_load(f)

    pacman_packages = yaml_file["pacman"]
    aur_packages = yaml_file["aur"]
    git_packages = yaml_file["git"]

    packages = []
    packages += Package.safe_load(pacman_packages)
    packages += Package.safe_load(aur_packages, aur=True)
    packages += Package.safe_load(git_packages, git=True)

    return packages


def install_packages() -> None:
    packages = obtain_packages()
    if Input.yes_no("Do you wish to perform system upgrade first? (Recommended)"):
        install.upgrade_pacman()
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
