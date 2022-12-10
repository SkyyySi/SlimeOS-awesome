local wibox = require("wibox")
local util  = require("modules.lib.util")

---@param left wibox.widget
---@param center wibox.widget
---@param right wibox.widget
---@param buttons? awful.button
---@param callback? fun(self: wibox.widget)
---@return wibox.widget widget
local function absolute_center(left, center, right, buttons, callback)
	--- `absolute_center {...}` overrides the click surface; this widget
	--- counteracts this.
	---@type wibox.widget
	local grab_field = wibox.widget {
		buttons = util.default(buttons, {}),
	}

	local ret = wibox.widget {
		{ -- Left widget
			{
				left,
				--right_click_menu_field(),
				layout = wibox.layout.fixed.horizontal,
			},
			{
				layout = wibox.layout.fixed.horizontal,
				buttons = buttons,
			},
			nil,
			expand = "inside",
			layout = wibox.layout.align.horizontal,
		},
		{ -- Middle widget
			nil,
			{
				center,
				layout = wibox.layout.fixed.horizontal,
			},
			layout = wibox.layout.align.horizontal,
		},
		{ -- Right widget
			nil,
			{
				layout = wibox.layout.fixed.horizontal,
				buttons = buttons,
			},
			{
				right,
				layout = wibox.layout.fixed.horizontal,
			},
			layout = wibox.layout.align.horizontal,
		},
		expand = "outside",
		layout = wibox.layout.align.horizontal,
	}

	if callback then
		callback(ret)
	end

	return ret
end

return absolute_center
