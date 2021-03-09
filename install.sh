if ! type "python3" &> /dev/null; then
	sudo pacman -S python
fi
if ! type "pip3" &> /dev/null; then
	sudo pacman -S python-pip
fi

pip install -r requirements.txt
python3 -m src
