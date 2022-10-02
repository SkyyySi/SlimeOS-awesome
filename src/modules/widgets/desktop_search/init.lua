local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local util = require("modules.lib.util")

local function main(args)
	args = util.default(args, {})
	args = {
		screen = util.default(args.screen, screen.primary),
	}

	local desktop_wibox = wibox {
		width   = util.scale(600),
		height  = util.scale(48),
		visible = true,
		ontop   = false,
		screen  = args.screen,
		bg      = gears.color.transparent,
		shape   = gears.shape.rounded_bar,
	}

	awful.placement.top(desktop_wibox, {
		honor_workarea = true,
		margins = {
			top = util.scale(200),
		}
	})

	local prompt_widget = wibox.widget {
		fg     = "#FFFFFF80",
		bg     = "#00000000",
		prompt = "Search the Web",
		widget = awful.widget.prompt,
	}

	desktop_wibox.widget = wibox.widget {
		{
			prompt_widget,
			left   = util.scale(16),
			right  = util.scale(16),
			widget = wibox.container.margin,
		},
		bg     = "#282A36",
		shape  = gears.shape.rounded_bar,
		widget = wibox.widget.background,
	}

	desktop_wibox:connect_signal("button::release", function(w,_,_,b)
		if b == 1 then
			awful.prompt.run {
				--with_shell = false,
				prompt = "Search the Web: ",
				font = beautiful.font,
				textbox = prompt_widget.widget,
				exe_callback = function(command)
					if not command:match(".*%..*") then
						command = "https://www.google.com/search?q=" .. command
					elseif not command:match("^https?://") then
						command = "https://" .. command
					end

					awful.spawn { "xdg-open", command }
				end,
			}
		end
	end)

	return desktop_wibox
end

return main
