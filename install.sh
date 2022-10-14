#!/usr/bin/env bash

if [[ ! -e '/etc/arch-release' ]]; then
	echo 'You do not appear to be running Arch Linux. Exiting'
	exit 1
fi

config_path="${XDG_CONFIG_HOME:-$HOME/.config}/awesome"
repo_path="https://github.com/SkyyySi/SlimeOS-awesome"
script_name="${0:-install.sh}"
dryrun=0 # Using a number allows to use `(( dryrun ))` instead of `[[ $dryrun = true ]]`; 0 = false, anything else = true

usage_info() {
	printf '\e[0m%s\n' "Usage: $script_name [-p <target path>] [-dh]
Install SkyyySi's awesome wm dotfiles.

  -h, --help      Show this help message and exit.

  -p, --path      Specify a target direcotry other than '$config_path'

  -d, --dryrun    Run this script, but don't make any system changes (for testing)
"
}

parse_args() {
	local opts='hdp:'
	local longopts='help,dryrun,path:'

	local options
	options=$(getopt --name="$script_name" --longoptions="$longopts" --options="$opts" -- "$@")
	eval set -- "$options"

	while true; do
		case "$1" in
			-h|--help)
				usage_info
				exit
			;;
			-p|--path)
				shift
				config_path="$1"
			;;
			-d|--dryrun)
				shift
				dryrun=1
			;;
		esac
	done
}

msg() {
	printf '\e[33;1m>>> \e[36m%s\e[00m\n' "$1"
}

msg_substep() {
	printf ' \e[33;1m-> \e[36m%s\e[00m\n' "$1"
}

msg_info() {
	printf ' \e[32;1m-> \e[36m%s\e[00m\n' "$1"
}

command_exists() {
	return "$(command -v "$1" &> /dev/null; echo "$?")";
}

installer_install_deps() {
	if ! command_exists paru; then
		msg_info "The paru AUR helper does not appear to be installed - installing that one first..."
		local paru_dir
		paru_dir="/tmp/slimeos_installer_paru_$(LANG=C date '+%F__%T')"
		if ! (( dryrun )); then
			mkdir "$paru_dir" || exit 1
			cd "$paru_dir" || exit 1
			git clone "https://aur.archlinux.org/paru-bin" "./paru-bin" || exit 1
			cd paru-bin || exit 1
			makepkg -sifcr || exit 1
			cd .. || exit 1
			rm -rf "./paru-bin"
		fi
	fi

	msg_info "Installing dependencies using paru..."
	paru --needed -Syu konsole-dracula-git ant-dracula-gtk-theme ant-dracula-kde-theme ant-dracula-kvantum-theme-git awesome-luajit-git playerctl inotify-tools pulseaudio perl papirus-icon-theme nitrogen konsole dolphin firefox lxqt-config lxqt-session || exit 1
}

installer_clone_repo() {
	local repo_store_dir="$HOME/Dots/awesome"

	msg_substep "Cloning '$repo_path' to '$repo_store_dir'..."
	(( dryrun )) || git clone --recursive-submodules https://github.com/SkyyySi/SlimeOS-awesome "$repo_store_dir" || exit 1

	if [[ -d $config_path ]]; then
		local backup_path
		backup_path="${XDG_CONFIG_HOME:-$HOME/.config}/awesome_backup_$(LANG=C date '+%F__%T')"
		msg_info "Previous configuration detected - it was backed up to '$backup_path'"
		(( dryrun )) || mv "$config_path" "$backup_path" || exit 1
	fi
	msg_info "Symlinking '$repo_store_dir/src' to '$config_path'..."
	(( dryrun )) || ln -s "$repo_store_dir/src" "$config_path" || exit 1
}

parse_args "$@"

clear
printf '\e[96;1m%s\e[00m\n' ' ____  _     _  _      _____ ____  ____    ____  ____  _____  ____ '
printf '\e[36;1m%s\e[00m\n' '/ ___\/ \   / \/ \__/|/  __//  _ \/ ___\  /  _ \/  _ \/__ __\/ ___\'
printf '\e[36;1m%s\e[00m\n' '|    \| |   | || |\/|||  \  | / \||    \  | | \|| / \|  / \  |    \'
printf '\e[34;1m%s\e[00m\n' '\___ || |_/\| || |  |||  /_ | \_/|\___ |  | |_/|| \_/|  | |  \___ |'
printf '\e[34;1m%s\e[00m\n' '\____/\____/\_/\_/  \|\____\\____/\____/  \____/\____/  \_/  \____/'

echo
msg 'Beginning installation of SlimeOS awesome...'

echo
msg 'Installing dependencies...'
installer_install_deps
msg 'Dependencies installed!'

echo
msg 'Installing dots...'
installer_clone_repo
msg 'Dotfiles installed!'

echo
msg 'Installation complete! Enjoy!'
