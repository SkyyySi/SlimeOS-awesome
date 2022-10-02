local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local util = require("modules.lib.util")
local beautiful = require("beautiful")

---@class slimeos.widgets.better_menu
local bm = {
	mt = {},
	__name = "better_menu",
}

bm.mt.__index = bm.mt
bm.__index = bm

---@class slimeos.widgets.better_menu.item : table
---@field label string
---@field icon string
---@field sub slimeos.widgets.better_menu.item The submenu (if present)
---@field onclick fun(self: slimeos.widgets.better_menu.item) Gets ignored if a submenu is defined
---@field bg string
---@field fg string
---@field shape gears.shape
---@field border_width number
---@field border_color string
local item = {}

---@param args slimeos.widgets.better_menu.item
function bm.mkitem(args)
	args = util.default(args, {})
	args = {
		label        = args.label,
		icon         = args.icon,
		sub          = args.sub or {},
		bg           = args.bg,
		fg           = args.fg,
		shape        = args.shape,
		border_width = args.border_width,
		border_color = args.border_color,
	}

	local widget = wibox.widget {
		{
			{
				{
					{
						image  = args.icon,
						widget = wibox.widget.imagebox,
					},
					{
						valign = "center",
						markup = args.label,
						widget = wibox.widget.textbox,
					},
					{
						image  = beautiful.menu_submenu_icon,
						widget = wibox.widget.imagebox,
					},
					foced_width  = beautiful.menu_width,
					foced_height = beautiful.menu_height,
					layout = wibox.layout.align.horizontal,
				},
				layout = wibox.layout.fixed.vertical,
			},
			layout = wibox.layout.fixed.horizontal,
		},
		bg    = args.bg,
		fg    = args.fg,
		shape = args.shape,
		shape_border_width = args.border_width,
		shape_border_color = args.border_color,
		widget = wibox.container.background,
	}

	return widget
end

function bm.mkpopup(widget, s)
	local popup = awful.popup {
		screen    = util.default(s, screen.primary);
		visible   = true,
		ontop     = true,
		placement = awful.placement.top_left,
		bg        = gears.color.transparent,
		widget    = widget or wibox.widget {},
	}

	client.connect_signal("property::active", function(c)
		popup:close()
	end)

	return popup
end

---@param args table<string|integer, any>
function bm.mt:new(args)
	args = util.default(args, {})
	args = {
		items = util.default(args.items, {}), ---@type slimeos.widgets.better_menu.item[]
		direction = util.default(args.direction, "vertical"), ---@type "horizontal"|"vertical"|"h"|"v"
	}

	return setmetatable(args, bm)
end

function bm.mt:__call(...)
	return self:new(...)
end

return setmetatable(bm, bm.mt)
