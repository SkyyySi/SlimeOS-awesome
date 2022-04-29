local awful = require("awful")
local wibox     = require("wibox") ---@type wibox
local gears     = require("gears")
local beautiful = require("beautiful")
local buttonify = require("modules.lib.buttonify")

local function make_button(widget, args)
	args = {
		normal     = args.normal   or "#FF000060",
		hover      = args.hover    or "#FF0000B0",
		press      = args.press    or "#FF0000FF",
		release    = args.release  or args.normal or"#FF0000B0",
		callback   = args.callback or function() end,
		shape      = args.shape    or function(cr, w, h) gears.shape.circle(cr, w, h) end,
	}

	local new_widget = wibox.widget {
		widget,
		bg     = args.normal or "#FF0000B0",
		shape  = args.shape,
		widget = wibox.container.background,
	}

	buttonify {
		widget                  = new_widget,
		mouse_effects           = false,
		button_color_normal     = args.normal,
		button_color_hover      = args.hover,
		button_color_press      = args.press,
		button_color_release    = args.release,
		button_callback_release = args.callback,
	}

	return new_widget
end

local function main(args)
	client.connect_signal("request::titlebars", function(c)
		-- buttons for the titlebar
		local buttons = {
			awful.button({ }, 1, function()
				c:activate { context = "titlebar", action = "mouse_move"  }
			end),
			awful.button({ }, 3, function()
				c:activate { context = "titlebar", action = "mouse_resize"}
			end),
		}

		local titlebars = {}

		titlebars.top = awful.titlebar(c, {
			position = "top",
			height   = 16,
			bg       = gears.color.transparent,
		})
		titlebars.top.widget = {
			{
				{
					{
						{
							{
								awful.titlebar.widget.iconwidget(c),
								--make_button(awful.titlebar.widget.floatingbutton(c)),
								--make_button(awful.titlebar.widget.stickybutton(c)),
								--make_button(awful.titlebar.widget.ontopbutton(c)),
								make_button(awful.titlebar.widget.floatingbutton(c), {
									normal = "#00000000",
									hover  = "#2060C0",
									press  = "#3090FF",
								}),
								make_button(awful.titlebar.widget.stickybutton(c), {
									normal = "#00000000",
									hover  = "#2060C0",
									press  = "#3090FF",
								}),
								make_button(awful.titlebar.widget.ontopbutton(c), {
									normal = "#00000000",
									hover  = "#2060C0",
									press  = "#3090FF",
								}),
								layout = wibox.layout.fixed.horizontal,
							},
							margins = 2,
							widget = wibox.container.margin,
						},
						{
							{
								align  = "center",
								widget = awful.titlebar.widget.titlewidget(c),
							},
							buttons = buttons,
							layout  = wibox.layout.flex.horizontal,
						},
						{
							{
								--awful.titlebar.widget.minimizebutton(c),
								--awful.titlebar.widget.maximizedbutton(c),
								--awful.titlebar.widget.closebutton(c),
								make_button(awful.titlebar.widget.minimizebutton(c), {
									normal = "#00000000",
									hover  = "#2060C0",
									press  = "#3090FF",
								}),
								make_button(awful.titlebar.widget.maximizedbutton(c), {
									normal = "#00000000",
									hover  = "#2060C0",
									press  = "#3090FF",
								}),
								make_button(awful.titlebar.widget.closebutton(c), {
									normal = "#C01000",
									hover  = "#D83010",
									press  = "#F02010",
								}),
								layout = wibox.layout.fixed.horizontal(),
							},
							margins = 2,
							widget  = wibox.container.margin,
						},
						layout = wibox.layout.align.horizontal
					},
					bg     = beautiful.accent_bright,
					widget = wibox.container.background,
				},
				top    = 1,
				left   = 1,
				right  = 1,
				widget = wibox.container.margin,
			},
			bg     = beautiful.accent_dark,
			widget = wibox.container.background,
		}

		--c:connect_signal("property::geometry", function(c)
		--	titlebars.top.widget.bg = gears.color {
		--		type = "linear",
		--		from = { 0, 0 },
		--		to   = { c.width, 0},
		--		stops = {
		--			{ 0, beautiful.accent_primary_brighter },
		--			{ 1, beautiful.accent_primary_medium },
		--		}
		--	}
		--end)

		titlebars.bottom = awful.titlebar(c, {
			position = "bottom",
			size     = 2,
			bg       = gears.color.transparent,
		})
		titlebars.bottom.widget = wibox.widget {
			{
				{
					bg     = beautiful.accent_bright,
					widget = wibox.container.background,
				},
				bottom = 1,
				left   = 1,
				right  = 1,
				widget = wibox.container.margin,
			},
			bg     = beautiful.accent_dark,
			widget = wibox.container.background,
		}

		titlebars.left = awful.titlebar(c, {
			position = "left",
			size     = 2,
			bg       = gears.color.transparent,
		})
		titlebars.left.widget = wibox.widget {
			{
				{
					bg     = beautiful.accent_bright,
					widget = wibox.container.background,
				},
				left   = 1,
				widget = wibox.container.margin,
			},
			bg     = beautiful.accent_dark,
			widget = wibox.container.background,
		}

		titlebars.right = awful.titlebar(c, {
			position = "right",
			size     = 2,
			bg       = gears.color.transparent,
		})
		titlebars.right.widget = wibox.widget {
			{
				{
					bg     = beautiful.accent_bright,
					widget = wibox.container.background,
				},
				right  = 1,
				widget = wibox.container.margin,
			},
			bg     = beautiful.accent_dark,
			widget = wibox.container.background,
		}
	end)
end

return main
