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
		cfgdir=']]..gears.filesystem.get_configuration_dir()..[[modules/widgets/awesome_xdg_menu'
		[ -d "${cfgdir}" ] || mkdir -p "${cfgdir}"
		xdg_menu --desktop GNOME --format awesome --root-menu "/etc/xdg/menus/arch-applications.menu" > "${cfgdir}/menus.lua"
	]]

	local apps = {}
	apps.terminal     = globals.terminal     or "xterm"
	apps.editor       = globals.editor       or globals.terminal .. " -e vi"
	apps.file_browser = globals.file_browser or "dolphin"
	apps.web_browser  = globals.web_browser  or "firefox"

	awful.spawn.easy_async_with_shell(script, function(stdout, stderr, reason, exit_code)
		local function sort_table_by_key(t)
			local index_table = {}

			for i,v in pairs(t) do
				table.insert(index_table, i)
			end

			table.sort(index_table)

			local output_table = {}

			for i,v in pairs(index_table) do
				output_table[i] = { index = v, value = t[v] }
			end

			return output_table
		end

		local menu_parts = dofile(util.get_script_path().."menus.lua")
		local xdg_menu = {}

		xdg_menu = sort_table_by_key(menu_parts)

		-- Entries related to awesome itself
		local menu_awesome = {
			{ "Show hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
			{ "Show manual", apps.terminal .. " -e man awesome" },
			{ "Edit config", apps.editor .. " " .. globals.config_dir },
			{ "Restart awesome", awesome.restart },
			{ "Quit awesome", function() awesome.quit() end },
		}

		-- Entries related to power management
		local menu_power = {
			{ "Lock session", "xdg-screensaver lock", menubar.utils.lookup_icon("system-lock-screen") }, -- loginctl lock-session
			{ "Shutdown",     "sudo poweroff",        menubar.utils.lookup_icon("system-shutdown") },
			{ "Reboot",       "sudo reboot",          menubar.utils.lookup_icon("system-reboot") },
			{ "Suspend",      "systemctl suspend",    menubar.utils.lookup_icon("system-suspend") },
			{ "Hibernate",    "systemctl hibernate",  menubar.utils.lookup_icon("system-hibernate") },
			{ "Log out",      function() awesome.exit() end, menubar.utils.lookup_icon("system-log-out") },
		}

		local menu_template = {
			{ "Awesome",      menu_awesome,      beautiful.awesome_icon  or nil },
			{ "Power",        menu_power,        beautiful.icon.power    or nil },
			--{ "Applications", xdg_menu,          beautiful.icon.app      or nil },
			{ "Terminal",     apps.terminal,     beautiful.icon.terminal or nil },
			{ "File manager", apps.file_browser, beautiful.icon.folder   or nil },
			{ "Web browser",  apps.web_browser,  beautiful.icon.web      or nil },
			{ "⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯" },
		}

		for _,v in pairs(xdg_menu) do
			table.insert(menu_template, { v.index, v.value })
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
