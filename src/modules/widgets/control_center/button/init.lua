local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local util      = require("modules.lib.util")
local buttonify = require("modules.lib.buttonify")

---@class control_center.button
local button = {
	screen = screen.primary, -- Setting this isn't actually necessary, as this widget will not create any windows. It's only for testing.

	is_active = false,
	activity_signal = nil, ---@type string?

	has_label    = true,
	label_normal = "Normal",
	label_active = "Active",
	font_normal  = util.default(beautiful.font, "Roboto, Regular 12"), ---@type string
	font_active  = util.default(beautiful.font, "Roboto, Regular 12"), ---@type string

	has_icon    = true,
	icon_normal = beautiful.awesome_icon, ---@type string
	icon_active = beautiful.awesome_icon, ---@type string

	shape_normal = util.default(beautiful.button_shape_normal, beautiful.widget_shape_normal, function(cr, w, h) gears.shape.rounded_rect(cr, w, h, util.scale(10)) end), ---@type fun(cr: cairo.context, w: number, h: number, ...?)
	shape_active = util.default(beautiful.button_shape_active, beautiful.widget_shape_active, function(cr, w, h) gears.shape.rounded_rect(cr, w, h, util.scale(10)) end), ---@type fun(cr: cairo.context, w: number, h: number, ...?)
	bg_normal    = util.default(beautiful.button_bg_normal, beautiful.widget_bg_normal, beautiful.bg_normal, "#44475a"), ---@type string
	bg_active    = util.default(beautiful.button_bg_active, beautiful.widget_bg_active, beautiful.bg_active, "#bd93f9"), ---@type string
	fg_normal    = util.default(beautiful.button_fg_normal, beautiful.widget_fg_normal, beautiful.fg_normal, "#f8f8f2"), ---@type string
	fg_active    = util.default(beautiful.button_fg_active, beautiful.widget_fg_active, beautiful.fg_active, "#282a36"), ---@type string
	border_color_normal = util.default(beautiful.button_border_color_normal, beautiful.widget_border_color_normal, beautiful.border_color_normal, beautiful.fg_normal, "#f8f8f2"), ---@type string
	border_color_active = util.default(beautiful.button_border_color_active, beautiful.widget_border_color_active, beautiful.border_color_active, beautiful.fg_active, "#f8f8f2"), ---@type string
	border_width_normal = util.default(beautiful.button_border_width_normal, beautiful.widget_border_width_normal, beautiful.border_width_normal, beautiful.border_width, 0), ---@type number
	border_width_active = util.default(beautiful.button_border_width_active, beautiful.widget_border_width_active, beautiful.border_width_active, beautiful.border_width, 0), ---@type number
	onclick = function(self, button) ---@type fun(self: control_center.button, button: number)
		local retval = ("The button '%s' was clicked (with mouse button %s).\nIs active: %s"):format(self, button, self.is_active)
		print(retval)
	end,
	update_widgets = function() end,
}

---@class control_center.button.meta : control_center.button
local mt = {}
mt.__index = mt

---@param self control_center.button.meta
---@param base table?
---@return control_center.button
function mt:new(base)
	self.__index = self
	base = setmetatable(util.default(base, {}), self) ---@type control_center.button

	local current_property = {}
	---@param is_active boolean
	local function make_current_properties(is_active)
		if base.is_active then
			current_property.label = base.label_active
			current_property.font  = base.font_active
			current_property.icon  = base.icon_active
			current_property.shape = base.shape_active
			current_property.bg    = base.bg_active
			current_property.fg    = base.fg_active
			current_property.border_color = base.border_color_active
			current_property.border_width = base.border_width_active
		else
			current_property.label = base.label_normal
			current_property.font  = base.font_normal
			current_property.icon  = base.icon_normal
			current_property.shape = base.shape_normal
			current_property.bg    = base.bg_normal
			current_property.fg    = base.fg_normal
			current_property.border_color = base.border_color_normal
			current_property.border_width = base.border_width_normal
		end
	end

	make_current_properties(base.is_active)

	local widget_component = {}

	widget_component.label = wibox.widget {
		markup = current_property.label,
		font   = current_property.font,
		align  = "center",
		valign = "center",
		widget = wibox.widget.textbox,
	}

	widget_component.icon = wibox.widget {
		image  = current_property.icon,
		halign = "center",
		valign = "center",
		widget = wibox.widget.imagebox,
	}

	widget_component.mouse_effects = wibox.widget {
		{
			{
				widget_component.icon,
				top    = util.scale(12),
				left   = util.scale(12),
				right  = util.scale(12),
				widget = wibox.container.margin,
			},
			widget_component.label,
			layout = wibox.layout.align.vertical,
		},
		widget = wibox.container.background
	}

	widget_component.container = wibox.widget {
		widget_component.mouse_effects,
		shape = current_property.shape,
		bg    = current_property.bg,
		fg    = current_property.fg,
		shape_border_color = current_property.border_color,
		shape_border_width = current_property.border_width,
		widget = wibox.container.background,
	}

	function base:update_widgets()
		make_current_properties(base.is_active)

		widget_component.label.markup = current_property.label
		widget_component.label.font   = current_property.font

		widget_component.icon.image = current_property.icon

		widget_component.container.shape = current_property.shape
		widget_component.container.bg = current_property.bg
		widget_component.container.fg = current_property.fg
		widget_component.container.shape_border_color = current_property.border_color
		widget_component.container.shape_border_width = current_property.border_width

		widget_component.label:emit_signal("widget::redraw_needed")
		widget_component.icon:emit_signal("widget::redraw_needed")
		widget_component.container:emit_signal("widget::redraw_needed")
	end

	buttonify {
		widget = widget_component.mouse_effects,
		button_callback_release = function(w, b)
			base.is_active = not base.is_active
			base:update_widgets()
			base:onclick(b)
		end
	}

	--widget_component.container:connect_signal("widget::redraw_needed", function()
	--	notify("Current fg: "..tostring(current_property.fg))
	--	base:update_widgets()
	--end)

	return widget_component.container
end

mt.__call = mt.new

setmetatable(button, mt)
return button
