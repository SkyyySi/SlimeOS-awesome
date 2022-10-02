#!/usr/bin/env bash
_DISPLAY=':4'
CONFIG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$CONFIG_DIR" || exit 1
echo " ==> Launching in $(pwd) <== "

Xephyr "$_DISPLAY" -dpi 96x96 -ac -br -noreset -screen 1600x900&
sleep 1 # Just making sure that Xephyr has been started up fully.

export DISPLAY="$_DISPLAY"

if [[ -e "$CONFIG_DIR/prelauch.sh" ]]; then
	source "$CONFIG_DIR/prelauch.sh"
fi

if command -v vglclient 2> /dev/null; then
	vglclient -detach
	vglrun awesome --config "$CONFIG_DIR/rc.lua"&
else
	awesome --config "$CONFIG_DIR/rc.lua"&
fi

# Allow commands to be typed in the VScode debug terminal.
printf '\nDebugging awesome using Xephyr.\nType `exit` to stop debuggin.\n\n'

while true; do
	printf '> '
	read -r next_command
	awesome-client "$next_command"
done
