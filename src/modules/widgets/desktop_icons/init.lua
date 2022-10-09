local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local naughty   = require("naughty")
local beautiful = require("beautiful")
local util      = require("modules.lib.util")
local globals   = require("modules.lib.globals")
local launcher_utils = require("modules.widgets.rasti_launcher.utils")

local lfs = require("lfs")

local lgi = require("lgi")
local cairo = lgi.cairo

--[[
	TODO list:
	* Save the layout to load it back in later
	  * Currently,
	* Allow for file drag-and-drop (requires the Freedesktop XDND API to be available first)
	* Watch the desktop for changes and automatically update it accordingly (probably using `inotifywatch`)
	* Documentation and cleanup...
--]]


local savestate = {}

savestate.util = {}

--- Replace escape sequences with their litteral representation.
---@param s string
---@return string, integer
function savestate.util.string_escape(s)
	return s:gsub("\a", [[\a]])
		:gsub("\b", [[\b]])
		:gsub("\f", [[\f]])
		:gsub("\n", [[\n]])
		:gsub("\r", [[\r]])
		:gsub("\t", [[\t]])
		:gsub("\v", [[\v]])
		:gsub("\\", [[\\]])
		:gsub("\"", [[\"]])
		:gsub("\'", [[\']])
end

---@param str string
---@param n number
---@return string
function savestate.util.string_multiply(str, n)
	if n <= 0 then
		return ""
	end

	local outs = ""
	local floor = math.floor(n)
	local point = n - floor

	for i = 1, n do
		outs = outs..str
	end

	if point > 0 then
		local len = #str * floor
		outs = outs..str:sub(1, math.floor(len))
	end

	return outs
end

---@param t table
---@param indent? string
---@param depth? integer
---@return string
function savestate.util.table_to_string(t, indent, depth)
	if type(t) ~= "table" then
		return ""
	end

	indent = indent or "\t" --- Tab masterrace!!!
	depth = depth or 0
	local bracket_indent = savestate.util.string_multiply(indent, depth)
	local full_indent = bracket_indent..indent

	if next(t) == nil then
		if depth > 0 then
			return "{},"
		else
			return "{}"
		end
	end

	local outs = "{\n"

	for k, v in pairs(t) do
		local tv = type(v)
		local tk = type(k)

		if tk == "string" then
			k = '"'..savestate.util.string_escape(k)..'"'
		elseif tk == "function" or tk == "thread" or tk == "userdata" then
			k = "[["..tostring(k).."]]"
		end

		if tv == "table" then
			outs = ("%s%s[%s] = %s"):format(outs, full_indent, k, savestate.util.table_to_string(v, indent, depth + 1).."\n")
		else
			if tv == "string" then
				v = '"'..savestate.util.string_escape(v)..'"'
			elseif tv == "function" or tv == "thread" or tv == "userdata" then
				v = "[["..tostring(v).."]]"
			end

			outs = ("%s%s[%s] = %s,\n"):format(outs, full_indent, k, v)
		end
	end

	if depth > 0 then
		return outs..bracket_indent.."},"
	else
		return outs..bracket_indent.."}"
	end
end

savestate.env = {}

savestate.env.home_dir  = os.getenv("HOME")
savestate.env.cache_dir = os.getenv("XDG_CACHE_HOME") or savestate.env.home_dir.."/.cache"
savestate.store_dir = savestate.env.cache_dir.."/awesome"
savestate.store_path = savestate.store_dir.."/desktop_icon_state.lua"

---@param path? string
---@param callback fun(content): boolean
---@return boolean was_successful `false` if an error occured, otherwise true
function savestate.read_file_content(path, callback)
	path = path or savestate.store_path

	local file,err = io.open(path, "w")
	local content = ""

	if file then
		content = file:read()
		file:close()
	elseif err then
		naughty.emit_signal("request::display_error", "ERROR: Could not load desktop layout from file: "..err)
		return false
	else
		naughty.emit_signal("request::display_error", "ERROR: Could not load desktop layout from file!")
		return false
	end

	return callback(content)
end

---@param path? string
---@param content string
---@return boolean was_successful `false` if an error occured, otherwise true
function savestate.write_file_content(path, content)
	path = path or savestate.store_path

	local file,err = io.open(path, "w")

	if file then
		file:write(content)
		file:close()
	elseif err then
		naughty.emit_signal("request::display_error", "ERROR: Could not save desktop layout to file: "..err)
		return false
	else
		naughty.emit_signal("request::display_error", "ERROR: Could not save desktop layout to file!")
		return false
	end

	return true
end

---@param path? string
---@param callback fun(parsed_data): boolean
---@return boolean was_successful `false` if an error occured, otherwise true
function savestate.deserialize_file(path, callback)
	path = path or savestate.store_path

	local parsed_data

	-- While loading random files is generally really studpid, if an
	-- attacker wanted to inject your config with mallicious code,
	-- they could just inject it into your rc.lua directly.
	if pcall(function() return dofile(savestate.store_path) end) then
		parsed_data = dofile(savestate.store_path)
	else
		naughty.emit_signal("request::display_error", "ERROR: Could not parse desktop layout from content!")
		return false
	end

	return callback(parsed_data)
end

---@param path? string
---@param content table
---@return boolean was_successful `false` if an error occured, otherwise true
function savestate.serialize_to_file(path, content)
	path = path or savestate.store_path

	local file_content = savestate.util.table_to_string(content)

	local ret = savestate.write_file_content(path, "return "..file_content.."\n")

	return ret
end


---@param path string Filepath
---@param callback fun(mime_type: string)
---@param sub_slash_with_dash boolean
local function get_mime_type(path, callback, sub_slash_with_dash)
	awful.spawn.easy_async({ "file", "-b", "--mime-type", path }, function(stdout)
		stdout = stdout:gsub("\n", "")
		if sub_slash_with_dash then
			stdout = stdout:gsub("/", "-")
		end
		callback(stdout)
	end)
end

--- Determine whether a file is an image usable as a cairo surface
--- using `wibox.widget.imagebox` or not.
---@param path string Filepath
---@return boolean file_can_be_surface
local function file_can_be_cairo_surface(path)
	path = path:lower()
	local f_ext = path:match("%.(.*)$")

	if not f_ext then
		return false
	end

	for _, ext in ipairs { "png", "jpg", "bmp", "svg", "ppm" } do
		if f_ext == ext then
			return true
		end
	end

	return false
end

local geo = {
	screen = {},
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
	holding_start_pos = { x = 0, y = 0, }, ---@type { x: integer, y: integer }
	icons_of_screen = {},
	saved_screens = {},
}

function state.save_layout()
	awesome.emit_signal("desktop_grid::save_layout")

	--savestate.deserialize_file(nil, function(layout)
	--	awesome.emit_signal("desktop_grid::load_layout", layout)
	--end)

	--[[
	if #state.saved_screens > screen.count() then
		notify(#state.saved_screens)
		for k, v in pairs(state.saved_screens) do
			state.saved_screens[k] = nil
		end

		savestate.serialize_to_file(savestate.store_path, state.icons_of_screen)
	end
	--]]
end

do
	local mt = {}
	function mt:has_index(i)
		for k, v in pairs(self) do
			if v == i then
				return true
			end
		end

		return false
	end

	function mt:clear()
		for k, v in pairs(self) do
			self[k] = nil
		end
	end

	mt.insert = table.insert

	function mt:__tostring()
		local outs = ""
		local first = true

		for k, v in pairs(self) do
			if first then
				first = false
				outs = "{ "..tostring(v)
			else
				outs = outs..", "..tostring(v)
			end
		end

		return outs.." }"
	end

	mt.__index = mt

	local indecies = setmetatable({}, mt)

	awesome.connect_signal("desktop_grid::state_saved_on", function(index)
		indecies:insert(index)

		if indecies:has_index(index) and #indecies >= screen.count() then
			--notify("All desktop layouts were retrived - saving now!")
			indecies:clear()
			--notify(savestate.util.table_to_string(state.icons_of_screen))
			savestate.serialize_to_file(nil, state.icons_of_screen)
		else
			--notifyf("Still waiting for desktop layouts to be retrived\n%s", indecies)
		end
	end)
end

local function create_desktop_icon(args)
	args = util.default(args, {})
	args = {
		desktop_grid = args.desktop_grid, --- required
		screen = util.default(args.screen, screen.primary),
		icon = util.default(args.icon, beautiful.awesome_icon),
		label = util.default(args.label, "Placeholder"),
		font = util.default(args.font, beautiful.desktop_icon_font, "Source Sans Pro, Semibold "..beautiful.font_size),
		onclick = util.default(args.onclick, function() naughty.notification { message = "The icon you just clicked doesn't appear to have an 'onclick()' function. Consier adding one to give it some actual functionality and to make this message go away." } end),
		type = util.default(args.type, "file"), ---@type "builtin"|"desktop"|"file"
		tooltip = args.tooltip,
		id = args.id,
	}
	args.tooltip = util.default(args.tooltip, args.label)
	args.id = util.default(args.id, args.label)

	local desktop_grid = args.desktop_grid

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

	local tooltip = awful.tooltip {
		objects = { widget },
		timeout = 0.2,
		timer_function = function()
			if state.is_holding_icon then
				return ""
			end

			return args.tooltip
		end,
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

			mousegrabber.run(function(mouse_state) ---@param mouse_state { x: integer, y: integer, buttons: boolean[] }
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
								state.save_layout()
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

	function widget:get_icon()
		return widget_label:get_image()
	end
	function widget:set_icon(path)
		widget_icon:set_image(path)
	end

	function widget:get_label()
		return widget_label:get_text()
	end
	function widget:set_label(label)
		widget_label:set_text(label)
	end

	function widget:get_savedata()
		return {
			type = args.type,
			id = args.id,
		}
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
---@field show_desktop_launchers b

local tmp = io.popen("xdg-user-dir DESKTOP", "r")
local desktop_dir_path = tmp:read("*a"):gsub("\n", "")
if not desktop_dir_path or desktop_dir_path == "" then
	desktop_dir_path = os.getenv("XDG_DESKTOP_DIR") or os.getenv("HOME").."/Desktop"
end
tmp = nil

local screens_with_desktops = {}

---@param args? slimeos.widgets.desktop_icons.main_args
local function main(args)
	args = util.default(args, {})
	args = {
		screen            = util.default(args.screen, screen.primary), -- -@type screen
		show_computer     = util.default(args.show_computer, true),    ---@type boolean
		show_trash_can    = util.default(args.show_trash_can, true),   ---@type boolean
		show_network      = util.default(args.show_network, true),     ---@type boolean
		show_user_home    = util.default(args.show_user_home, true),   ---@type boolean
		show_desktop      = util.default(args.show_desktop, true),     ---@type boolean
		show_trash        = util.default(args.show_trash, true),       ---@type boolean
		show_web_browser  = util.default(args.show_web_browser, true), ---@type boolean
		show_terminal     = util.default(args.show_terminal, true),    ---@type boolean
		show_files        = util.default(args.show_files, true),       ---@type boolean
		show_desktop_launchers = util.default(args.show_desktop_launchers, true), ---@type boolean
		show_hidden_files = util.default(args.show_hidden_files, false), ---@type boolean
	}

	geo.screen[args.screen.index] = {}
	geo.screen[args.screen.index].x = args.screen.workarea.x
	geo.screen[args.screen.index].y = args.screen.workarea.y
	geo.screen[args.screen.index].width = args.screen.workarea.width
	geo.screen[args.screen.index].height = args.screen.workarea.height

	local desktop_grid = wibox.widget {
		homogeneous     = true,
		expand          = false,
		orientation     = "horizontal",
		spacing         = geo.grid_spacing,
		min_cols_size   = geo.min_cols_size,
		min_rows_size   = geo.min_rows_size,
		forced_width    = geo.screen[args.screen.index].width,
		forced_height   = geo.screen[args.screen.index].height,
		forced_num_rows = geo.forced_num_rows,
		layout          = wibox.layout.grid,
	}

	function desktop_grid:update_size()
		self.x = geo.screen[args.screen.index].x
		self.y = geo.screen[args.screen.index].y
		self.width = geo.screen[args.screen.index].width
		self.height = geo.screen[args.screen.index].height

		do
			local width = geo.button_width + geo.grid_spacing
			local i = 1
			while width * i < geo.screen[args.screen.index].width do
				i = i + 1
			end
			i = i - 1 --- Prevent overshooting
			geo.forced_num_cols = i
			self.forced_num_cols = i
		end

		do
			local height = geo.button_height + geo.grid_spacing
			local i = 1
			while height * i < geo.screen[args.screen.index].height do
				i = i + 1
			end
			i = i - 1 --- Prevent overshooting
			geo.forced_num_rows = i
			self.forced_num_rows = i
		end
	end

	---@param x integer
	---@param y integer
	---@return {col: integer, row: integer}
	function desktop_grid:get_tile_index_at_coords(x, y)
		local offset = geo.screen[args.screen.index]

		local col = 1
		do
			local width = geo.button_width + self.spacing
			while width * col < x - offset.x do
				col = col+ 1
			end

			if geo.forced_num_cols and col > geo.forced_num_cols then
				col = geo.forced_num_cols
			end
		end

		local row = 1
		do
			local height = geo.button_height + self.spacing
			while height * row < y - offset.y do
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

	function desktop_grid:save_layout()
		---@type {col: integer, row: integer, type: "builtin"|"desktop"|"file", id: string}[]
		local data = {}

		for _, child in pairs(self.children) do
			table.insert(data, {})

			local pos = self:get_widget_position(child)
			data[#data].row = pos.row
			data[#data].col = pos.col

			local dat = child:get_savedata()
			for k, v in pairs(dat) do
				data[#data][k] = v
			end
		end

		state.icons_of_screen[args.screen.index] = data
		--table.insert(state.saved_screens, args.screen.index)

		awesome.emit_signal("desktop_grid::state_saved_on", args.screen.index)
		--return savestate.serialize_to_file(savestate.store_path, data)
		--return savestate.serialize_to_file(savestate.icons_of_screen, data)
	end

	if not screens_with_desktops[args.screen.index] then
		screens_with_desktops[args.screen.index] = true
	else
		return
	end

	desktop_grid:update_size()

	local desktop_wibox = wibox {
		type    = "desktop",
		x       = geo.screen[args.screen.index].x,
		y       = geo.screen[args.screen.index].y,
		width   = geo.screen[args.screen.index].width,
		height  = geo.screen[args.screen.index].height,
		screen  = args.screen,
		visible = true,
		ontop   = false,
		bg      = gears.color.transparent,
	}

	local function update_geomgetry(s)
		if not s then s = args.screen end
		local sw = s.workarea
		geo.screen[args.screen.index].x = sw.x
		geo.screen[args.screen.index].y = sw.y
		geo.screen[args.screen.index].width = sw.width
		geo.screen[args.screen.index].height = sw.height
		desktop_grid:update_size()
	end

	args.screen:connect_signal("property::workarea", function(s)
		update_geomgetry(s)
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

	local generators = { builtin = {}, file = {} }

	function generators.builtin.home()
		if args.show_user_home then
			local desktop_icon = create_desktop_icon {
				desktop_grid = desktop_grid,
				icon = "/usr/share/icons/Papirus-Dark/24x24/places/user-home.svg",
				label = "Home",
				type = "builtin",
				id = "home",
				screen = args.screen,
				onclick = function()
					awful.spawn.with_shell("QT_QPA_PLATFORMTHEME=lxqt xdg-open "..os.getenv("HOME"))
				end,
			}

			return desktop_icon
		end
	end

	function generators.builtin.computer()
		if args.show_computer then
			local desktop_icon = create_desktop_icon {
				desktop_grid = desktop_grid,
				icon = "/usr/share/icons/Papirus-Dark/24x24/places/user-desktop.svg",
				label = "Your Computer",
				type = "builtin",
				id = "computer",
				screen = args.screen,
				onclick = function()
					awful.spawn.with_shell("QT_QPA_PLATFORMTHEME=lxqt xdg-open /")
				end,
			}

			return desktop_icon
		end
	end

	function generators.builtin.trash()
		if args.show_computer then
			local trash_path = os.getenv("HOME").."/.local/share/Trash/files"
			local icon_empty, icon_filled = "/usr/share/icons/Papirus-Dark/24x24/places/user-trash.svg", "/usr/share/icons/Papirus-Dark/24x24/places/user-trash-full.svg"
			local label_empty, label_filled = "Trash", "Trash (filled)"

			local desktop_icon = create_desktop_icon {
				desktop_grid = desktop_grid,
				icon = icon_empty,
				label = "Trash",
				type = "builtin",
				id = "trash",
				screen = args.screen,
				onclick = function()
					awful.spawn.with_shell("QT_QPA_PLATFORMTHEME=lxqt xdg-open "..trash_path)
				end,
			}

			--- TODO: Use something like inotifywatch to watch for realtime updates (rather than running a timer)
			gears.timer {
				timeout = 1,
				autostart = true,
				call_now = true,
				callback = function()
					awful.spawn.easy_async({ "ls", "-A", trash_path }, function(stdout, stderr, reason, exit_code)
						if stdout == "" then
							desktop_icon:set_icon(icon_empty)
							desktop_icon:set_label(label_empty)
						else
							desktop_icon:set_icon(icon_filled)
							desktop_icon:set_label(label_filled)
						end
					end)
				end,
			}

			return desktop_icon
		end
	end

	function generators.builtin.web_browser()
		if args.show_web_browser then
			local desktop_icon = create_desktop_icon {
				desktop_grid = desktop_grid,
				icon = "/usr/share/icons/Papirus-Dark/24x24/categories/internet-web-browser.svg",
				label = "Web Browser",
				type = "builtin",
				id = "web_browser",
				screen = args.screen,
				onclick = function()
					awful.spawn.with_shell("xdg-open http://")
				end,
			}

			return desktop_icon
		end
	end

	function generators.builtin.terminal()
		if args.show_terminal then
			local desktop_icon = create_desktop_icon {
				desktop_grid = desktop_grid,
				icon = "/usr/share/icons/Papirus-Dark/24x24/categories/terminal.svg",
				label = "Terminal",
				type = "builtin",
				id = "terminal",
				screen = args.screen,
				onclick = function()
					awful.spawn.with_shell(util.default(globals.terminal, terminal, "xterm"))
				end,
			}

			return desktop_icon
		end
	end

	function generators.file.desktop(file, path)
		local desktop_file = launcher_utils.parse_desktop_file(path)
		if not desktop_file.IconPath or desktop_file.IconPath == "" or not util.file_exists(desktop_file.IconPath) then
			desktop_file.IconPath = "/usr/share/icons/Papirus-Dark/24x24/apps/x.svg"
		end

		local desktop_icon = create_desktop_icon {
			desktop_grid = desktop_grid,
			icon = desktop_file.IconPath,
			label = desktop_file.Name,
			type = "desktop",
			id = file,
			screen = args.screen,
			onclick = function()
				awful.spawn.with_shell(desktop_file.Cmdline)
			end,
		}

		return desktop_icon
	end

	function generators.file.directory(file, path)
		local desktop_icon = create_desktop_icon {
			desktop_grid = desktop_grid,
			icon = "/usr/share/icons/Papirus-Dark/24x24/places/folder.svg",
			label = file,
			type = "file",
			screen = args.screen,
			onclick = function()
				awful.spawn { "xdg-open", path }
			end,
		}

		return desktop_icon
	end

	function generators.file.document(file, path)
		local desktop_icon = create_desktop_icon {
			desktop_grid = desktop_grid,
			icon = "/usr/share/icons/Papirus-Dark/24x24/mimetypes/application-x-zerosize.svg",
			label = file,
			type = "file",
			screen = args.screen,
			onclick = function()
				awful.spawn { "xdg-open", path }
			end,
		}

		if file_can_be_cairo_surface(file) then
			desktop_icon:set_icon(path)
		else
			get_mime_type(path, function(mime_type)
				local icon = "/usr/share/icons/Papirus-Dark/24x24/mimetypes/application-x-zerosize.svg"
				if mime_type then
					icon = "/usr/share/icons/Papirus-Dark/24x24/mimetypes/"..mime_type..".svg"
				end

				desktop_icon:set_icon(icon)
			end, true)
		end

		return desktop_icon
	end

	setmetatable(generators.file, {
		__call = function(self, file)
			if args.show_hidden_files or not file:match("^%.") then
				local f = desktop_dir_path.."/"..file
				local attr = lfs.attributes(f)

				if attr.mode == "directory" then
					if args.show_files then
						return self.directory(file, f)
					end
				else
					if launcher_utils.is_desktop_file(f) and args.show_desktop_launchers then
						return self.desktop(file, f)
					else
						if args.show_files then
							return self.document(file, f)
						end
					end
				end
			end
		end,
	})

	local function try_add(desktop_icon)
		if desktop_icon then
			desktop_grid:add(desktop_icon)
		end
	end

	try_add(generators.builtin.home())
	try_add(generators.builtin.computer())
	try_add(generators.builtin.trash())
	try_add(generators.builtin.web_browser())
	try_add(generators.builtin.terminal())

	for file in lfs.dir(desktop_dir_path) do
		if file ~= "." and file ~= ".." then
			try_add(generators.file(file))
		end
	end

	awesome.connect_signal("desktop_grid::load_layout", function(layout)
		if not layout then
			return
		end

		local l = layout[args.screen.index]
		desktop_grid:reset()
		update_geomgetry()

		--- sc = shortcut
		for _, sc in pairs(l) do
			local sc_parsed

			if sc.type == "builtin" then
				sc_parsed = generators.builtin[sc.id]()
			else
				sc_parsed = generators.file(sc.id)
			end

			desktop_grid:add_widget_at(sc_parsed, sc.row, sc.col, 1, 1)
		end
	end)

	for file in lfs.dir(savestate.store_dir) do
		if savestate.store_dir.."/"..file == savestate.store_path then
			notify("FOUND IT")
			savestate.deserialize_file(nil, function(layout)
				awesome.emit_signal("desktop_grid::load_layout", layout)
			end)

			break
		end
	end

	awesome.connect_signal("desktop_grid::save_layout", function()
		desktop_grid:save_layout()
	end)

	desktop_wibox.widget = {
		desktop_grid,
		margins = util.scale(5),
		widget = wibox.container.margin,
	}

	return desktop_wibox
end

return main
