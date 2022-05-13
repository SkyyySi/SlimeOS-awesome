#!/usr/bin/env lua
local gears     = require("gears")
local awful     = require("awful")
local wibox     = require("wibox")
local ruled     = require("ruled")
local naughty   = require("naughty")
local util      = require("modules.lib.util")
local bling     = require("modules.external.bling")
local playerctl = bling.signal.playerctl.lib()

---@param args table
local function main(args)
	if not args then args = {} end
	args = {
		width = util.default(args.width, util.scale(350)), ---@type number
	}

	local bar_widget_text = wibox.widget {
		markup = "Nothing playing",
		widget = wibox.widget.textbox,
	}

	playerctl:connect_signal("metadata", function(_, title, artist, album_path, album, new, player_name)
		--if new then
			local new_text = util.sstrfmt(
				[[♫ <b>${artist}</b> - <b>${title}</b> <i>(from '${album}')</i>  |  ]],
				{artist = artist, title = title, album = album}
			)
			--notify(new_text)
			bar_widget_text:set_markup_silently(new_text)
		--end
	end)

	local bar_widget = wibox.widget {
		{
			{
				nil,
				bar_widget_text,
				nil,
				layout = wibox.layout.align.horizontal,
			},
			--step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
			max_size      = util.scale(350),
			speed         = 40,
			layout        = wibox.container.scroll.horizontal,
		},
		layout = wibox.layout.fixed.horizontal,
	}

	return bar_widget
end

return main
