#!/usr/bin/env python3
"""
This is a "safe release tag" script to avoid accidental mistakes when creating version release tags.

It will:

1. Checks that you are on `main`, `master`, `release` or `stable` branch.
2. Validate that your local version matches the remote.
3. Ensures that the provided tag is a valid semantic version bump from the latest release tag.
4. Runs git tag -m "" -as <tag> if valid.
"""

from __future__ import annotations

from dataclasses import dataclass
import re
import subprocess
import sys
from typing import ClassVar, final, override

RELEASE_BRANCHES = {"main", "master", "release", "stable"}


@final
@dataclass(frozen=True, order=True)
class SemverTag:
    VERSION_TAG_RE: ClassVar[re.Pattern[str]] = re.compile(r"^(v)?(\d+)\.(\d+)\.(\d+)$")

    has_v: bool
    major: int
    minor: int
    patch: int

    @classmethod
    def from_str(cls, s: str) -> SemverTag:
        """Parse a version tag string into a SemverTag instance."""
        m = cls.VERSION_TAG_RE.fullmatch(s)
        if not m:
            raise ValueError(f"Invalid version tag string: {s}")

        v, major, minor, patch = m.groups()
        return cls(v == "v", int(major), int(minor), int(patch))

    def is_next_after(self, other: SemverTag) -> bool:
        """Return True if this tag is the immediate next major, minor, or patch bump after another tag."""
        return (
            self == SemverTag(other.has_v, other.major + 1, 0, 0)
            or self == SemverTag(other.has_v, other.major, other.minor + 1, 0)
            or self == SemverTag(other.has_v, other.major, other.minor, other.patch + 1)
        )

    @override
    def __str__(self) -> str:
        """Return tag in standard 'vX.Y.Z' format."""
        return f"v{self.major}.{self.minor}.{self.patch}"


def run_git(*args: str) -> str:
    """Run a git command and return stdout, raising on any error."""
    result = subprocess.run(["git", *args], capture_output=True, text=True, check=True)
    return result.stdout.strip()


def ensure_branch() -> None:
    """Exit if not on a valid release branch."""
    branch = run_git("rev-parse", "--abbrev-ref", "HEAD")
    if branch not in RELEASE_BRANCHES:
        sys.exit(
            f"You must be on a valid release branch (one of: {', '.join(RELEASE_BRANCHES)}), your branch: {branch}"
        )


def ensure_remote_match() -> None:
    """Exit if the local version doesn't match the remote version."""
    _ = run_git("fetch")
    branch = run_git("rev-parse", "--abbrev-ref", "HEAD")
    tracking = run_git("rev-parse", "--abbrev-ref", f"{branch}@{{upstream}}")

    local_commit = run_git("rev-parse", branch)
    remote_commit = run_git("rev-parse", tracking)

    if local_commit != remote_commit:
        sys.exit(f"Local branch {branch} is not in sync with remote branch {tracking}")


def get_latest_tag() -> SemverTag:
    """Return the latest git version tag."""
    # Get all tags sorted by creation name
    tags = run_git("tag").splitlines()
    version_tags: list[SemverTag] = []

    for tag in tags:
        try:
            version_tag = SemverTag.from_str(tag)
        except ValueError:
            continue
        version_tags.append(version_tag)

    if not version_tags:
        # Arguably, it might make sense to instead return None and let that pass
        # since it's entirely valid to make a new release tag, however, it could
        # also indicate a problem with the script, so it's safer to just fail and
        # let the user make the first release tag manually.
        sys.exit("No version tags found in repository.")

    # Sort by semantic version, newest first
    return max(version_tags)


def try_make_tag(tag: str) -> None:
    ensure_branch()
    ensure_remote_match()

    try:
        new_tag = SemverTag.from_str(tag)
    except ValueError as exc:
        sys.exit(f"Invalid tag: {exc!s}")

    latest_tag = get_latest_tag()

    if not new_tag.is_next_after(latest_tag):
        sys.exit(f"Given tag isn't a valid version bump after {latest_tag}")

    _ = run_git("tag", "-m", "", "-as", str(new_tag))


def main() -> None:
    if len(sys.argv) != 2:
        sys.exit(f"Usage: {sys.argv[0]} <new_tag>")

    new_tag_str = sys.argv[1]
    try_make_tag(new_tag_str)


if __name__ == "__main__":
    main()
