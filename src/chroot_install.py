import colorama

colorama.init(autoreset=True)


def install_chroot():
    print(f"{colorama.Fore.RED}Sorry, chroot installation file is still WIP, for now, proceed manually.")
    print(f"{colorama.Fore.LIGHTCYAN_EX}You can use `arch-install-checklist.md` file which containes detailed installation steps.")


if __name__ == "__main__":
    install_chroot()
