from pathlib import Path
from typing import Optional

import colorama
import inquirer.shortcuts

from src.util.command import run_cmd, run_root_cmd
from src.util.internet import connect_internet

colorama.init(autoreset=True)


def mount_partition(partition_path: Path, mount_path: Optional[Path] = None) -> Path:
    """
    Mount given `partition_path` to `mount_path`.
    If `mount_path` wasn't provided, ask user for it.

    After mounting, mount_path will be returned
    """
    if not mount_path:
        mount_path = Path(inquirer.shortcuts.path(f"Specify mountpoint for {partition_path}", default="/mnt"))

    if not mount_path.exists():
        run_root_cmd(f"mkdir -p {mount_path}")

    run_root_cmd(f"mount {partition_path} {mount_path}")
    return mount_path


def partition_disk() -> Path:
    """Create all necessary partitions and return root mountpoint"""
    uefi = Path("/sys/firmware/efi/efivars").is_dir()

    # Let user make partitions in shell environment
    partitions_made = inquirer.shortcuts.confirm("Do you already have partitions pre-made?")
    if not partitions_made:
        print(
            f"{colorama.Fore.CYAN}Dropping to shell environment, create your partitions here."
            " When you are done, use `exit` to return\n"
            f"{colorama.Style.DIM}This is {'UEFI' if uefi else 'LEGACY (BIOS)'} system\n"
        )
        run_cmd("exec $SHELL")

    # Obtain partitions from user and mount them
    root_part = Path(inquirer.shortcuts.path("Specify the root partition (/dev/sdXY)", exists=True))
    if inquirer.shortcuts.confirm(f"Do you wish to make EXT4 filesystem on {root_part}?", default=True):
        run_root_cmd(f"mkfs.ext4 {root_part}")
    root_mountpoint = mount_partition(root_part)

    if inquirer.shortcuts.confirm("Do you have an EFI partition?", default=uefi):
        if not uefi:
            print(
                f"{colorama.Fore.RED}Warning: Adding EFI partition from non-uefi system isn't adviced.\n"
                "While this process won't directly fail, you won't be able to install a bootloader from "
                "this computer. You can proceed, but you will have to use another computer to install the bootloader."
            )
        efi_part = Path(inquirer.shortcuts.path("Specify EFI partition (/dev/sdXY)", exists=True))
        if inquirer.shortcuts.confirm(f"Do you wish to make FAT32 filesystem on {efi_part}?", default=True):
            run_root_cmd(f"mkfs.fat -F32 {efi_part}")
        mount_partition(efi_part, Path(root_mountpoint, "/boot"))
    elif uefi:
        print(
            f"{colorama.Fore.RED}Proceeding without EFI partition on UEFI system is not adviced, "
            "unless you want to run this OS with other UEFI capable system"
        )

    if inquirer.shortcuts.confirm("Do you have a swap partition?"):
        swap_part = Path(inquirer.shortcuts.path("Specify the swap partition (/dev/sdXY)", exists=True))
        if inquirer.shortcuts.confirm(f"Do you wish to make swap system on {root_part}?", default=True):
            run_root_cmd(f"mkswap {swap_part}")
        if inquirer.shortcuts.confirm("Do you wish to turn on swap?", default=True):
            run_root_cmd(f"swapon {swap_part}")

    while inquirer.shortcuts.confirm("Do you have any other partition?"):
        part_path = Path(inquirer.shortcuts.path("Specify partition path (/dev/sdXY)", exists=True))
        if inquirer.shortcuts.confirm("Do you wish to format this partition?"):
            print(f"{colorama.Fore.CYAN}Dropping to shell, format the partition here and type `exit` to return")
            run_cmd("exec $SHELL")
        mount_partition(part_path)

    print(f"{colorama.Fore.LIGHTCYAN_EX}Printing disk report (with lsblk)")
    run_root_cmd("lsblk")
    if inquirer.shortcuts.confirm("Do you want to drop to shell and make some further adjustments?"):
        print(f"{colorama.Fore.CYAN}After you are done, return by typing `exit`")
        run_cmd("exec $SHELL")

    print(f"{colorama.Fore.GREEN}Partitioning complete")
    return root_mountpoint


def run_pacstrap(root_mountpoint: Path):
    mirror_setup = inquirer.shortcuts.confirm("Do you wish to setup your mirrors (This is necessary for fast downloads)?", default=True)
    if mirror_setup:
        print(
            f"{colorama.Fore.CYAN}Dropping to shell environment, setup your mirrors from here."
            " When you are done, use `exit` to return\n"
            f"{colorama.Style.DIM}Mirrors are located in `/etc/pacman.d/mirrorlist`\n"
        )
        run_cmd("exec $SHELL")

    extra_pkgs = inquirer.shortcuts.checkbox(
        "You can choose to install additional packages with pacstrap here (select with space)",
        choices=["NetworkManager", "base-devel", "vim", "nano"]
    )
    run_root_cmd(f"pacstrap {root_mountpoint} base linux linux-firmware {' '.join(extra_pkgs)}")

    if inquirer.shortcuts.confirm("Do you wish to make some further adjustments and drop to shell?"):
        print(f"{colorama.Fore.CYAN}When you are done, use `exit` to return")
        run_cmd("exec $SHELL")


def install_arch():
    """Perform full Arch installation and return mountpoint and default user"""
    connect_internet()

    run_root_cmd("timedatectl set-ntp true")
    root_mountpoint = partition_disk()
    run_pacstrap(root_mountpoint)
    print(f"{colorama.Fore.CYAN}Generating fstab")
    run_root_cmd(f"genfstab -U {root_mountpoint} >> {root_mountpoint}/etc/fstab")
    print(
        f"\n{colorama.Fore.GREEN}Core installation complete.\n"
        f"{colorama.Fore.YELLOW}Instalation within chroot environment is not possible from this script, "
        "run chroot_install.py within chroot environment.\n"
        f"{colorama.Fore.LIGHTBLUE_EX}Execute: {colorama.Style.BRIGHT}`arch-chroot /mnt`"
    )


if __name__ == "__main__":
    install_arch()
