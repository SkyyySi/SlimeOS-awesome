local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")
--local menubar   = require("menubar")
local menubar_utils = require("modules.widgets.dock.menubar_utils")
local util      = require("modules.lib.util")
local buttonify = require("modules.lib.buttonify")
local lgi       = require("lgi")
local Gio       = lgi.Gio

local favs_mt = {
	clear = function(self)
		for k, _ in pairs(self) do
			self[k] = nil
		end

		return self
	end,

	replace_with = function(self, other)
		if type(other) ~= "table" then
			return self
		end

		for k, _ in pairs(self) do
			self[k] = nil
		end

		return self
	end,

	update = function(self)
		for _, schema in pairs(Gio.Settings.list_schemas()) do
			if schema == "org.gnome.shell" then
				local favs = Gio.Settings({ schema = schema }):get_strv("favorite-apps")
				self:clear()
				for k, v in pairs(favs) do
					self[k] = v
				end
				break
			end
		end

		return self
	end,

	__call = function(self)
		local mt = getmetatable(self)

		if mt._iterator < #self then
			iterator = mt._iterator + 1
			local ret = self[mt._iterator]
			return ret
		end

		mt._iterator = 0
	end,
}
favs_mt.__index = favs_mt
local favorites = setmetatable({}, favs_mt)

favorites:update()

if not _SLIMEOS_GNOME_SHELL_FAVORITES_STORE then
	_SLIMEOS_GNOME_SHELL_FAVORITES_STORE = favorites

	awful.spawn.with_line_callback([[dconf watch /org/gnome/shell/favorite-apps]], {
		stdout = function(line)
			favorites:update()
			awesome.emit_signal("slimeos::dock::favorites_update", favorites)
		end,
	})
end

--notify(util.table_to_string(menubar_utils.parse_desktop_file("/usr/share/applications/"..favorites[1])), 0)

---@class slimesos.widgets.dock
---@field orientation "horizontal"|"vertical" Currently: "horizontal" is default --- If not set, the dock will try to auto-determin this value (by checking which direction has more space available)
---@field stretch boolean When `true`, the dock will be stretched with a speparator between the icons and the trash can.
---@field favorites string[]
local dock = {}
dock.__index = dock

dock.ref = {}
local ref_mt = {}
ref_mt.__index = ref_mt
setmetatable(dock.ref, ref_mt)

function dock.ref:__call()
	return self:get()
end

function ref_mt:__call(value)
	local value_wrap = { value = value }
	local proxy = {
		get = function(self)
			return value_wrap.value
		end,

		set = function(self, v)
			value_wrap.value = v
		end,
	}

	return setmetatable(proxy, self)
end

local mt = {}
mt.__index = mt
setmetatable(dock, mt)

function dock.gen_fav_widget(args, app)
	local cur = menubar_utils.parse_desktop_file("/usr/share/applications/"..app)
	if not cur then return end

	local icon = cur.icon_path or menubar_utils.lookup_icon(cur.Icon) or beautiful.awesome_icon

	if app == "firefox.desktop" and not _HGZFJHRFG then
		_HGZFJHRFG = app.." "..util.table_to_string(cur)
		util.dump_to_file(_HGZFJHRFG, "/tmp/table.lua")
	end

	--if not util.table_is_empty(cur.actions_table) then
	--	notify(app.." "..util.table_to_string(cur.actions_table), 0)
	--end

	local w = wibox.widget {
		{
			{
				{
					{
					image      = icon,
					clip_shape = gears.shape.circle,
					widget     = wibox.widget.imagebox,
					},
					margins = util.scale(1),
					widget  = wibox.container.margin,
				},
				bg     = "#EEEEEE",
				shape  = gears.shape.circle,
				widget = wibox.container.background,
			},
			margins = util.scale(2),
			widget  = wibox.container.margin,
		},
		shape  = gears.shape.circle,
		widget = wibox.container.background,
	}

	local widget = wibox.widget {
		w,
		desktop_file_data = cur, -- Not used for the widget itself, but rather to access its metadata.
		margins = util.scale(2),
		widget  = wibox.container.margin,
	}

	local cmd
	if cur.cmdline then
		cmd = cur.cmdline
	elseif cur.Exec then
		cmd = util.split(cur.Exec)[1]
	end

	local bound_menu_items = {}
	for k, v in pairs(cur.actions_table) do
		if v.Icon then
			v.Icon = menubar_utils.lookup_icon(v.Icon)
		end

		table.insert(bound_menu_items, { v.Name, v.Exec:match("(.+)%s%%") or v.Exec, v.Icon })
	end
	local bound_menu = awful.menu {
		items = bound_menu_items,
	}
	awesome.connect_signal("slimeos::dock::close_all_jumplists_excluding", function(menu)
		if menu ~= bound_menu then
			bound_menu:hide()
		end
	end)

	buttonify {
		w,
		button_callback_release = function(w, b)
			if b == 1 then
				awful.spawn.with_shell(cmd)
			elseif b == 3 then
				awesome.emit_signal("slimeos::dock::close_all_jumplists_excluding", bound_menu)
				bound_menu:toggle()
			end
		end,
	}

	local tooltip = awful.tooltip {
		objects = { widget },
		markup = cur.Name,
	}

	return widget
end

function mt:new(args)
	args = util.default(args, {}) ---@type slimesos.widgets.dock
	args = {
		orientation = util.default(args.orientation, "horizontal"),
		stretch = util.default(args.stretch, false),
		favorites = util.default(args.favorites, favorites),
	}

	local o = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
	}

	for i, v in pairs(args.favorites) do
		o.children[i] = dock.gen_fav_widget(args, v)
	end

	awesome.connect_signal("slimeos::dock::favorites_update", function(favorites)
		local iargs = {}
		for k, v in pairs(args) do
			iargs[k] = v
		end
		iargs.favorites = favorites

		for i, v in pairs(o.children) do
			o.children[i] = nil
		end

		for i, v in pairs(args.favorites) do
			o.children[i] = dock.gen_fav_widget(args, v)
		end

		o:emit_signal("widget::layout_changed")
		o:emit_signal("widget::redraw_needed")
	end)

	return o
end

function mt:__call(...)
	return self:new(...)
end

return dock
