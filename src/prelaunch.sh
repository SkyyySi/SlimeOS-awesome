#!/usr/bin/env bash
# This script will be sourced before awesome is launched,
# which allows you to, for example, modify the environment
# in an easy way.

# Set the QT theme engine.
# Other common options include 'qt5ct' and 'kvantum'.
export QT_QPA_PLATFORMTHEME='lxqt'
#export QT_QPA_PLATFORMTHEME='qt5ct'

# Whether to redirect Awesome's terminal output (and, by extension,
# the output of all apps Awesome runs) into a log file.
#export AWESOME_SESSION_LOG_OUTPUT=true
export AWESOME_SESSION_LOG_OUTPUT=true

if [[ -e "${HOME}/.screenlayout/layout.sh" ]]; then
	"${HOME}/.screenlayout/layout.sh"
fi
