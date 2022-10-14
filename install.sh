#!/usr/bin/env bash

if [[ ! -e '/etc/arch-release' ]]; then
	echo 'You do not appear to be running Arch Linux. Exiting'
	exit 1
fi

config_path="${XDG_CONFIG_HOME:-$HOME/.config}/awesome"

parse_args() {
	local opts='d,p:'
	local longopts='dryrun,path:'

	
}

msg() {
	printf '\e[33;1m>>> \e[36m%s\e[00m\n' "$1"
}

msg_info() {
	printf '\e[32;1m>>> \e[36m%s\e[00m\n' "$1"
}

installer_clone_repo() {
	git clone --recursive-submodules https://github.com/SkyyySi/SlimeOS-awesome "$HOME/Dots/awesome"
	if [[ -d $config_path ]]; then
		local backup_path
		backup_path="${XDG_CONFIG_HOME:-$HOME/.config}/awesome_backup_$(LANG=C date '+%F__%T')"
		msg_info "Previous configuration detected - it was backed up to '$backup_path'"
		mv "$config_path" "backup_path"
	fi
	ln -s "$HOME/Dots/awesome/src" "$config_path"
}

clear
printf '\e[36;1m%s\e[00m\n' ' ____  _     _  _      _____ ____  ____    ____  ____  _____  ____ '
printf '\e[36;1m%s\e[00m\n' '/ ___\/ \   / \/ \__/|/  __//  _ \/ ___\  /  _ \/  _ \/__ __\/ ___\'
printf '\e[36;1m%s\e[00m\n' '|    \| |   | || |\/|||  \  | / \||    \  | | \|| / \|  / \  |    \'
printf '\e[36;1m%s\e[00m\n' '\___ || |_/\| || |  |||  /_ | \_/|\___ |  | |_/|| \_/|  | |  \___ |'
printf '\e[36;1m%s\e[00m\n' '\____/\____/\_/\_/  \|\____\\____/\____/  \____/\____/  \_/  \____/'

parse_args

echo
msg 'Beginning installation of SlimeOS awesome...'

echo
msg 'Cloning repository...'
installer_clone_repo
msg 'Cloning done!'

echo
msg 'Installation complete! Enjoy!'
