import os
import sys

from src.packages import install_packages
from src.util.user import Input, Print


if os.geteuid() != 0:
    sys.exit("Please run this program as root user")


def main():
    if Input.yes_no("Do you wish to perform package install (from `packages.yaml`)?"):
        install_packages()


try:
    main()
except KeyboardInterrupt:
    Print.err("User cancelled (KeyboardInterrupt)")
