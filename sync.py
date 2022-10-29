#!/usr/bin/env python
from __future__ import annotations

import hashlib
import sys
from collections.abc import Iterable, Iterator
from enum import Enum, auto
from pathlib import Path
from typing import NamedTuple

try:
    import rich
except ImportError:
    print("rich not found (`pip install rich`), falling back to no colors", file=sys.stderr)
    rich = None

DOTHOMEDIR = Path("./home")
HOMEDIR = Path("~")
DOTROOTDIR = Path("./root")
ROOTDIR = Path("/")


class DiffStatus(Enum):
    NOT_FOUND = auto()
    PERMISSION_ERROR = auto()
    MATCH = auto()
    EXPECTED_SYMLINK = auto()
    UNEXPECTED_SYMLINK = auto()
    CONTENT_DIFFERS = auto()
    SYMLINK_DIFFERS = auto()
    UNEXPECTED_DIRECTORY = auto()


class FileDiff(NamedTuple):
    dot_file: Path
    sys_file: Path
    status: DiffStatus

    def __repr__(self) -> str:
        dot_file = str(self.rel_dot_file)
        sys_file = str(self.sys_file)
        status = self.status.name
        return f"FileDiff({dot_file=}, {sys_file=}, {status=})"

    @property
    def rel_dot_file(self) -> Path:
        """Returns path to a dot_file relative to workdir."""
        return self.dot_file.relative_to(Path.cwd())


def iter_dir(directory: Path) -> Iterator[Path]:
    """Recursively iterate over given directory and yield all files in it."""
    for subpath in directory.iterdir():
        if subpath.is_file() or subpath.is_symlink():
            yield subpath
        else:
            yield from iter_dir(subpath)


def file_sum(file: Path) -> str:
    """Compute SHA-256 hash sum of given file."""
    sha256_hash = hashlib.sha256()
    with file.open("rb") as f:
        for byte_block in iter(lambda: f.read(4096), b""):
            sha256_hash.update(byte_block)
    return sha256_hash.hexdigest()


def compare_files(dot_file: Path, sys_file: Path) -> DiffStatus:
    """Compare two files returning their diff status."""
    try:
        if not sys_file.exists():
            return DiffStatus.NOT_FOUND
    except PermissionError:
        return DiffStatus.PERMISSION_ERROR

    if dot_file.is_symlink():
        if sys_file.is_symlink():
            if dot_file.readlink() == sys_file.readlink():
                return DiffStatus.MATCH
            else:
                # In case the sys_file link uses an absolute path, make sure
                # it points to the same location, even if that location is a
                # symlink.
                dot_target = sys_file.parent.joinpath(dot_file.readlink()).absolute()
                sys_target = sys_file.parent.joinpath(sys_file.readlink()).absolute()
                if dot_target == sys_target:
                    return DiffStatus.MATCH
                return DiffStatus.SYMLINK_DIFFERS
        return DiffStatus.EXPECTED_SYMLINK
    elif sys_file.is_symlink():
        return DiffStatus.UNEXPECTED_SYMLINK

    if sys_file.is_dir():
        return DiffStatus.UNEXPECTED_DIRECTORY

    try:
        if file_sum(dot_file) == file_sum(sys_file):
            return DiffStatus.MATCH
    except PermissionError:
        return DiffStatus.PERMISSION_ERROR

    return DiffStatus.CONTENT_DIFFERS


def iter_pairs() -> Iterator[tuple[Path, Path]]:
    """Go through all files in the dotfiles directories and match them to system paths.

    Yields tuples of (dotfile file path, matching system path)
    """
    for dot_file in iter_dir(DOTHOMEDIR):
        real_file = Path(HOMEDIR, *dot_file.parts[1:])
        yield dot_file.expanduser().absolute(), real_file.expanduser().absolute()

    for dot_file in iter_dir(DOTROOTDIR):
        real_file = Path(ROOTDIR, *dot_file.parts[1:])
        yield dot_file.expanduser().absolute(), real_file.expanduser().absolute()


def iter_diffs() -> Iterator[FileDiff]:
    """Go through all files and compute their diffs."""
    for dot_file, sys_file in iter_pairs():
        diff_status = compare_files(dot_file, sys_file)
        yield FileDiff(dot_file, sys_file, diff_status)


def print_status(diffs: Iterable[FileDiff]) -> None:
    """Pretty print the individual diff statuses."""
    # Exhause the iterable, and ensure we work on a copy
    diffs = list(diffs)

    # Sort by DiffStatus, with MATCH entries being first
    diffs.sort(key=lambda v: (v.status is not DiffStatus.MATCH, v.status.name))

    if rich is None:
        for diff in diffs:
            print(f"{diff.status.name}   ->    {diff.sys_file}")
        return

    from rich.table import Table
    table = Table()
    table.add_column("Status")
    table.add_column("System file", style="magenta")
    table.add_column("Dotfile file", style="magenta")

    for diff in diffs:
        _str_status = diff.status.name.replace("_", " ")
        if diff.status is DiffStatus.MATCH:
            status_str = (f"[green]{_str_status}[/green]")
        elif diff.status is DiffStatus.PERMISSION_ERROR:
            status_str = f"[bold yellow]{_str_status}[/bold yellow]"
        elif diff.status is DiffStatus.NOT_FOUND:
            status_str = f"[bold orange_red1]{_str_status}[/bold orange_red1]"
        else:
            status_str = f"[bold red]{_str_status}[/bold red]"

        try:
            # Unexpand home (/home/xyz/foo -> ~/foo)
            sys_file = Path("~") / diff.sys_file.relative_to(Path.home())
        except ValueError:  # File not in home
            sys_file = diff.sys_file

        sys_file = str(sys_file)
        dot_file = "./" + str(diff.rel_dot_file)
        table.add_row(status_str, sys_file, dot_file)

    rich.print(table)


def exclude_fun(diff: FileDiff) -> bool:
    EXCLUDE_RULES = [
        lambda d: d.status is DiffStatus.MATCH,
        lambda d: d.dot_file.name == ".keep" and d.sys_file.parent.is_dir(),
        lambda d: Path("root/etc/opensnitchd/rules") in d.rel_dot_file.parents,
        lambda d: Path("home/.config/xmobar") in d.rel_dot_file.parents,
        lambda d: Path("home/.config/xmonad") in d.rel_dot_file.parents,
        lambda d: Path("home/.local/share/xmonad") in d.rel_dot_file.parents,
        lambda d: Path("home/.config/topgrade.toml") == d.rel_dot_file,
        lambda d: Path("home/.config/newsboat") in d.rel_dot_file.parents,
        lambda d: Path("home/.cache/zsh/history") == d.rel_dot_file and d.status is DiffStatus.CONTENT_DIFFERS,
        lambda d: Path("home/.local/scripts") in d.rel_dot_file.parents,
        lambda d: Path("home/.config/nomacs/Image Lounge.conf") == d.rel_dot_file and d.status is DiffStatus.CONTENT_DIFFERS,
        lambda d: Path("root") in d.rel_dot_file.parents,  # Temporary
    ]

    for exc_rule in EXCLUDE_RULES:
        if exc_rule(diff):
            return False
    return True


def main() -> None:
    diffs = iter_diffs()
    diffs = filter(exclude_fun, diffs)
    print_status(diffs)



if __name__ == "__main__":
    main()
