import os
import subprocess

import colorama
import inquirer.shortcuts

DEBUG = True


def debug_confirm_run(cmd):
    if DEBUG:
        cnfrm = inquirer.shortcuts.confirm(
            f"{colorama.Fore.BLUE}[DEBUG] Running command: "
            f"{colorama.Fore.YELLOW}{cmd}{colorama.Fore.RESET}"
        )
        return cnfrm
    else:
        return True


def run_root_cmd(cmd: str, enable_debug: bool = True) -> subprocess.CompletedProcess:
    """Run command as root"""
    if os.geteuid() != 0:
        return run_cmd(f"sudo {cmd}", enable_debug=enable_debug)
    else:
        return run_cmd(cmd, enable_debug=enable_debug)


def run_cmd(cmd: str, capture_out: bool = False, enable_debug: bool = True) -> subprocess.CompletedProcess:
    """Run given command"""
    args = {}
    if capture_out:
        args.update({"stdout": subprocess.PIPE, "stderr": subprocess.STDOUT})

    if not enable_debug or debug_confirm_run(cmd):
        return subprocess.run(cmd, shell=True, **args)
    else:
        # If debug confirm wasn't confirmed, return code 1 (error)
        return subprocess.CompletedProcess(cmd, returncode=1)


def command_exists(cmd) -> bool:
    """Check if given command can be executed"""
    parts = cmd.split()
    executable = parts[0] if parts[0] != "sudo" else parts[1]
    proc = run_cmd(f"which {executable}", capture_out=True)
    return proc.returncode != 1
