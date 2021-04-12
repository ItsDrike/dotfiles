import sys
import time
import urllib.request
from urllib.error import URLError

import colorama
import inquirer.shortcuts

from src.util.command import command_exists, run_cmd, run_root_cmd


def _connect_wifi() -> bool:
    """
    Attempt to connect to internet using WiFI.

    This uses `nmtui` with fallback to `iwctl`, if none
    of these tools are aviable, either quit or return False,
    if the tool was executed properly, return True

    Note: True doesn't mean we connected, just that the tool was ran,
    it is up to user to use that tool properly and make the connection.
    """
    if command_exists("nmtui"):
        run_root_cmd("nmtui")
    elif command_exists("iwctl"):
        run_root_cmd("iwctl")
    else:
        print(
            f"{colorama.Fore.RED}{colorama.Style.BRIGHT}ERROR: "
            "WiFi connection tool not found: `nmtui`/`iwctl`, please use Ethernet instead.\n"
            "Alternatively, connect manually outside of this script and re-run it."
        )
        opt = inquirer.shortcuts.list_input(
            "How do you wish to proceed?",
            choices=["Quit and connect manually", "Proceed with Ethernet"]
        )
        if opt == "Quit and connect manually":
            sys.exit()
        else:
            return False
    return True


def _connect_ethernet(max_wait_time: int = 20, iteration_time: int = 1) -> bool:
    """
    Attempt to connect to internet using Ethernet.

    This will simply wait for the user to plug in the ethernet cable,
    once that happens loop is interrupted and True is returned. In case
    it takes over the `max_wait_time`, loop ends and False is returned.

    `iteration_time` is the time of each loop iteration, after whcih we
    check if connection is valid, if not, we continue iterating.
    """
    print(f"{colorama.Style.DIM}Please plug in the Ethernet cable, waiting 20s")
    time_elapsed = 0
    while not check_connection() and time_elapsed < max_wait_time:
        time.sleep(iteration_time)
        time_elapsed += iteration_time

    if time_elapsed >= max_wait_time:
        # We stopped because max wait time was crossed
        return False
    else:
        # We stopped because connection to internet was successful
        return True


def connect_internet():
    wifi_possible = True

    while not check_connection():
        run_cmd("clear")
        print(f"{colorama.Fore.RED}Internet connection unaviable")
        if wifi_possible:
            connect_opt = inquirer.shortcuts.list_input("How do you wish to connect to internet?", choices=["Wi-Fi", "Ethernet"])
        else:
            connect_opt = "Ethernet"

        if connect_opt == "Wi-Fi":
            wifi_possible = _connect_wifi()
        else:
            if _connect_ethernet():
                break

    print(f"{colorama.Fore.GREEN}Internet connection successful")


def check_connection(host="https://google.com") -> bool:
    """Check if system is connected to the internet"""
    try:
        urllib.request.urlopen(host)
        return True
    except URLError:
        return False
