local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local naughty   = require("naughty")
local beautiful = require("beautiful")
local menubar   = require("menubar")
local util      = require("modules.lib.util")
local globals   = require("modules.lib.globals")

local function create_desktop_icon(args)
	args = util.default(args, {})
	args = {
		icon = util.default(args.icon, beautiful.awesome_icon),
		label = util.default(args.label, "Placeholder"),
		font = util.default(args.font, beautiful.desktop_icon_font, "Source Sans Pro, Semibold "..beautiful.font_size),
		onclick = util.default(args.onclick, function() naughty.notification { message = "The icon you just clicked doesn't appear to have an 'onclick()' function. Consier adding one to give it some actual functionality and to make this message go away." } end)
	}

	local widget_icon = wibox.widget {
		image = args.icon,
		forced_width = util.scale(50),
		forced_height = util.scale(50),
		halign = "center",
		widget = wibox.widget.imagebox,
	}

	local widget_label = wibox.widget {
		text = args.label,
		font = args.font,
		align = "center",
		widget = wibox.widget.textbox,
	}

	local widget = wibox.widget {
		{
			{
				{
					nil,
					widget_icon,
					widget_label,
					forced_width = util.scale(140),
					forced_height = util.scale(90),
					layout = wibox.layout.align.vertical,
				},
				layout = wibox.layout.fixed.horizontal,
			},
			layout = wibox.layout.fixed.vertical,
		},
		bg = gears.color.transparent,
		shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, util.scale(5)) end,
		shape_border_width = util.scale(1),
		shape_border_color = gears.color.transparent,
		widget = wibox.container.background,
	}

	local old_cursor, old_wibox
	widget:connect_signal("mouse::enter", function(w)
		local wb = mouse.current_wibox or {}
		old_cursor, old_wibox = wb.cursor, wb
		wb.cursor = "hand1"

		w.bg = "#50A0C040"
		w.shape_border_color = "#50A0C0B0"
	end)

	widget:connect_signal("mouse::leave", function(w)
		if old_wibox then
			old_wibox.cursor = old_cursor
			old_wibox = nil
		end

		w.bg = gears.color.transparent
		w.shape_border_color = gears.color.transparent
	end)

	--local old_cursor_pos
	widget:connect_signal("button::press", function(w,_,_,b)
		if b == 1 then
			w.bg = "#80C0E080"
			w.shape_border_color = "#A0D0F0D0"
		elseif b == 2 then
			local wb = mouse.current_wibox or {}
			wb.cursor = "fleur" -- fleur
		end

		--if not old_cursor_pos then
		--	old_cursor_pos = mouse.coords()
		--end
		--
		--gears.timer.start_new(0.2, function()
		--	local current_cursor_pos = mouse.coords()
		--
		--	if current_cursor_pos.x ~= old_cursor_pos.x or current_cursor_pos.y ~= old_cursor_pos.y then
		--		--notify("Dragging!")
		--		--- TODO: Add drag-and-drop support
		--	end
		--
		--	old_cursor_pos = current_cursor_pos
		--
		--	return false
		--end)
	end)

	widget:connect_signal("button::release", function(w,_,_,b)
		if b == 1 then
			w.bg = "#50A0C040"
			w.shape_border_color = "#50A0C0B0"

			old_cursor_pos = nil
			args.onclick()
		end
	end)

	function widget:set_icon(path)
		widget_icon:set_image(path)
	end

	function widget:set_label(label)
		widget_label:set_text(label)
	end

	return widget
end

---@alias b boolean
---@class Args
---@field screen screen
---@field show_computer b
---@field show_trash_can b
---@field show_network b
---@field show_user_home b
---@field show_desktop b Whether to show icons defined as .desktop files / shortcuts
---@field show_trash b
---@field show_web_browser b
---@field show_terminal b

local tmp = io.popen("xdg-user-dir DESKTOP", "r")
local desktop_dir_path = tmp:read("*a"):gsub("\n", "")
if desktop_dir_path == "" then
	desktop_dir_path = os.getenv("HOME").."/Desktop"
end
tmp = nil

---@param args? Args
local function main(args)
	args = util.default(args, {})
	args = {
		screen = util.default(args.screen, screen.primary), ---@type screen
		show_computer = util.default(args.show_computer, true), ---@type boolean
		show_trash_can = util.default(args.show_trash_can, true), ---@type boolean
		show_network = util.default(args.show_network, true), ---@type boolean
		show_user_home = util.default(args.show_user_home, true), ---@type boolean
		show_desktop = util.default(args.show_desktop, true),  ---@type boolean
		show_trash = util.default(args.show_trash, true),  ---@type boolean
		show_web_browser = util.default(args.show_terminal, true),  ---@type boolean
		show_terminal = util.default(args.show_terminal, true),  ---@type boolean
	}

	local desktop_wibox = wibox {
		type = "desktop",
		x = args.screen.workarea.x,
		y = args.screen.workarea.y,
		width = args.screen.workarea.width,
		height = args.screen.workarea.height,
		screen = args.screen,
		visible = true,
		ontop = false,
		bg = gears.color.transparent,
	}

	function desktop_wibox:update_layout(s)
		if not s then s = args.screen end
		s = s.workarea
		self.x = s.x
		self.y = s.y
		self.width = s.width
		self.height = s.height
	end

	args.screen:connect_signal("property::workarea", function(s)
		s.desktop_icons:update_layout()
	end)

	local connected_to_menu = false
	awesome.connect_signal("slimeos::menu_is_ready", function(menus)
		if connected_to_menu then
			return
		end

		connected_to_menu = true

		desktop_wibox:connect_signal("button::release", function(_,_,_,b)
			local t = awful.screen.focused().selected_tag

			if b == 1 then
				--
			elseif b == 2 then
				--
			elseif b == 3 then
				menus.main:toggle()
			elseif b == 4 then
				awful.tag.viewprev(t.screen)
			elseif b == 5 then
				awful.tag.viewnext(t.screen)
			end
		end)
	end)

	local desktop_grid = wibox.widget {
		homogeneous = true,
		expand = false,
		orientation = "vertical",
		spacing = util.scale(10),
		min_cols_size = util.scale(50),
		min_rows_size = util.scale(50),
		layout = wibox.layout.grid,
	}

	--for i=1,5 do
	--	desktop_grid:add(create_desktop_icon {
	--		icon = beautiful.awesome_icon,
	--		label = "Test Icon #"..tostring(i),
	--		onclick = function(b)
	--			notify("Clicked on icon #"..tostring(i))
	--		end
	--	})
	--end

	if args.show_computer then
		local desktop_icon = create_desktop_icon {
			icon = "/usr/share/icons/Papirus-Dark/24x24/places/user-home.svg",
			label = "Home",
			onclick = function()
				awful.spawn.with_shell("QT_QPA_PLATFORMTHEME=lxqt xdg-open "..os.getenv("HOME"))
			end
		}

		desktop_grid:add(desktop_icon)
	end

	if args.show_user_home then
		local desktop_icon = create_desktop_icon {
			icon = "/usr/share/icons/Papirus-Dark/24x24/places/user-desktop.svg",
			label = "Your Computer",
			onclick = function()
				awful.spawn.with_shell("QT_QPA_PLATFORMTHEME=lxqt xdg-open /")
			end
		}

		desktop_grid:add(desktop_icon)
	end

	if args.show_trash then
		local trash_path = os.getenv("HOME").."/.local/share/Trash/files"
		local icon_empty, icon_filled = "/usr/share/icons/Papirus-Dark/24x24/places/user-trash.svg", "/usr/share/icons/Papirus-Dark/24x24/places/user-trash-full.svg"

		local desktop_icon = create_desktop_icon {
			icon = icon_empty,
			label = "Trash",
			onclick = function()
				awful.spawn.with_shell("QT_QPA_PLATFORMTHEME=lxqt xdg-open "..trash_path)
			end
		}

		gears.timer {
			timeout = 1,
			autostart = true,
			call_now = true,
			callback = function()
				awful.spawn.easy_async({ "ls", "-A", trash_path }, function(stdout, stderr, reason, exit_code)
					if stdout == "" then
						desktop_icon:set_icon(icon_empty)
					else
						desktop_icon:set_icon(icon_filled)
					end
				end)
			end,
		}

		desktop_grid:add(desktop_icon)
	end

	if args.show_web_browser then
		local desktop_icon = create_desktop_icon {
			icon = "/usr/share/icons/Papirus-Dark/24x24/categories/internet-web-browser.svg",
			label = "Web Browser",
			onclick = function()
				awful.spawn.with_shell("xdg-open http://")
			end
		}

		desktop_grid:add(desktop_icon)
		desktop_icon:set_label("Web Browser")
	end

	if args.show_terminal then
		local desktop_icon = create_desktop_icon {
			icon = "/usr/share/icons/Papirus-Dark/24x24/categories/terminal.svg",
			label = "Terminal",
			onclick = function()
				awful.spawn.with_shell(util.default(globals.terminal, terminal, "xterm"))
			end
		}

		desktop_grid:add(desktop_icon)
	end

	util.ls("/home/simon/Schreibtisch", function(item) ---@param item string
		--notify(menubar.utils.parse_desktop_file(item))
		--notify(item)
	end)

	desktop_wibox.widget = {
		desktop_grid,
		margins = util.scale(5),
		widget = wibox.container.margin,
	}

	--notify(string.format("x: %s, y: %s\nw: %s, h: %s", args.screen.geometry.x, args.screen.geometry.y, args.screen.geometry.width, args.screen.geometry.height))

	return desktop_wibox
end

return main
