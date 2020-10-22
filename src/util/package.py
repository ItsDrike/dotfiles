from src.util.install import Install


class InvalidPackage(Exception):
    pass


class PackageAlreadyInstalled(Exception):
    pass


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
        if not self.git and Install.is_installed(self.name):
            raise PackageAlreadyInstalled(f"Package {self} is already installed")

        if self.aur:
            if not Install.is_installed("yay"):
                raise InvalidPackage(f"Package {self} can't be installed (missing `yay` - AUR installation software)")
            Install.yay_install(self.name)
        elif self.git:
            Install.git_install(self.git_url)
        else:
            Install.pacman_install(self.name)

    def __repr__(self) -> str:
        if self.git:
            return f"<Git package: {self.name} ({self.git_url})>"
        elif self.aur:
            return f"<Aur package: {self.name}>"
        return f"<Package: {self.name}>"
