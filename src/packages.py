import yaml

from src.util.package import Package, PackageAlreadyInstalled, InvalidPackage
from src.util import log

with open("packages.yaml") as f:
    yaml_file = yaml.safe_load(f)

pacman_packages = yaml_file["pacman"]
aur_packages = yaml_file["aur"]
git_packages = yaml_file["git"]

packages = []
for package in git_packages:
    packages.append(Package(package, git=True))
for package in pacman_packages:
    packages.append(Package(package))
for package in aur_packages:
    packages.append(Package(package, aur=True))

for package in packages:
    try:
        log.action(f"Installing {package}")
        package.install()
    except PackageAlreadyInstalled:
        log.cancel(f"Package {package} is already installed.")
    except InvalidPackage as e:
        log.warning(e)
