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
	git commit -m "${1} | $(date '+%d/%m/%Y (%a) %T [%Z]')"
	echo
	echo " ==> Pushing changes (to $(git branch --show-current) branch) <== "
	git push
}

luarep() {
	LUA_PATH='/usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua;/usr/lib/lua/5.1/?.lua;/usr/lib/lua/5.1/?/init.lua;./?.lua;./?/init.lua;/home/simon/.luarocks/share/lua/5.1/?.lua;/home/simon/.luarocks/share/lua/5.1/?/init.lua;/home/simon/projects/lua/slimeos/src/?.lua;/home/simon/projects/lua/slimeos/src/?/init.lua;/etc/xdg/awesome/?.lua;/etc/xdg/awesome/?/init.lua;/usr/share/awesome/lib/?.lua;/usr/share/awesome/lib/?/init.lua' \
		LUA_CPATH='/usr/lib/lua/5.1/?.so;/usr/lib/lua/5.1/loadall.so;./?.so;/home/simon/.luarocks/lib/lua/5.1/?.so' \
		PATH='/home/simon/.luarocks/bin:/usr/local/bin:/usr/bin:/bin:/home/simon/.local/bin:/home/simon/.bin:/home/simon/bin:/usr/local/sbin:/opt/anaconda/condabin:/apps/1.31.1/usr/bin:/home/simon/.dotnet/tools:/var/lib/flatpak/exports/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/opt/plan9/bin:/var/lib/snapd/snap/bin' \
		rlwrap --always-readline --no-children --multi-line luajit
}
