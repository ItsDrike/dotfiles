#!/usr/bin/sh

# Set some basic colors using tput (8-bit color: 256 colors)
bold="$(tput bold)"
red="$(tput setaf 196)"
blue="$(tput setaf 27)"
yellow="$(tput setaf 226)"
gold="$(tput setaf 214)"
grey="$(tput setaf 238)"
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



echo "${blue} // Do you wish to create symbolic links?${reset}"
if (yes_no); then

	# Backup prompt
	echo "${blue} // Do you wish to create backup? (otherwise your dotfiles will be deleted).${reset}"
	if (yes_no); then

		echo "${gold} >> Backing up current dotfile configuration${reset}"
		sleep 1s

		# Create backup floder if it doesn't exist
		if ! [ -d "$SCRIPT_DIR/backup" ]; then
			echo "Creating backup directory $SCRIPT_DIR/backup"
			mkdir "$SCRIPT_DIR/backup"
		else
			echo "Backup directory: $SCRIPT_DIR/backup"
		fi

		# Backup .oh-my-zsh floder and move it to proper location
		if [ -d "$HOME/.oh-my-zsh"]; then
			echo "Creating backup of .oh-my-zsh"
			cp -r "$HOME/.oh-my-zsh" "$SCRIPT_DIR/backup/"
			# Ensure .config directory existence
			if ! [ -d "$HOME/.config" ]; then
				mkdir "$HOME/.config"
			fi
			# Move oh-my-zsh to config (to match .zshrc position)
			echo "Moving .oh-my-zsh/ to $HOME/.config/oh-my-zsh"
			mv "$HOME/.oh-my-zsh" "$HOME/.config/oh-my-zsh"
		fi

		# Loop through all dotfiles which will be affected and copy them to backup dir
		for file in $(find $SCRIPT_DIR/files -type f); do
			file=${file/$SCRIPT_DIR\/files\//}

			if [ -f "$HOME/$file" ]; then
				# Get name of parent directory of current file
				dirname=$(dirname "${file}")
				# Ensure current dirname is in backup dir
				if ! [ -d "$SCRIPT_DIR/backup/$dirname" ]; then
					echo "Creating directory backup/$dirname"
					mkdir -p "$SCRIPT_DIR/backup/$dirname"
				fi

				echo "Backing up file: $HOME/$file"
				cp "$HOME/$file" "$SCRIPT_DIR/backup/$file"
				sleep 0.1s
			else
				echo "Skipping $file (not found)"
			fi
		done
	else
		echo "${yellow} >> (WARNING) Backing up cancelled, this will erease your current dotfiles${reset}"
		sleep 2s
	fi


	# Create SymLinks
	echo "${gold} >> Creating symbolic links to dotfiles${reset}"
	sleep 1s

	# Loop through every
	for file in $(find $SCRIPT_DIR/files -type f) ; do
		file=${file/$SCRIPT_DIR\/files\//}

		dirname=$(dirname "$HOME/$file")
		if ! [ -d $dirname ]; then
			echo "Creating directory: $dirname"
			mkdir -p $dirname
		fi

		echo "Creating symbolic link: $HOME/$file"
		ln -sf "$SCRIPT_DIR/files/$file" "$HOME/$file"
		# If file is .gitignore ask user for name and email to fill into that file
		if [[ $file == *'.gitconfig' ]]; then
			echo "${blue} // Please specify your name for gitconfig (will be used as commits creators name)${reset}"
			read NAME
			if ! [ -z $NAME ]; then
				sed -i "3s/.*/	name = $NAME/" "$SCRIPT_DIR/files/$file"
			else
				default_name=$(sed '3q;d' "$SCRIPT_DIR/files/$file")
				default_name="${default_name/\	/}"
				default_name="${default_name/name = /}"
				echo "${yellow} >> NAME not specified, using default ($default_name)${reset}"
			fi

			echo "${blue} // Please specify your email for gitconfig (will be used as commits creators mail)${reset}"
			read EMAIL
			if ! [ -z $EMAIL ]; then
				sed -i "4s/.*/	email = $EMAIL/" "$SCRIPT_DIR/files/$file"
			else
				default_email=$(sed '4q;d' "$SCRIPT_DIR/files/$file")
				default_email="${default_email/\	/}"
				default_email="${default_email/email = /}"
				echo "${yellow} >> EMAIL not specified, using default ($default_email)${reset}"
			fi


			unset NAME EMAIL default_name default_email
		fi
		sleep 0.2s
	done

	unset file
else
	echo "${grey} >> Symbolic links to dotfiles will not be created${reset}"
	sleep 1s
fi

if [ -f "$SCRIPT_DIR/package_install.sh" ]; then

	echo "${blue} // Do you wish to install some recommended packages?${reset}"
	if (yes_no); then
		echo "${gold} >> Installing packages, redirection to external script ($SCRIPT_DIR/package_install.sh)${reset}"
		sleep 1s
		sh "$SCRIPT_DIR/package_install.sh"
	else
		echo "${grey} >> No additional packages will be installed.${reset}"
		sleep 1s
	fi
fi

unset title txt1 txt2 txt3
unset SCRIPT_DIR output

echo "${bold}Installation Complete.${reset}"
