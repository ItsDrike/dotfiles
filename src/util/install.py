import shutil
import os

from src.util import command
from src.util.user import Print, Input


class Install:
    def is_installed(package: str) -> bool:
        """Check if the package is already installed in the system"""
        return_code = command.get_return_code(f"pacman -Qi {package}")
        return return_code != 1

    def upgrade_pacman() -> None:
        """Run full sync, refresh the package database and upgrade."""
        command.execute("sudo pacman -Syu")

    def pacman_install(package: str) -> None:
        """Install given `package`"""
        command.execute(f"sudo pacman -S {package}")

    def yay_install(package: str) -> None:
        """Install give package via `yay` (from AUR)"""
        command.execute(f"yay -S {package}")

    def git_install(url: str) -> None:
        """Clone a git repository with given `url`"""
        dir_name = url.split("/")[-1].replace(".git", "")
        if os.path.exists(dir_name):
            Print.cancel(f"Git repository {dir_name} already exists")

        ret_code = command.get_return_code(f"git clone {url}")
        if ret_code == 128:
            Print.warning(f"Unable to install git repository {url}")
            return

        if not os.path.exists(f"{dir_name}/PKGBUILD"):
            Print.comment(f"Git repository {dir_name} doesn't contain PKGBUILD, only downloaded.")
            return

        if Input.yes_no("Do you wish to run makepkg on the downloaded git repository?"):
            cwd = os.getcwd()
            os.chdir(dir_name)
            command.execute("makepkg -si")
            os.chdir(cwd)
            shutil.rmtree(dir_name)
        else:
            os.makedirs("download")
            command.execute(f"mv {dir_name} download/")
            Print.action(f"Your git repository was cloned into `download/{dir_name}`")
