import os
import sys

from src.packages import install_packages


if os.geteuid() != 0:
    sys.exit("Please run this program as root user")

install_packages()
