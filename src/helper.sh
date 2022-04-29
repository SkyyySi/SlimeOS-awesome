#!/usr/bin/env sh
# This is a helper script, intended to be sourced. It provides some usefull
# aliases, functions and environment settings.

AWESOME_CONFIG_DIR="$(dirname "$(basename "$0")")"
export AWESOME_CONFIG_DIR

gitam() {        
	if [ -z "$1" ] || [ -n "$2" ]; then
		echo 'You need to provide a (qouted) commit message!'
		return 1
    fi

	git add "${AWESOME_CONFIG_DIR:-.}"
	git commit -m "${1} | +%d/%m/%Y (%a) %T [%Z]"
}
