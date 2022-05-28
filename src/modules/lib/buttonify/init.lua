local beautiful = require("beautiful")
local util      = require("modules.lib.util")

--[[ A small helper module that adds hover and click effects
to a widget, to make it "feel" more like a button. --]]
local function main(args)
	args = {
		widget                  = util.default(args.widget, args[1]), --- Allow to just write `buttonify { <your widget here> }`
		mouse_effects           = util.default(args.mouse_effects, true),
		button_color_hover      = util.default(args.button_color_hover,   beautiful.button_enter,   beautiful.accent_primary_darker),
		button_color_normal     = util.default(args.button_color_normal,  beautiful.button_normal,  beautiful.accent_primary_dark),
		button_color_press      = util.default(args.button_color_press,   beautiful.button_press,   beautiful.accent_primary_medium),
		button_color_release    = util.default(args.button_color_release, beautiful.button_release, beautiful.accent_primary_darker),
		-- Callbacks are functions that will be executed whenever the corresponding action is performed.
		button_callback_hover   = util.default(args.button_callback_hover,   nil),
		button_callback_normal  = util.default(args.button_callback_normal,  nil),
		button_callback_press   = util.default(args.button_callback_press,   nil),
		button_callback_release = util.default(args.button_callback_release, nil),
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
