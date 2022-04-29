#!/usr/bin/env sh
# This is a helper script, intended to be sourced. It provides some usefull
# aliases, functions and environment settings.
# This file should be loadable by any POSIX shell. For zsh, you can use
# the following to ensure compatibility:
#emulate sh -c 'source "[...]/src/helper.sh"'

AWESOME_CONFIG_DIR="$(dirname "$(basename "$0")")"
export AWESOME_CONFIG_DIR

gitamp() {        
	if [ -z "$1" ] || [ -n "$2" ]; then
		echo 'You need to provide a (qouted) commit message!'
		return 1
    fi

	echo " ==> Adding files <== "
	git add "${AWESOME_CONFIG_DIR:-.}"
	echo
	echo " ==> Commiting changes <== "
	git commit -m "${1} | +%d/%m/%Y (%a) %T [%Z]"
	echo
	echo " ==> Pushing changes (to $(git branch --show-current) branch) <== "
	git push
}
