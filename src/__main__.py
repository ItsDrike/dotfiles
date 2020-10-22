import os

from src.packages import install_packages
from src.util.user import Input, Print


def main():
    if os.geteuid() == 0:
        Print.err("You can't to run this program as root user")
        return

    if Input.yes_no("Do you wish to perform package install (from `packages.yaml`)?"):
        install_packages()


try:
    main()
except KeyboardInterrupt:
    Print.err("User cancelled (KeyboardInterrupt)")
