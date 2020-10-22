from src.util import command


class Install:
    def is_installed(package: str) -> bool:
        """Check if the package is already installed in the system"""
        return_code = command.get_return_code(f"pacman -Qi {package}")
        return return_code != 1

    def upgrade_pacman() -> None:
        """Run full sync, refresh the package database and upgrade."""
        command.execute("pacman -Syu")

    def pacman_install(package: str) -> None:
        """Install given `package`"""
        command.execute(f"pacman -S {package}")

    def yay_install(package: str) -> None:
        """Install give package via `yay` (from AUR)"""
        command.execute(f"yay -S {package}")

    def git_install(url: str) -> None:
        """Clone a git repository with given `url`"""
        command.execute(f"git clone {url}")
