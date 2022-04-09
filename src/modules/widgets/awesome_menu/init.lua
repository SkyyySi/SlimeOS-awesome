#!/usr/bin/env lua
local gears         = require("gears")
local awful         = require("awful")
local beautiful     = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")

local awesome_menu = awful.menu {}

local function main(args)
	args = {}

	local script = [[
		cfgdir=']]..gears.filesystem.get_configuration_dir()..[[modules/widgets/awesome_xdg_menu'
		[ -d "${cfgdir}" ] || mkdir -p "${cfgdir}"
		xdg_menu --desktop GNOME --format awesome --root-menu "/etc/xdg/menus/arch-applications.menu" > "${cfgdir}/menus.lua"
	]]

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

		local menu_parts = require('modules.external.archmenu')
		local xdg_menu = {}

		xdg_menu = sort_table_by_key(menu_parts)

		-- Entries related to awesome itself
		local menu_awesome = {
			{ "Show hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
			{ "Show manual", (terminal or "xterm") .. " -e man awesome" },
			{ "Edit config", (editor_cmd or "xterm -e vi") .. " " .. config_dir },
			{ "Restart awesome", awesome.restart },
			{ "Quit awesome", function() awesome.quit() end },
		}

		-- Entries related to power management
		local menu_power = {
			{ "Lock session", "xdg-screensaver lock" }, -- loginctl lock-session
			{ "Shutdown",     "sudo poweroff"         },
			{ "Reboot",       "sudo reboot"           },
			{ "Suspend",      "systemctl suspend"     },
			{ "Hibernate",    "systemctl hibernate"   },
		}

		local menu_template = {
			{ "Awesome",      menu_awesome, beautiful.awesome_icon  },
			{ "Power",        menu_power,   beautiful.icon.power    },
			--{ "Applications", xdg_menu,     beautiful.icon.app      },
			{ "Terminal",     terminal,     beautiful.icon.terminal },
			{ "File manager", filemanager,  beautiful.icon.folder   },
			{ "Web browser",  webbrowser,   beautiful.icon.web      },
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

		local terminal = terminal or "xterm"
		local tools_menu = {
			{ "Settings", "lxqt-config" },
			{ "Terminal", terminal },
			{ "Terminal (as root)", terminal .. [[ -e lxqt-sudo "${SHELL:-/usr/bin/env sh}"]] },
			{ "Kill app (xkill)", "xkill" },
		}

		-- Assemble all menus into one
		awesome_menu = {
			-- Left click
			left = awful.menu(menu_template),

			-- Middle click
			middle = awful.menu(settings_menu),

			-- Right click
			right = awful.menu(tools_menu),
		}
	end)

	return awesome_menu
end

return main
