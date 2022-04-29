#!/usr/bin/env lua
local naughty   = require("naughty")
local beautiful = require("beautiful")

--[[ A small helper module that adds hover and click effects
to a widget, to make it "feel" more like a button. --]]
local function main(args)
	args = {
		widget                  = args.widget,
		mouse_effects           = not (not args.mouse_effects) or false,
		button_color_hover      = args.button_color_hover      or beautiful.button_enter,
		button_color_normal     = args.button_color_normal     or beautiful.button_normal,
		button_color_press      = args.button_color_press      or beautiful.button_press,
		button_color_release    = args.button_color_release    or beautiful.button_release,
		-- Callbacks are functions that will be executed whenever the corresponding action is performed.
		button_callback_hover   = args.button_callback_hover   or nil,
		button_callback_normal  = args.button_callback_normal  or nil,
		button_callback_press   = args.button_callback_press   or nil,
		button_callback_release = args.button_callback_release or nil,
	}

	args.widget:set_bg(args.button_color_normal)

	local old_cursor, old_wibox
	args.widget:connect_signal("mouse::enter", function(c)
		c:set_bg(args.button_color_hover)
		if args.mouse_effects then
			local wb = mouse.current_wibox
			old_cursor, old_wibox = wb.cursor, wb
			wb.cursor = "hand1"
		end

		if type(args.button_callback_hover) == "function" then
			args.button_callback_hover(c)
		end
	end)

	args.widget:connect_signal("mouse::leave", function(c)
		c:set_bg(args.button_color_normal)
		if args.mouse_effects and old_wibox then
			old_wibox.cursor = old_cursor
			old_wibox = nil
		end

		if type(args.button_callback_normal) == "function" then
			args.button_callback_normal(c)
		end
	end)

	args.widget:connect_signal("button::press", function(c,_,_,button)
		c:set_bg(args.button_color_press)

		if type(args.button_callback_press) == "function" then
			args.button_callback_press(c, button)
		end
	end)

	args.widget:connect_signal("button::release", function(c,_,_,button)
		c:set_bg(args.button_color_release)

		if type(args.button_callback_release) == "function" then
			args.button_callback_release(c, button)
		end
	end)
end

return main
