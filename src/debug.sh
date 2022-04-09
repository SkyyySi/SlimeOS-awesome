#!/usr/bin/env bash
_DISPLAY=':4'
CONFIG_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$CONFIG_DIR" || exit 1

Xephyr "$_DISPLAY" -ac -br -noreset -screen 1600x900&
sleep 1 # Just making sure that Xephyr has been started up fully.

export DISPLAY="$_DISPLAY"

awesome --config "$CONFIG_DIR/rc.lua"
