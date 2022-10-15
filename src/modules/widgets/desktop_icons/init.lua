local g = {
	os = os,
	io = io,
	require = require,
	setmetatable = setmetatable,
}

local capi = {
	---@type screen
	screen = screen,
	---@type mouse
	mouse = mouse,
	awesome = awesome,
}

local awful     = g.require("awful") -- -@type awful
local wibox     = g.require("wibox") ---@type wibox
local gears     = g.require("gears") -- -@type gears
local naughty   = g.require("naughty") -- -@type naughty
local beautiful = g.require("beautiful") -- -@type beautiful

wibox.layout.overflow = g.require("wibox_layout_overflow")

local lfs = g.require("lfs")
local lgi = g.require("lgi")
local glib = lgi.GLib

local util = g.require("desktop_icons.util")
local savestate = g.require("desktop_icons.savestate")

--[[
	TODO list:
	* Allow for file drag-and-drop (requires the Freedesktop XDND API to be available first)
	* Documentation and cleanup...
--]]

---@class desktop_icons.geo.screen
---@field forced_num_cols int
---@field forced_num_rows int
---@field x int
---@field y int
---@field width int
---@field height int

---@class desktop_icons.geometry
local geo = {
	---@type desktop_icons.geo.screen
	screen = {},

	grid_spacing  = util.scale(10),
	min_cols_size = util.scale(50),
	min_rows_size = util.scale(50),
	button_width  = util.scale(140),
	button_height = util.scale(90),
}

---@class desktop_icons.state : table
local state = {
	is_holding_icon   = false,
	is_over_icon      = false,
	known_screens     = {}, ---@type screen[]
	holding_start_pos = { x = 0, y = 0, }, ---@type { x: int, y: int }
	icons_of_screen   = {},
	saved_screens     = {},
}

local index_manager = g.require("desktop_icons.index_manager")
index_manager(state)

function state.save_layout()
	capi.awesome.emit_signal("desktop_icons::save_layout")

	--savestate.load_layout_from_file(nil, function(layout)
	--	awesome.emit_signal("desktop_icons::load_layout", layout)
	--end)

	--[[
	if #state.saved_screens > screen.count() then
		notify(#state.saved_screens)
		for k, v in pairs(state.saved_screens) do
			state.saved_screens[k] = nil
		end

		savestate.save_layout_to_file(savestate.store_path, state.icons_of_screen)
	end
	--]]
end

local desktop_dir_path = util.get_desktop_dir()

---@diagnostic disable-next-line: undefined-global
local terminal = terminal or "xterm"

local generators = g.require("desktop_icons.generators")

local screens_with_desktops = {}

---@class desktop_icons.pages.grid : wibox.layout.grid
---@field try_add fun(self)
---@field save_layout fun(self)

---@return desktop_icons.pages.grid
local function create_page(args)
	local desktop_grid = wibox.widget {
		homogeneous     = true,
		expand          = false,
		orientation     = "horizontal",
		spacing         = geo.grid_spacing,
		min_cols_size   = geo.min_cols_size,
		min_rows_size   = geo.min_rows_size,
		forced_width    = geo.screen[args.screen.index].width,
		forced_height   = geo.screen[args.screen.index].height,
		forced_num_rows = geo.screen[args.screen.index].forced_num_rows,
		layout          = wibox.layout.grid,

	}
	desktop_grid._is_desktop_grid = true

	function desktop_grid:update_size()
		do
			local width = geo.button_width + geo.grid_spacing
			local i = 1
			while width * i < geo.screen[args.screen.index].width do
				i = i + 1
			end
			i = i - 1 --- Prevent overshooting
			geo.screen[args.screen.index].forced_num_cols = i
			self.forced_num_cols = i
		end

		do
			local height = geo.button_height + geo.grid_spacing
			local i = 1
			while height * i < geo.screen[args.screen.index].height do
				i = i + 1
			end
			i = i - 1 --- Prevent overshooting
			geo.screen[args.screen.index].forced_num_rows = i
			self.forced_num_rows = i
		end
	end

	---@param x int
	---@param y int
	---@return {col: int, row: int}
	function desktop_grid:get_tile_index_at_coords(x, y)
		local offset = geo.screen[args.screen.index]

		local col = 1
		do
			local width = geo.button_width + self.spacing
			while width * col < x - offset.x do
				col = col+ 1
			end

			if geo.screen[args.screen.index].forced_num_cols and col > geo.screen[args.screen.index].forced_num_cols then
				col = geo.screen[args.screen.index].forced_num_cols
			end
		end

		local row = 1
		do
			local height = geo.button_height + self.spacing
			while height * row < y - offset.y do
				row = row + 1
			end

			if geo.screen[args.screen.index].forced_num_rows and row > geo.screen[args.screen.index].forced_num_rows then
				row = geo.screen[args.screen.index].forced_num_rows
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
		---@type {col: int, row: int, type: "builtin"|"desktop"|"file"|"directory", id: str}[]
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

		capi.awesome.emit_signal("desktop_icons::state_saved_on", args.screen.index)
	end

	if not screens_with_desktops[args.screen.index] then
		screens_with_desktops[args.screen.index] = desktop_grid
	else
		return screens_with_desktops[args.screen.index]
	end

	desktop_grid:update_size()

	local connected_to_menu = false
	capi.awesome.connect_signal("slimeos::menu_is_ready", function(menus)
		if connected_to_menu then
			return
		end

		connected_to_menu = true

		desktop_grid:connect_signal("button::release", function(_,_,_,b)
			local t = awful.screen.focused().selected_tag

			if b == 3 and not state.is_over_icon then
				menus.main:toggle()
			elseif b == 4 then
				awful.tag.viewprev(t.screen)
			elseif b == 5 then
				awful.tag.viewnext(t.screen)
			end
		end)
	end)

	function desktop_grid:try_add(desktop_icon, placement)
		if desktop_icon then
			if placement then
				local w_at = self:get_widgets_at(placement.row, placement.col, 1, 1)
				if w_at then
					local row, col = self:get_next_empty()

					self:add_widget_at(desktop_icon, row, col, 1, 1)
				else
					self:add_widget_at(desktop_icon, placement.row, placement.col, 1, 1)
				end

				return
			end

			self:add(desktop_icon)
		end
	end

	local function file_or_dir_exists(file)
		local f = desktop_dir_path.."/"..file
		local attr = lfs.attributes(f)

		if not attr then
			notify(f)
			return false
		end

		if attr.mode == "file" or attr.mode == "directory" then
			return true
		end

		return false
	end

	capi.awesome.connect_signal("desktop_icons::load_layout", function(layout)
		if not layout or not layout[args.screen.index] then
			return
		end

		local l = layout[args.screen.index]
		desktop_grid:reset()

		--- sc = shortcut
		for _, sc in pairs(l) do
			local sc_parsed

			if sc.type == "builtin" then
				sc_parsed = generators.builtin[sc.id]({
					parrent = desktop_grid,
					show = args["show_"..sc.id],
					screen = args.screen,
					terminal_emulator = args.terminal_emulator,
					geo = geo,
					state = state,
				})
				desktop_grid:try_add(sc_parsed, { row = sc.row, col = sc.col })
			elseif file_or_dir_exists(sc.id) then
				sc_parsed = generators.file {
					parrent = desktop_grid,-- args,
					file = sc.id,
					screen = args.screen,
					show_files = true,
					show_desktop_launchers = true,
					is_for_desktop = true,
					geo = geo,
					state = state,
				}
				desktop_grid:try_add(sc_parsed, { row = sc.row, col = sc.col })
			end
		end

		capi.awesome.emit_signal("desktop_icons::save_layout")
	end)

	return desktop_grid
end

local desktop_pages = {}
do
	local mt = {}
	mt.__index = mt
	setmetatable(desktop_pages, mt)

	function mt:append(index, item)
		self[index] = self[index] or wibox.widget {
			layout = wibox.layout.overflow.horizontal,
		}

		table.insert(self[index].children, item)
	end

	function mt:clear(index)
		for k, _ in pairs(self[index].children) do
			self.children[k] = nil
		end
	end

	function mt:add(index, page)
		self:append(index, wibox.widget {
			page,
			margins = util.scale(5),
			widget = wibox.container.margin,
		})
	end

	function mt:pop(index)
		self[index][#self[index]] = nil
	end

	function mt:foreach(index, callback)
		for k, page in ipairs(self[index]) do
			callback(k, page)
		end
	end

	function mt:new_selector(index, args)
		args = args or {}
		args.align = args.align or "bottom"

		local page_selector = wibox.widget {
			{
				{
					{
						text   = " < ",
						widget = wibox.widget.textbox,
					},
					id     = "page_prev",
					widget = wibox.container.background,
				},
				{
					nil,
					{
						id     = "page_list",
						layout = wibox.layout.flex.horizontal,
					},
					{
						{
							{
								text   = " - ",
								widget = wibox.widget.textbox,
							},
							id     = "page_del",
							widget = wibox.container.background,
						},
						{
							{
								text   = " + ",
								widget = wibox.widget.textbox,
							},
							id     = "page_add",
							widget = wibox.container.background,
						},
						layout = wibox.layout.fixed.horizontal,
					},
					layout = wibox.layout.align.horizontal,
				},
				{
					{
						text   = " > ",
						widget = wibox.widget.textbox,
					},
					id     = "page_next",
					widget = wibox.container.background,
				},
				layout = wibox.layout.align.horizontal,
			},
			bg     = beautiful.bg_normal,
			shape  = gears.shape.rounded_bar,
			widget = wibox.container.background
		}

		for _, w in ipairs(page_selector:get_children_by_id("page_list")) do
			self:foreach(index, function(k, page)
				local subw = wibox.widget {
					text = " "..tostring(k).." ",
					widget = wibox.widget.textbox,
				}

				table.insert(w.children, subw)
			end)
		end

		for _, w in ipairs(page_selector:get_children_by_id("page_add")) do
		end

		return page_selector
	end

	function mt:new_selector_bar(index, args)
		args = args or {}
		args.selector_widget = args.selector_widget or self:new_selector(index, args)
		args.align = args.align or "bottom"

		local page_selector_bar = wibox {
			shape = gears.shape.rounded_bar,
			bg = gears.color.transparent,
			screen = args.screen,
			visible = true,
			widget = args.selector_widget,
		}

		if args.align == "top" or args.align == "bottom" then
			page_selector_bar.width = util.scale(350)
			page_selector_bar.height = util.scale(50)
		else
			page_selector_bar.width = util.scale(50)
			page_selector_bar.height = util.scale(350)
		end

		awful.placement[args.align](page_selector_bar, {
			honor_workarea = true,
			margins = {
				[args.align] = util.scale(100),
			}
		})

		return page_selector_bar
	end
end

local function main(args)
	args = util.default(args, {})
	args.screen            = util.default(args.screen, capi.screen.primary) ---@type screen
	args.show_computer     = util.default(args.show_computer, true)    ---@type bool
	args.show_network      = util.default(args.show_network, true)     ---@type bool
	args.show_home    = util.default(args.show_home, true)   ---@type bool
	args.show_desktop      = util.default(args.show_desktop, true)     ---@type bool
	args.show_trash        = util.default(args.show_trash, true)       ---@type bool
	args.show_web_browser  = util.default(args.show_web_browser, true) ---@type bool
	args.show_terminal     = util.default(args.show_terminal, true)    ---@type bool
	args.show_files        = util.default(args.show_files, true)       ---@type bool
	args.show_desktop_launchers = util.default(args.show_desktop_launchers, true) ---@type bool
	args.show_hidden_files = util.default(args.show_hidden_files, false) ---@type bool

	geo.screen[args.screen.index] = {}
	geo.screen[args.screen.index].x = args.screen.workarea.x
	geo.screen[args.screen.index].y = args.screen.workarea.y
	geo.screen[args.screen.index].width = args.screen.workarea.width
	geo.screen[args.screen.index].height = args.screen.workarea.height

	local desktop_grid = create_page(args)

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

	function desktop_wibox:update_geometry()
		self.x = geo.screen[args.screen.index].x
		self.y = geo.screen[args.screen.index].y
		self.width = geo.screen[args.screen.index].width
		self.height = geo.screen[args.screen.index].height
	end

	local function update_geomgetry(s)
		if not s then s = args.screen end
		local sw = s.workarea
		geo.screen[args.screen.index].x = sw.x
		geo.screen[args.screen.index].y = sw.y
		geo.screen[args.screen.index].width = sw.width
		geo.screen[args.screen.index].height = sw.height
		util.try_method(desktop_grid, "update_geometry")
		util.try_method(desktop_wibox, "update_geometry")
	end

	args.screen:connect_signal("property::workarea", function(s)
		update_geomgetry(s)
	end)

	capi.awesome.connect_signal("desktop_icons::save_layout", function()
		desktop_grid:save_layout()
	end)

	local function load_layout()
		local layout_file_was_loaded = false
		for file in lfs.dir(savestate.store_dir) do
			if savestate.store_dir.."/"..file == savestate.store_path then
				--- Reminder: `savestate.load_layout_from_file()` returns `true` on success and `false` otherwise
				layout_file_was_loaded = savestate.load_layout_from_file(nil, function(layout)
					local loaded_files = {}
					do
						local mt = {}
						mt.__index = mt
						setmetatable(loaded_files, mt)

						function mt:has(item)
							for _, v in ipairs(self) do
								if v == item then
									return true
								end
							end

							return false
						end
					end

					capi.awesome.emit_signal("desktop_icons::load_layout", layout)

					for desk_id, desk in ipairs(layout) do
						for sc_id, sc in ipairs(desk) do
							if sc.type == "file" or sc.type == "directory" or sc.type == "desktop" then
								table.insert(loaded_files, sc.id)
							end
						end
					end

					if next(loaded_files) ~= nil then
						for file in lfs.dir(desktop_dir_path) do
							if file ~= "." and file ~= ".." and not loaded_files:has(file) then
								--notify(("MISSING: %s"):format(file), 0)
								desktop_grid:try_add(generators.file {
									--desktop_grid, args, file, true
									parrent = desktop_grid,
									screen = args.screen,
									file = file,
									is_for_desktop = true,
									show_files = true,
									show_desktop_launchers = true,
									terminal_emulator = args.terminal_emulator,
									geo = geo,
									state = state,
								})
							end
						end
					end
				end)
				break
			end
		end

		if not layout_file_was_loaded then
			desktop_grid:try_add(generators.builtin.home {
				parrent = desktop_grid,
				screen = args.screen,
				show = args.show_home,
				state = state,
				geo = geo,
			})
			desktop_grid:try_add(generators.builtin.computer {
				parrent = desktop_grid,
				screen = args.screen,
				show = args.show_computer,
				state = state,
				geo = geo,
			})
			desktop_grid:try_add(generators.builtin.trash {
				parrent = desktop_grid,
				screen = args.screen,
				show = args.show_trash,
				state = state,
				geo = geo,
			})
			desktop_grid:try_add(generators.builtin.web_browser {
				parrent = desktop_grid,
				screen = args.screen,
				show = args.show_web_browser,
				state = state,
				geo = geo,
			})
			desktop_grid:try_add(generators.builtin.terminal {
				parrent = desktop_grid,
				screen = args.screen,
				show = args.show_terminal,
				terminal_emulator = args.terminal_emulator,
				state = state,
				geo = geo,
			})

			for file in lfs.dir(desktop_dir_path) do
				if file ~= "." and file ~= ".." then
					desktop_grid:try_add(generators.file {
						--show_hidden_files = false,
						parrent = desktop_grid,
						screen = args.screen,
						file = file,
						is_for_desktop = true,
						show_files = true,
						show_desktop_launchers = true,
						terminal_emulator = args.terminal_emulator,
						geo = geo,
						state = state,
					})
				end
			end

			capi.awesome.emit_signal("desktop_icons::save_layout")
		end
	end
	load_layout()

	awful.spawn.with_line_callback("inotifywait  -e modify -e move -e create -e delete -m '"..desktop_dir_path:gsub([[']], [['"'"']]).."'", {
		stdout = function(line)
			--notify(line)
			--awesome.emit_signal("desktop_icons::save_layout")
			load_layout()
		end,
	})

	desktop_pages:add(args.screen.index, desktop_grid)

	desktop_pages:new_selector_bar(args.screen.index, args)

	desktop_wibox.widget = desktop_pages[args.screen.index].children[1]

	return desktop_wibox
end

return main
