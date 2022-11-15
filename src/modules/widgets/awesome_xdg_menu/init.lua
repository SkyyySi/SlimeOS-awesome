local gears         = require("gears")
local awful         = require("awful")
local beautiful     = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")
local util          = require("modules.lib.util")
local globals       = require("modules.lib.globals")
local naughty       = require("naughty")
local menubar       = require("menubar")

-- Create an empty menu to make awesome not error out while waiting
-- for it to be populated via a callback function.
-- Create a launcher widget and a main menu
local awesome_menu = {
	main = awful.menu { -- populate it with awesome's default menu
		items = {
			{ "awesome", {
				{ "hotkeys",     function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
				{ "manual",      globals.terminal.." -e man awesome" },
				{ "edit config", globals.editor.." "..awesome.conffile },
				{ "restart",     awesome.restart },
				{ "quit",        function() awesome.quit() end },
			}, beautiful.awesome_icon },
			{ "open terminal", globals.terminal },
		}
	},
	settings = awful.menu {},
	tools    = awful.menu {},
}

local function main(args)
	if _SLIMEOS_MENU_GENERATION_ALREADY_STARTED then
		return
	end

	_SLIMEOS_MENU_GENERATION_ALREADY_STARTED = true

	args = {}

	local script = [[
		cfgdir=']]..util.get_script_path()..[['
		[ -d "${cfgdir}" ] || mkdir -p "${cfgdir}"
		"]]..util.get_script_path()..[[/xdg_menu" --desktop GNOME --format awesome --root-menu "/etc/xdg/menus/arch-applications.menu" > "${cfgdir}/menus.lua"
	]]

	local apps = {}
	apps.terminal     = globals.terminal     or "xterm"
	apps.editor       = globals.editor       or globals.terminal .. " -e vi"
	apps.file_browser = globals.file_browser or "dolphin"
	apps.web_browser  = globals.web_browser  or "firefox"

	awful.spawn.easy_async_with_shell(script, function(stdout, stderr, reason, exit_code)
		local xdg_menu = dofile(util.get_script_path().."/menus.lua")
		table.sort(xdg_menu, function(a, b)
			return a[1] < b[1]
		end)

		-- Entries related to awesome itself
		local menu_awesome = {
			{ "Show hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end, menubar.utils.lookup_icon("input-keyboard-symbolic")   or "/usr/share/icons/Papirus-Dark/symbolic/devices/input-keyboard-symbolic.svg" },
			{ "Show manual", apps.terminal .. " -e man awesome",                                   menubar.utils.lookup_icon("help-info-symbolic")        or "/usr/share/icons/Papirus-Dark/symbolic/actions/help-info-symbolic.svg" },
			{ "Edit config", apps.editor .. " " .. globals.config_dir,                             menubar.utils.lookup_icon("edit-symbolic")             or "/usr/share/icons/Papirus-Dark/symbolic/actions/edit-symbolic.svg" },
			{ "Restart awesome", awesome.restart,                                                  menubar.utils.lookup_icon("system-restart-symbolic")   or "/usr/share/icons/Papirus-Dark/symbolic/actions/system-restart-symbolic.svg" },
			{ "Quit awesome", function() awesome.quit() end,                                       menubar.utils.lookup_icon("application-exit-symbolic") or "/usr/share/icons/Papirus-Dark/symbolic/actions/application-exit-symbolic.svg" },
		}

		-- Entries related to power management
		local menu_power = {
			{ "Lock session", "xdg-screensaver lock",           menubar.utils.lookup_icon("system-lock-screen") }, -- loginctl lock-session
			{ "Shutdown",     "gnome-session-quit --power-off", menubar.utils.lookup_icon("system-shutdown") },
			{ "Reboot",       "gnome-session-quit --reboot",    menubar.utils.lookup_icon("system-reboot") },
			{ "Suspend",      "systemctl suspend",              menubar.utils.lookup_icon("system-suspend") },
			{ "Hibernate",    "systemctl hibernate",            menubar.utils.lookup_icon("system-hibernate") },
			{ "Log out",      "gnome-session-quit --logout",    menubar.utils.lookup_icon("system-log-out") },
		}

		local menu_template = {
			{ "Awesome",      menu_awesome,      beautiful.awesome_icon },
			{ "Power",        menu_power,        beautiful.icon.power    or menubar.utils.lookup_icon("system-shutdown-symbolic")     or "/usr/share/icons/Papirus-Dark/symbolic/actions/system-shutdown-symbolic.svg" },
			--{ "Applications", xdg_menu,          beautiful.icon.app      or nil },
			{ "Terminal",     apps.terminal,     beautiful.icon.terminal or menubar.utils.lookup_icon("utilities-terminal-symbolic")  or "/usr/share/icons/Papirus-Dark/symbolic/apps/utilities-terminal-symbolic.svg" },
			{ "File manager", apps.file_browser, beautiful.icon.folder   or menubar.utils.lookup_icon("system-file-manager-symbolic") or "/usr/share/icons/Papirus-Dark/symbolic/apps/system-file-manager-symbolic.svg" },
			{ "Web browser",  apps.web_browser,  beautiful.icon.web      or menubar.utils.lookup_icon("web-browser-symbolic")         or "/usr/share/icons/Papirus-Dark/symbolic/apps/web-browser-symbolic.svg" },
			{ "⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯" },
		}

		for _,v in pairs(xdg_menu) do
			table.insert(menu_template, { v[1], v[2] })
		end

		local settings_menu = {
			{ "Settings",              "lxqt-config"                       },
			{ "⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯" },
			{ "Appearance",            "lxqt-config-appearance"            },
			{ "Brightness",            "lxqt-config-brightness"            },
			{ "Date and Time",         "lxqt-admin-time"                   },
			{ "Desktop",               "pcmanfm-qt --desktop-pref awesome" },
			{ "Desktop Notifications", "lxqt-config-notificationd"         },
			{ "File associations",     "lxqt-config-file-associations"     },
			{ "Keyboard and Mouse",    "lxqt-config-input"                 },
			{ "Kvantum Manager",       "kvantummanager"                    },
			{ "Locale",                "lxqt-config-locale"                },
			{ "Monitor settings",      "lxqt-config-monitor"               },
			{ "Network settings",      "nm-connection-editor"              },
			{ "Power Management",      "lxqt-config-powermanagement"       },
			{ "Session Settings",      "lxqt-config-session"               },
			{ "Shortcut Keys",         "lxqt-config-globalkeyshortcuts"    },
			{ "Sound Settings",        "pavucontrol-qt"                    },
			{ "Users and Groups",      "lxqt-admin-user"                   },
		}

		local tools_menu = {
			{ "Settings", "lxqt-config" },
			{ "Terminal", apps.terminal },
			{ "Terminal (as root)", apps.terminal .. [[ -e lxqt-sudo "${SHELL:-/usr/bin/env sh}"]] },
			{ "Kill app (xkill)", "xkill" },
		}

		-- Assemble all menus into one
		awesome_menu = {
			-- Left click
			main = awful.menu(menu_template),

			-- Middle click
			settings = awful.menu(settings_menu),

			-- Right click
			tools = awful.menu(tools_menu),
		}

		awesome.emit_signal("slimeos::menu_is_ready", awesome_menu)
	end)

	return awesome_menu
end

return main
