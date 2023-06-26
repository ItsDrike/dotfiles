#!/usr/bin/env python3
import argparse
import json
import subprocess
import sys
from typing import TypedDict, TYPE_CHECKING

if TYPE_CHECKING:
    from _typeshed import SupportsRichComparison


class WorkspaceInfo(TypedDict):
    id: int
    name: str
    monitor: str
    windows: int
    hasfullscreen: bool
    lastwindow: str
    lastwindowtitle: str


class ActiveWorkspaceInfo(TypedDict):
    id: int
    name: str


class MonitorInfo(TypedDict):
    id: int
    name: str
    description: str
    make: str
    model: str
    width: int
    height: int
    refreshRate: float
    x: int
    y: int
    activeWorkspace: ActiveWorkspaceInfo
    reserved: list[int]
    scale: float
    transform: int
    focused: bool
    dpmsStatus: bool
    vrr: bool


class OutputWorkspaceInfo(WorkspaceInfo):
    format_name: str
    active: bool
    monitor_id: int


# workspace id -> remapped name
REMAPS = {
    1: "󰞷",
    2: "󰈹",
    3: "󱕂",
    4: "󰭹",
    5: "󰝚",
    6: "󰋹",
    7: "7",
    8: "8",
    9: "9",
}

# Skip the special (scratchpad) workspace
SKIP = {-99}


def workspace_sort(obj: OutputWorkspaceInfo) -> "SupportsRichComparison":
    """Returns a key to sort by, given the current element."""
    return obj["id"]


def fill_blank_workspaces(open: list[OutputWorkspaceInfo]) -> list[OutputWorkspaceInfo]:
    """Add in the rest of the workspaces which don't have any open windows on them.

    This is needed because hyprland deletes workspaces with nothing in them.
    Note that this assumes all available workspaces were listed in REMAPS, and will
    only fill those. These blank workspaces will have most string values set to "N/A",
    and most int values set to 0.
    """
    # Work on a copy, we don't want to alter the original list
    lst = open.copy()

    for remap_id, format_name in REMAPS.items():
        # Skip for already present workspaces
        if any(ws_info["id"] == remap_id for ws_info in lst):
            continue

        blank_ws: OutputWorkspaceInfo = {
            "id": remap_id,
            "name": str(remap_id),
            "monitor": "N/A",
            "windows": 0,
            "hasfullscreen": False,
            "lastwindow": "N/A",
            "lastwindowtitle": "N/A",
            "active": False,
            "format_name": format_name,
            "monitor_id": 0,
        }
        lst.append(blank_ws)

    return lst


def get_workspaces() -> list[OutputWorkspaceInfo]:
    """Obtain workspaces from hyprctl, sort them and add format_name arg."""
    proc = subprocess.run(["hyprctl", "workspaces", "-j"], stdout=subprocess.PIPE)
    proc.check_returncode()
    try:
        workspaces: list[WorkspaceInfo] = json.loads(proc.stdout)
    except json.JSONDecodeError:
        sys.stderr.writelines([
            "Error decoding json response from hyprctl, returning empty workspaces",
            f"Actual captured output from hyprctl: {proc.stdout!r}"
        ])
        sys.stderr.flush()
        workspaces = []

    proc = subprocess.run(["hyprctl", "monitors", "-j"], stdout=subprocess.PIPE)
    proc.check_returncode()
    monitors: list[MonitorInfo] = json.loads(proc.stdout)

    active_workspaces = {monitor["activeWorkspace"]["id"] for monitor in monitors}

    out: list[OutputWorkspaceInfo] = []
    for workspace in workspaces:
        if workspace["id"] in SKIP:
            continue
        format_name = REMAPS.get(workspace["id"], workspace["name"])
        active = workspace["id"] in active_workspaces
        mon_id = [monitor["id"] for monitor in monitors if monitor["name"] == workspace["monitor"]][0]
        out.append({**workspace, "format_name": format_name, "active": active, "monitor_id": mon_id})

    out = fill_blank_workspaces(out)
    out.sort(key=workspace_sort)
    return out


def print_workspaces() -> None:
    wks = get_workspaces()
    ret = json.dumps(wks)
    print(ret)
    sys.stdout.flush()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--oneshot",
        action="store_true",
        help="Don't listen to stdout for updates, only run once and quit",
    )
    parser.add_argument(
        "--loop",
        action="store_true",
        help="Listen to stdout input, once something is received, re-print workspaces"
    )
    args = parser.parse_args()

    if args.loop and args.oneshot:
        print("Can't use both --oneshot and --loop", file=sys.stdout)
        sys.exit(1)

    if args.loop is None and args.oneshot is None:
        print("No option specified!", file=sys.stdout)
        sys.exit(1)

    # Print workspaces here immediately, we don't want to have to wait for the first
    # update from stdin as we only receive those on actual workspace change.
    print_workspaces()

    if args.oneshot:
        # We've already printed the workspaces once, we can exit now
        return

    # Reprint workspaces on each stdin update (flush)
    for _ in sys.stdin:
        print_workspaces()


if __name__ == "__main__":
    main()
