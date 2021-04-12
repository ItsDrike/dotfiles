from datetime import datetime
from pathlib import Path

import colorama
import inquirer.shortcuts

from src.util.command import run_root_cmd

colorama.init(autoreset=True)


def _find_all_files(path: Path):
    for subpath in path.iterdir():
        if subpath.is_dir():
            yield from _find_all_files(subpath)
        else:
            yield subpath


def _walk_dotfiles():
    """
    Walk through every stored file in repositorie's dotfiles,
    start by going through `home` specific files, and continue
    with `root` dotfiles.
    """
    yield from _find_all_files(Path.cwd().joinpath("home"))
    yield from _find_all_files(Path.cwd().joinpath("root"))


def _dotfile_to_system(dotfile_path: Path) -> Path:
    """Convert dotfile path to corresponding path on real system"""
    base_dir = str(Path.cwd())

    if base_dir + "/home/" in str(dotfile_path):
        rel_path = str(dotfile_path).replace(base_dir + "/home/", "")
        return Path.home().joinpath(rel_path)
    elif base_dir + "/root/" in str(dotfile_path):
        rel_path = str(dotfile_path).replace(base_dir + "/root/", "")
        return Path("/", rel_path)
    else:
        raise ValueError(f"Given path is not a valid dotfile path ({dotfile_path})")


def make_backup() -> None:
    """
    Find all files which will be replaced and back them up.
    Files which doesn't exist in the real system destination
    will be ignored.
    """
    print(f"{colorama.Fore.LIGHTYELLOW_EX}Creating current dotfiles backup")
    time = str(datetime.now()).replace(" ", "--")
    backup_dir = Path.joinpath(Path.cwd(), "backup", time)
    backup_dir.mkdir(parents=True, exist_ok=True)

    for dotfile_path in _walk_dotfiles():
        real_path = _dotfile_to_system(dotfile_path)
        if not real_path.exists():
            continue

        rel_path = str(dotfile_path).replace(str(Path.cwd()) + "/", "")
        backup_path = backup_dir.joinpath(rel_path)

        # Ensure backup directory existence
        if real_path.is_dir():
            backup_path.mkdir(parents=True, exist_ok=True)
        else:
            backup_path.parent.mkdir(parents=True, exist_ok=True)

        print(f"{colorama.Style.DIM}Backing up{real_path}")
        run_root_cmd(f"cp '{real_path}' '{backup_path}'", enable_debug=False)

    print(f"{colorama.Fore.LIGHTYELLOW_EX}Backup complete")


def overwrite_dotfiles() -> None:
    for dotfile_path in _walk_dotfiles():
        real_path = _dotfile_to_system(dotfile_path)
        # Ensure existence of system directory
        if dotfile_path.is_dir():
            real_path.mkdir(parents=True, exist_ok=True)
        else:
            dotfile_path.parent.mkdir(parents=True, exist_ok=True)

        # If we encounter placeholder file, making folder is suffictient
        # don't proceed with copying it to avoid clutterring the original system
        # with empty placeholder files, these files are here only for git to
        # recognize that directory
        if str(dotfile_path).endswith("placeholder"):
            continue

        print(f"{colorama.Style.DIM}Overwriting {real_path}")
        run_root_cmd(f"cp '{dotfile_path}' '{real_path}'")


def install_dotfiles() -> None:
    if inquirer.shortcuts.confirm("Do you want to backup current dotfiles? (Recommended)", default=True):
        make_backup()

    print(f"{colorama.Fore.CYAN}Proceeding with dotfiles installation (this will overwrite your original files)")
    if inquirer.shortcuts.confirm(
        "Have you adjusted all dotfiles to your liking? "
        f"{colorama.Fore.RED}(proceeding without checking the dotfiles first isn't adviced){colorama.Fore.RESET}"
    ):
        overwrite_dotfiles()
        print(f"{colorama.Fore.LIGHTYELLOW_EX}Dotfile installation complete, make sure to adjust the dotfiles to your liking.")
    else:
        print(f"{colorama.Fore.RED}Aborted...")


if __name__ == "__main__":
    install_dotfiles()
