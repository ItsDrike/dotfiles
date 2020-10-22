import os
import sys

if os.geteuid() != 0:
    sys.exit("Please run this program as root user")
