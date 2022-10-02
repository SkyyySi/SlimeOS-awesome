local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local naughty   = require("naughty")
local beautiful = require("beautiful")
local util      = require("modules.lib.util")
local buttonify = require("modules.lib.buttonify")

---@param args table
local function main(args)
	args = util.default(args, {})
	args = {
	}

	local bar_widget_text = wibox.widget {
		font         = "Roboto, Semibold 12",
		text         = "",
		align        = "center",
		widget       = wibox.widget.textbox,
	}

	local bar_widget = wibox.widget {
		{
			bar_widget_text,
			left = util.scale(12),
			right = util.scale(12),
			widget = wibox.container.margin,
		},
		widget = wibox.widget.background,
	}

	buttonify {
		bar_widget,
		button_callback_release = function(w, b)
			if b == 3 then
				awesome.emit_signal("playerctl::play-pause")
			end
		end,
	}

	awesome.connect_signal("playerctl::metadata", function(metadata)
		metadata = metadata or {}
		local new_text
		new_text = metadata.title

		bar_widget_text:set_text(new_text)
		bar_widget:emit_signal("widget::redraw_needed")
	end)

	return bar_widget
end

return main
