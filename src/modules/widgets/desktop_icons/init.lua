local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local naughty   = require("naughty")
local beautiful = require("beautiful")
local util      = require("modules.lib.util")
local globals   = require("modules.lib.globals")
local launcher_utils = require("modules.widgets.rasti_launcher.utils")

local lfs = require("lfs")

---@param path string Filepath
---@param callback fun(mime_type: string)
---@param sub_slash_with_dash boolean
local function get_mime_type(path, callback, sub_slash_with_dash)
	awful.spawn.easy_async({ "file", "-b", "--mime-type", path }, function(stdout)
		if sub_slash_with_dash then
			stdout = stdout:gsub("/", "-")
		end
		callback(stdout)
	end)
end

local geo = {
	x      = 0,
	y      = 0,
	width  = 0,
	height = 0,
	grid_spacing    = util.scale(10),
	min_cols_size   = util.scale(50),
	min_rows_size   = util.scale(50),
	forced_num_rows = 10,
	button_width    = util.scale(140),
	button_height   = util.scale(90),
}

local state = {
	is_holding_icon = false,
	is_over_icon = false,
	holding_start_pos = { x = 0, y = 0, } ---@type { x: integer, y: integer }
}

local desktop_grid = wibox.widget {
	homogeneous     = true,
	expand          = false,
	orientation     = "horizontal",
	spacing         = geo.grid_spacing,
	min_cols_size   = geo.min_cols_size,
	min_rows_size   = geo.min_rows_size,
	forced_width    = geo.width,
	forced_height   = geo.height,
	forced_num_rows = geo.forced_num_rows,
	layout          = wibox.layout.grid,
}

---@param x integer
---@param y integer
---@return {col: integer, row: integer}
function desktop_grid:get_tile_index_at_coords(x, y)
	local col = 1
	do
		local width = geo.button_width + self.spacing
		while width * col < x do
			col = col+ 1
		end

		if geo.forced_num_cols and col > geo.forced_num_cols then
			col = geo.forced_num_cols
		end
	end

	local row = 1
	do
		local height = geo.button_height + self.spacing
		while height * row < y do
			row = row + 1
		end

		if geo.forced_num_rows and row > geo.forced_num_rows then
			row = geo.forced_num_rows
		end
	end

	return { col = col, row = row }
end

--[[ This is a test
for k, v in pairs { { 20, 20 }, { 170, 220 }, { 20, 530 } } do
	local x, y = v[1], v[2]

	--- Should print
	---
	--- - `1 = { col = 1, row = 1 }`
	--- - `2 = { col = 3, row = 2 }`
	--- - `3 = { col = 6, row = 1 }`
	---
	--- when run with a row amount limit of 10 and at least 13 columns of desktop icons.
	local grid_coords = desktop_grid:get_tile_index_at_coords(x, y)
	notify(("%d = { col = %d, row = %d }"):format(k, grid_coords.col, grid_coords.row), 0)

	wibox {
		x = x,
		y = y,
		width = 30,
		height = 30,
		visible = true,
		widget = {
			text = tostring(k),
			valign = "center",
			halign = "center",
			font = "Source Sans Pro, Bold 12",
			widget = wibox.widget.textbox,
		}
	}
end
--]]

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
		forced_height = util.scale(60),
		halign = "center",
		widget = wibox.widget.imagebox,
	}

	local widget_label = wibox.widget {
		text = args.label,
		font = args.font,
		align = "center",
		forced_height = util.scale(30),
		widget = wibox.widget.textbox,
	}

	local widget = wibox.widget {
		{
			{
				nil,
				widget_icon,
				widget_label,
				forced_width = util.scale(140),
				forced_height = util.scale(90),
				layout = wibox.layout.align.vertical,
			},
			halign = "center",
			valign = "center",
			layout = wibox.container.place,
		},
		bg = gears.color.transparent,
		shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, util.scale(5)) end,
		shape_border_width = util.scale(1),
		shape_border_color = gears.color.transparent,
		widget = wibox.container.background,
	}

	local old_cursor, old_wibox
	widget:connect_signal("mouse::enter", function(w)
		state.is_over_icon = true

		local wb = mouse.current_wibox or {}
		old_cursor, old_wibox = wb.cursor, wb
		wb.cursor = "hand1"

		w.bg = "#50A0C040"
		w.shape_border_color = "#50A0C0B0"

	end)

	widget:connect_signal("mouse::leave", function(w)
		mousegrabber.stop()

		state.is_over_icon = false

		if old_wibox then
			old_wibox.cursor = old_cursor
			old_wibox = nil
		end

		w.bg = gears.color.transparent
		w.shape_border_color = gears.color.transparent
	end)

	widget:connect_signal("button::press", function(w,_,_,b)
		state.is_holding_icon = true

		local wb = mouse.current_wibox or {}
		if b == 1 then
			w.bg = "#80C0E080"
			w.shape_border_color = "#A0D0F0D0"
		elseif b == 2 then
			wb.cursor = "fleur" -- fleur
		end

		state.holding_start_pos = mouse.coords()

		if not mousegrabber.isrunning() then
			widget.floating_dnd_box = wibox {
				type    = "dnd",
				width   = geo.button_width,
				height  = geo.button_height,
				bg      = gears.color.transparent,
				visible = false,
				ontop   = true,
				opacity = 0.75,
				widget  = {
					widget,
					bg = "#80C0E080",
					shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, util.scale(5)) end,
					shape_border_width = util.scale(1),
					shape_border_color = "#A0D0F0D0",
					widget = wibox.container.background
				},
			}
			widget.floating_dnd_box_was_placed = false

			mousegrabber.run(function(mouse_state)
				if not widget.floating_dnd_box_was_placed then
					widget.floating_dnd_box_was_placed = true
					--awful.placement.under_cursor(widget.floating_dnd_box)
					widget.floating_dnd_box.x = mouse_state.x - widget.floating_dnd_box.width/2
					widget.floating_dnd_box.y = mouse_state.y - widget.floating_dnd_box.height/2
				end

				if (math.abs(mouse_state.x - state.holding_start_pos.x) > 10
					or math.abs(mouse_state.x - state.holding_start_pos.x) < -10
					or math.abs(mouse_state.y - state.holding_start_pos.y) > 10
					or math.abs(mouse_state.y - state.holding_start_pos.y) < -10)
					and mouse_state.buttons[1]
				then
					widget.floating_dnd_box.visible = true
					widget.floating_dnd_box.x = mouse_state.x - widget.floating_dnd_box.width/2
					widget.floating_dnd_box.y = mouse_state.y - widget.floating_dnd_box.height/2
					w.bg = gears.color.transparent
					w.shape_border_color = gears.color.transparent
					--notify(util.table_to_string(mouse_state), 0)
					--notify(("widget.floating_dnd_box { x = %s, y = %s }"):format(widget.floating_dnd_box.x, widget.floating_dnd_box.y), 0)
				end

				if not mouse_state.buttons[1] then
					state.is_holding_icon = false

					if b == 1 then
						w.bg = "#50A0C040"
						w.shape_border_color = "#50A0C0B0"

						if widget.floating_dnd_box.visible then
							-- desktop_grid:get_widget_position(widget) -> { col, row, col_span, row_span }
							local old_pos = desktop_grid:get_widget_position(widget)
							local new_pos = desktop_grid:get_tile_index_at_coords(mouse_state.x, mouse_state.y)

							widget.floating_dnd_box.visible = false

							if (old_pos.row ~= new_pos.row or old_pos.col ~= new_pos.col) and desktop_grid:get_widgets_at(new_pos.row, new_pos.col, 1, 1) == nil then
								--notifyf("Potion changed:\n\told_col = %d, old_row = %d\n\tnew_col = %d, new_row = %d", old_pos.col, old_pos.row, new_pos.col, new_pos.row)
								desktop_grid:remove_widgets_at(old_pos.row, old_pos.col, 1, 1)
								desktop_grid:add_widget_at(widget, new_pos.row, new_pos.col, 1, 1)
							else
								local clear_bg = true
								for _, widget_under_cursor in pairs(mouse.current_widgets) do
									if w == widget_under_cursor then
										clear_bg = false
										break
									end
								end
								if clear_bg then
									w.bg = gears.color.transparent
									w.shape_border_color = gears.color.transparent
								else
									mousegrabber.stop()
								end
							end
						else
							args.onclick()
						end
						mousegrabber.stop()
					end
				end

				return mouse_state.buttons[1]
			end, wb.cursor or "fleur")
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

	--- Doesn't appear to work properly with `mousegrabber()`
	--[[
	widget:connect_signal("button::release", function(w,_,_,b)
		state.is_holding_icon = false

		if b == 1 then
			w.bg = "#50A0C040"
			w.shape_border_color = "#50A0C0B0"

			--old_cursor_pos = nil
			args.onclick()
		end
	end)
	--]]

	function widget:set_icon(path)
		widget_icon:set_image(path)
		widget_icon:emit_signal("widget::layout_changed")
		widget_icon:emit_signal("widget::redraw_needed")
		widget:emit_signal("widget::layout_changed")
		widget:emit_signal("widget::redraw_needed")
	end

	function widget:set_label(label)
		widget_label:set_text(label)
		widget_label:emit_signal("widget::layout_changed")
		widget_label:emit_signal("widget::redraw_needed")
		widget:emit_signal("widget::layout_changed")
		widget:emit_signal("widget::redraw_needed")
	end

	return widget
end

---@alias b boolean
---@class slimeos.widgets.desktop_icons.main_args
---@field screen screen
---@field show_computer b
---@field show_trash_can b
---@field show_network b
---@field show_user_home b
---@field show_desktop b Whether to show icons defined as .desktop files / shortcuts
---@field show_trash b
---@field show_web_browser b
---@field show_terminal b
---@field show_files b
---@field show_hidden_files b

local tmp = io.popen("xdg-user-dir DESKTOP", "r")
local desktop_dir_path = tmp:read("*a"):gsub("\n", "")
if not desktop_dir_path or desktop_dir_path == "" then
	desktop_dir_path = os.getenv("XDG_DESKTOP_DIR") or os.getenv("HOME").."/Desktop"
end
tmp = nil

local desktop_already_created = false

---@param args? slimeos.widgets.desktop_icons.main_args
local function main(args)
	if not desktop_already_created then
		desktop_already_created = true
	else
		return
	end

	args = util.default(args, {})
	args = {
		screen            = util.default(args.screen, screen.primary), ---@type screen
		show_computer     = util.default(args.show_computer, true),    ---@type boolean
		show_trash_can    = util.default(args.show_trash_can, true),   ---@type boolean
		show_network      = util.default(args.show_network, true),     ---@type boolean
		show_user_home    = util.default(args.show_user_home, true),   ---@type boolean
		show_desktop      = util.default(args.show_desktop, true),     ---@type boolean
		show_trash        = util.default(args.show_trash, true),       ---@type boolean
		show_web_browser  = util.default(args.show_web_browser, true), ---@type boolean
		show_terminal     = util.default(args.show_terminal, true),    ---@type boolean
		show_files        = util.default(args.show_files, true),       ---@type boolean
		show_hidden_files = util.default(args.show_hidden_files, false) ---@type boolean
	}

	geo.x = args.screen.workarea.x
	geo.y = args.screen.workarea.y
	geo.width = args.screen.workarea.width
	geo.height = args.screen.workarea.height

	do
		local width = geo.button_width + geo.grid_spacing
		local i = 1
		while width * i < geo.width do
			i = i + 1
		end
		i = i - 1 --- Prevent overshooting
		geo.forced_num_cols = i
		desktop_grid.forced_num_cols = i
	end

	do
		local height = geo.button_height + geo.grid_spacing
		local i = 1
		while height * i < geo.height do
			i = i + 1
		end
		i = i - 1 --- Prevent overshooting
		geo.forced_num_rows = i
		desktop_grid.forced_num_rows = i
	end

	local desktop_wibox = wibox {
		type    = "desktop",
		x       = geo.x,
		y       = geo.y,
		width   = geo.width,
		height  = geo.height,
		screen  = args.screen,
		visible = true,
		ontop   = false,
		bg      = gears.color.transparent,
	}

	function desktop_wibox:update_layout(s)
		if not s then s = args.screen end
		s = s.workarea
		geo.x = s.x
		geo.y = s.y
		geo.width = s.width
		geo.height = s.height
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

	if args.show_files then
		for file in lfs.dir(desktop_dir_path) do
			if file ~= "." and file ~= ".." and (args.show_hidden_files or not file:match("^%.")) then
				local f = desktop_dir_path.."/"..file
				local attr = lfs.attributes(f)

				if attr.mode == "directory" then
					local desktop_icon = create_desktop_icon {
						icon = "/usr/share/icons/Papirus-Dark/24x24/places/folder.svg",
						label = file,
						onclick = function()
							awful.spawn { "xdg-open", f }
						end
					}

					desktop_grid:add(desktop_icon)
				else
					if launcher_utils.is_desktop_file(f) then
						local desktop_file = launcher_utils.parse_desktop_file(f)
						if not desktop_file.IconPath or desktop_file.IconPath == "" or not util.file_exists(desktop_file.IconPath) then
							desktop_file.IconPath = "/usr/share/icons/Papirus-Dark/24x24/apps/x.svg"
						end

						local desktop_icon = create_desktop_icon {
							icon = desktop_file.IconPath,
							label = desktop_file.Name,
							onclick = function()
								awful.spawn.with_shell(desktop_file.Cmdline)
							end
						}

						desktop_grid:add(desktop_icon)
					else
						local desktop_icon = create_desktop_icon {
							icon = "/usr/share/icons/Papirus-Dark/24x24/mimetypes/application-x-zerosize.svg",
							label = file,
							onclick = function()
								awful.spawn { "xdg-open", f }
							end
						}

						get_mime_type(f, function(mime_type)
							local icon = "/usr/share/icons/Papirus-Dark/24x24/mimetypes/application-x-zerosize.svg"
							if mime_type then
								icon = "/usr/share/icons/Papirus-Dark/24x24/mimetypes/"..mime_type..".svg"
							end

							desktop_icon:set_icon(icon)
						end, true)

						desktop_grid:add(desktop_icon)
					end
				end
			end
		end
	end

	--util.ls("/home/simon/Schreibtisch", function(item) ---@param item string
		--notify(menubar.launcher_utils.parse_desktop_file(item))
		--notify(item)
	--end)

	desktop_wibox.widget = {
		desktop_grid,
		margins = util.scale(5),
		widget = wibox.container.margin,
	}

	--notify(string.format("x: %s, y: %s\nw: %s, h: %s", args.screen.geometry.x, args.screen.geometry.y, args.screen.geometry.width, args.screen.geometry.height))

	return desktop_wibox
end

return main
