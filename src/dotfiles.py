import os
import shutil
import time
from datetime import datetime
from contextlib import suppress

from src.util import command
from src.util.user import Print, Input


def _backup_file(backup_dir: str, subdir: str, file: str) -> None:
    """
    Backup given `file` in given `subdir` from system
    """
    system_subdir = subdir.replace("home", f"{os.environ['HOME']}/").replace("root", "/")
    system_path = os.path.join(system_subdir, file)

    # Only backup files which exists in origin destination (real system destination)
    if os.path.exists(system_path):
        backup_subdir = os.path.join(backup_dir, subdir)
        backup_path = os.path.join(backup_subdir, file)
        # Ensure directory existence in the new backup directory
        with suppress(FileExistsError):
            os.makedirs(backup_subdir)

        if file != "placeholder":
            Print.comment(f"Backing up {system_path}")
            shutil.copyfile(system_path, backup_path)


def make_backup() -> None:
    """
    Find all files which will be replaced and back them up.
    Files which doesn't exist in the real system destination
    will be ignored.
    """
    Print.action("Creating current dotfiles backup")
    time = str(datetime.now()).replace(" ", "--")
    backup_dir = os.path.join(os.getcwd(), "backup", time)
    os.makedirs(backup_dir)

    # backup files in `home` directory
    for subdir, _, files in os.walk("home"):
        for file in files:
            _backup_file(backup_dir, subdir, file)

    # backup files in `root` directory
    for subdir, _, files in os.walk("root"):
        for file in files:
            _backup_file(backup_dir, subdir, file)

    Print.action("Backup complete")


def _overwrite_dotfile(subdir: str, dotfile: str) -> None:
    """Overwrite given `dotfile` in `subdir` from system with the local one"""
    local_path = os.path.join(subdir, dotfile)
    system_subdir = subdir.replace("home", f"{os.environ['HOME']}").replace("root", "/")
    system_path = os.path.join(system_subdir, dotfile)

    # Ensure existence of system directory
    with suppress(FileExistsError):
        os.makedirs(system_subdir)

    if dotfile != "placeholder":
        Print.comment(f"Overwriting {system_path}")
        # Use sudo to avoid PermissionError
        command.execute(f"sudo cp {local_path} {system_path}")


def overwrite_dotfiles() -> None:
    # overwrite system dotfiles with local in `home`
    for subdir, _, files in os.walk("home"):
        for file in files:
            _overwrite_dotfile(subdir, file)
    # overwrite system dotfiles with local in `root`
    for subdir, _, files in os.walk("root"):
        for file in files:
            _overwrite_dotfile(subdir, file)


def install_dotfiles() -> None:
    if Input.yes_no("Do you want to backup current dotfiles? (Recommended)"):
        make_backup()

    Print.action("Installing dotfiles (this will overwrite your original files)")
    time.sleep(2)

    overwrite_dotfiles()

    Print.action("Dotfile installation complete, make sure to adjust the dotfiles to your liking.")


if __name__ == "__main__":
    install_dotfiles()
