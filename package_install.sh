#!/usr/bin/sh

# Set some basic colors using tput (8-bit color: 256 colors)
bold="$(tput bold)"
red="$(tput setaf 196)"
blue="$(tput setaf 51)"
yellow="$(tput setaf 226)"
gold="$(tput setaf 214)"
grey="$(tput setaf 238)"
lgrey="$(tput setaf 243)"
green="$(tput setaf 46)"
reset="$(tput sgr0)"

SCRIPT_DIR="$HOME/dotfiles"

function choose() {
	return $(whiptail \
			--title "$1" \
			--yesno "$2" 25 72 \
			3>&1 1>&2 2>&3)
}

function menu2() {
	output=$(whiptail \
			--title "$1" \
			--menu "$2" 25 72 0 \
			"1" "$3" \
			"2" "$4" \
			3>&1 1>&2 2>&3)
}

function cecho() {
	echo "${lgrey} (package-install) $1${reset}"
}

function yes_no() {
	while true; do
		read -p "(Y/n): " yn
	    case $yn in
	        [Yy]* ) return 0; break;;
	        [Nn]* ) return 1;;
			* ) echo "Invalid choice (y/n)";;
		esac
	done
}

function choice2() {
	cecho "${green} -> 1. $1"
	cecho "${green} -> 2. $2"
	cecho "${green} -> c. Cancel"
	while true; do
		read -p "(1/2/c): " yn
	    case $yn in
	        [1]* ) return "1"; break;;
	        [2]* ) return "2";;
			[cC]* ) return "c";;
			* ) echo "Invalid choice (1/2/c)";;
		esac
	done
}

function choice3() {
	cecho "${green} -> 1. $1"
	cecho "${green} -> 2. $2"
	cecho "${green} -> 3. $3"
	cecho "${green} -> c. Cancel"
	while true; do
		read -p "(1/2/3/c): " yn
	    case $yn in
	        [1]* ) return "1"; break;;
	        [2]* ) return "2";;
			[3]* ) return "3";;
			[cC]* ) return "c";;
			* ) echo "Invalid choice (1/2/c)";;
		esac
	done
}



cecho "${blue} // Do you wish to upgrade packages before installing (recommended) [pacman -Syu]"
if (yes_no); then
	sudo pacman -Syu
fi

cecho "${gold} >> Choose which packages you wish to install"
cecho "${blue} // X window system (xorg xorg-server)"
if (yes_no); then
	sudo pacman -S xorg xorg-server
fi

cecho "${blue} // Desktop Enviroment (you will be able to choose which DE)"
if (yes_no); then
	res = choice2 "KDE - Plasma" "Gnome"
	if [ $res == "1" ]; then
		cecho "${gold} >> Installing plasma"
		sudo pacman -S --needed plasma
	elif [ $res == "2" ]; then
		cecho "${gold} >> Installing gnome"
		sudo pacman -S --needed gnome
	else
		cecho "${yellow} >> Aborting Desktop Enviroment installation"
	fi
fi

cecho "${blue} // Desktop Manager (you will be able to choose which DM)"
if (yes_no); then
	res = choice3 "SDDM (KDE)" "GDM (Gnome)" "LightDM"
	if [ $res == "1" ]; then
		cecho "${gold} >> Installing SDDM (KDE)"
		sudo pacman -S --needed sddm
	elif [ $res == "2" ]; then
		sudo pacman -S --needed gdm
	elif [ $res == "3" ]; then
		sudo pacman -S --needed lightdm
	else
		echo "${lgrey} (package-install) ${yellow} >> Aborting Desktop Enviroment install"
	fi
fi

# sudo pacman -S plasma | sudo pacman -S gnome
sudo pacman -S git
sudo pacman -S
