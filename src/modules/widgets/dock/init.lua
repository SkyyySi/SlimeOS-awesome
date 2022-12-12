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

	_schema_exists = function(self, s)
		s = s or "org.gnome.shell"

		for _, schema in pairs(Gio.Settings.list_schemas()) do
			if schema == s then
				return true
			end
		end

		return false
	end,

	has_favorite = function(self, fav_name)
		local schema = "org.gnome.shell"

		if self:_schema_exists(schema) then
			local favs = Gio.Settings({ schema = schema }):get_strv("favorite-apps")

			for _, fav in ipairs(favs) do
				if fav == fav_name then
					return true
				end
			end
		end

		return false
	end,

	add = function(self, file_name)
		local schema = "org.gnome.shell"

		if self:_schema_exists(schema) then
			local favs = Gio.Settings({ schema = schema }):get_strv("favorite-apps")
			table.insert(favs, file_name)
			Gio.Settings({ schema = schema }):set_strv("favorite-apps", favs)
		end

		awesome.emit_signal("slimeos::dock::favorites::update", self)
		return self
	end,

	remove = function(self, file_name)
		local schema = "org.gnome.shell"

		if self:_schema_exists(schema) then
			local favs = Gio.Settings({ schema = schema }):get_strv("favorite-apps")
			for k, v in pairs(favs) do
				if v == file_name then
					--favs[k] = nil
					table.remove(favs, k)
					break
				end
			end
			Gio.Settings({ schema = schema }):set_strv("favorite-apps", favs)
		end

		awesome.emit_signal("slimeos::dock::favorites::update", self)
		return self
	end,

	update = function(self)
		local schema = "org.gnome.shell"

		if self:_schema_exists(schema) then
			local favs = Gio.Settings({ schema = schema }):get_strv("favorite-apps")
			self:clear()
			for k, v in pairs(favs) do
				self[k] = v
			end
		end

		return self
	end,

	__call = function(self)
		local mt = getmetatable(self)
		mt._iterator = mt._iterator or 0

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

	awesome.connect_signal("slimeos::dock::favorites::add", function(file_name)
		favorites:add(file_name)
	end)

	awesome.connect_signal("slimeos::dock::favorites::remove", function(file_name)
		favorites:remove(file_name)
	end)

	awesome.connect_signal("slimeos::dock::favorites::get", function(callback)
		callback(favorites)
	end)

	awful.spawn.with_line_callback([[dconf watch /org/gnome/shell/favorite-apps]], {
		stdout = function(line)
			favorites:update()
			awesome.emit_signal("slimeos::dock::favorites::update", favorites)
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

dock.generic_app_icon = gears.surface.load_silently(menubar_utils.lookup_icon("application-x-executable"))

function dock.gen_fav_widget(args, app)
	local cur = menubar_utils.parse_desktop_file("/usr/share/applications/"..app)
	if not cur then return end

	local icon = cur.icon_path or menubar_utils.lookup_icon(cur.Icon) or dock.generic_app_icon

	--if app == "firefox.desktop" and not _HGZFJHRFG then
	--	_HGZFJHRFG = app.." "..util.table_to_string(cur)
	--	util.dump_to_file(_HGZFJHRFG, "/tmp/table.lua")
	--end

	--if not util.table_is_empty(cur.actions_table) then
	--	notify(app.." "..util.table_to_string(cur.actions_table), 0)
	--end

	local widget = wibox.widget {
		{
			{
				{
					{
						image      = icon,
						clip_shape = gears.shape.circle,
						widget     = wibox.widget.imagebox,
					},
					bg     = "#F8F8F2",
					shape  = gears.shape.circle,
					shape_border_width = util.scale(1),
					shape_border_color = "#F8F8F2",
					widget = wibox.container.background,
				},
				margins = util.scale(4),
				widget  = wibox.container.margin,
			},
			bg = {
				type  = "radial",
				from  = { util.scale(19), util.scale(22), util.scale(12) },
				to    = { util.scale(20), util.scale(22), util.scale(16) },
				stops = { { 0, "#000000A0" }, { 1/3, "#00000070" }, { 2/3, "#00000030" }, { 1, "#0000" } }
			},
			widget = wibox.container.background,
		},
		{
			{
				id     = "effect_role",
				shape  = gears.shape.circle,
				widget = wibox.container.background,
			},
			margins = util.scale(1),
			widget  = wibox.container.margin,
		},
		desktop_file_data = cur, -- Not used for the widget itself, but rather to access its metadata.
		layout = wibox.layout.stack,
	}

	local cmd
	if cur.cmdline then
		cmd = cur.cmdline
	elseif cur.Exec then
		cmd = util.split(cur.Exec)[1]
	end

	cur.actions_table = cur.actions_table or {}
	local bound_menu
	do
		local bound_menu_items = {}

		local desktop_file_name = cur.file:match(".*/(.*%.desktop)$")
		table.insert(bound_menu_items, {
			"Remove from dock",
			function()
				awesome.emit_signal("slimeos::dock::favorites::remove", desktop_file_name)
			end,
		})

		if next(cur.actions_table) ~= nil then
			table.insert(bound_menu_items, { "-----------" })

			for k, v in pairs(cur.actions_table) do
				if v.Icon then
					v.Icon = menubar_utils.lookup_icon(v.Icon)
				end

				table.insert(bound_menu_items, { v.Name, v.Exec:match("(.+)%s%%") or v.Exec, v.Icon })
			end
		end

		table.insert(bound_menu_items, { "-----------" })
		table.insert(bound_menu_items, { "Close menu", function()
			bound_menu:hide()
		end })

		bound_menu = awful.menu {
			items = bound_menu_items,
		}
	end
	awesome.connect_signal("slimeos::dock::close_all_jumplists_excluding", function(menu)
		if menu ~= bound_menu then
			bound_menu:hide()
		end
	end)

	for _, child in ipairs(widget:get_children_by_id("effect_role")) do
		buttonify {
			widget = child,
			button_callback_release = function(w, b)
				if b == 1 then
					awful.spawn.with_shell(cmd)
				elseif b == 3 then
					awesome.emit_signal("slimeos::dock::close_all_jumplists_excluding", bound_menu)
					bound_menu:toggle()
				end
			end,
		}
	end

	do
		--- The shape function for the tooltip
		---@param cr cairo_surface
		---@param w number Widget width
		---@param h number Widget height
		local function tooltip_shape(cr, w, h)
			local corner_radius  = util.scale(5)
			local arrow_size     = util.scale(10)
			local arrow_position = w / 2 - arrow_size / 1
			(gears.shape.transform(gears.shape.infobubble)
				:rotate_at(w/2, h/2, math.pi))(cr, w, h, corner_radius, arrow_size, arrow_position)
		end

		local tooltip_bg = util.color.alter(beautiful.bg_normal, { a = 0.65 })

		local tooltip = awful.popup {
			ontop   = true,
			visible = false,
			shape   = tooltip_shape,
			bg      = gears.color.transparent,
			widget  = wibox.widget {
				{
					{
						{
							id     = "icon-role",
							forced_width  = util.scale(25),
							forced_height = util.scale(25),
							widget = wibox.widget.imagebox,
						},
						{
							id     = "text-role",
							widget = wibox.widget.textbox,
						},
						spacing = util.scale(4),
						layout  = wibox.layout.fixed.horizontal,
					},
					margins = {
						top = util.scale(10),
						bottom = util.scale(10 + 10),
						left = util.scale(10),
						right = util.scale(10),
					},
					widget  = wibox.container.margin,
				},
				bg     = tooltip_bg,
				shape  = tooltip_shape,
				shape_border_width = util.scale(1),
				shape_border_color = "#FFFFFF",
				widget = wibox.container.background,
			},
		}

		for _, c in pairs(tooltip.widget:get_children_by_id("text-role")) do
			c.markup = cur.Name
		end

		for _, c in pairs(tooltip.widget:get_children_by_id("icon-role")) do
			c.image = cur.icon_path
		end

		awful.placement.bottom(tooltip, {
			honor_workarea = true,
			margins = util.scale(5),
		})

		widget:connect_signal("mouse::enter", function()
			local widget_geo = mouse.current_widget_geometry
			awful.placement.bottom(tooltip, {
				honor_workarea = true,
				margins = util.scale(5),
			})

			if widget_geo and widget_geo.x and widget_geo.width and tooltip.width then
				tooltip.x = widget_geo.x + widget_geo.width / 2 - tooltip.width / 2
			end

			tooltip.visible = true
		end)

		widget:connect_signal("mouse::leave", function()
			tooltip.visible = false
		end)
	end

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

	awesome.connect_signal("slimeos::dock::favorites::update", function(f)
		local iargs = {}
		for k, v in pairs(args) do
			iargs[k] = v
		end
		iargs.favorites = f

		for i, v in pairs(o.children) do
			o.children[i] = nil
		end

		for i, v in pairs(iargs.favorites) do
			o.children[i] = dock.gen_fav_widget(iargs, v)
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
