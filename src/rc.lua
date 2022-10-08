pcall(require, "luarocks.loader") -- Enable LuaRocks package manager support

-- Error handling. Should be loaded as soon as possible to be able
-- to properly catch all errors.
local error_handling = require("modules.lib.error_handling")
error_handling {}

-- Standard awesome libraries
local gears     = require("gears")
local awful     = require("awful")
local wibox     = require("wibox") ---@type wibox Widget and layout library
local beautiful = require("beautiful") -- Theme handling library
local naughty   = require("naughty") -- Notification library
local ruled     = require("ruled") -- Declarative object management
local menubar   = require("menubar")

--- Print a message using naughty.notification
---
--- Please only use this for debugging.
---@param text string The text that should be printed
---@param timeout? number The number of seconds to wait before auto closing the notification (default: `5`; `0` means no timeout)
function notify(text, timeout)
	timeout = timeout or 5

	naughty.notification {
		message = tostring(text),
		timeout = timeout,
	}
end

--- Print a formatted message using naughty.notification and string.format.
---
--- Please only use this for debugging.
---@vararg string The format string and text that should be printed
function notifyf(...)
	naughty.notification {
		message = string.format(...),
		timeout = 5,
	}
end

require("modules.lib.bindings")

local util = require("modules.lib.util")

local config_auto_reload = require("modules.lib.config_auto_reload")
config_auto_reload()

local titlebars = require("modules.widgets.titlebars")
titlebars()

local kill_all_but_one = require("modules.lib.kill_all_but_one")
kill_all_but_one {
	pattern = "^pasystray$"
}

local buttonify = require("modules.lib.buttonify")
local desktop_icons = require("modules.widgets.desktop_icons")
--local async = require("modules.lib.async")

-- {{{ Variable definitions
-- Themes define colors, icons, font and wallpapers.
local globals = require("modules.lib.globals")

util.add_package_path(globals.config_dir .. "modules")
util.add_package_path(globals.config_dir .. "modules/external")

--local autostart = require("modules.lib.autostart")
----[ [
--autostart {
--	apps = {
--		{ "picom", "--experimental-backends", "--config", globals.config_dir.."/config/picom/picom.conf" },
--	}
--}

local username = os.getenv("USER")
local spawn_once_cmd = ([[pgrep -fU '%s' -- ']]):format(username) .. "%s'"
local function spawn_once(cmd)
	awful.spawn.easy_async_with_shell(spawn_once_cmd:format(cmd[1]), function(stdout, stderr, reason, exit_code)
		if exit_code > 0 then
			awful.spawn(cmd)
		end
	end)
end

spawn_once { "picom",--[[ "--experimental-backends",]] "--config", globals.config_dir.."/config/picom/picom.conf" }
spawn_once { "pasystray" }
spawn_once { "kdeconnect-indicator" }
spawn_once { "flameshot" }
spawn_once { os.getenv("HOME").."/.screenlayout/layout.sh" }
--]]

local theme_dir = gears.filesystem.get_configuration_dir().."themes/"..globals.theme
beautiful.init(theme_dir.."/theme.lua")

local bling = require("modules.external.bling") -- needs to be loaded after running beautiful.init
bling.module.flash_focus.enable()

local playerctl_cli = require("modules.lib.playerctl_cli")
playerctl_cli()

local pulseaudio = require("modules.lib.pulseaudio")
pulseaudio()

local media_info = require("modules.widgets.media_info")
--local desktop_search = require("modules.widgets.desktop_search")
local better_menu = require("modules.widgets.better_menu")
local global_menu_bar = require("modules.widgets.global_menu_bar")
local dock = require("modules.widgets.dock")
--local category_launcher = require("modules.widgets.category_launcher")
local tasklist = require("modules.widgets.tasklist")
-- }}}

-- {{{ Menu
local awesome_xdg_menu = require("modules.widgets.awesome_xdg_menu")
local menus = awesome_xdg_menu()

local main_menu
local all_menus = {}
awesome.connect_signal("slimeos::menu_is_ready", function(menu)
	main_menu = menu.main

	for k, v in pairs(menu) do
		all_menus[k] = v
	end
end)

--local freedesktop = require("modules.external.awesome-freedesktop")

--main_menu = awesome_menu()
--main_menu = awful.menu({ "restart", awesome.restart })

menubar.utils.terminal = globals.terminal
-- }}}

-- {{{ Tag
-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal("request::default_layouts", function()
	awful.layout.append_default_layouts({
		awful.layout.suit.spiral,
		awful.layout.suit.floating,
		awful.layout.suit.tile,
		awful.layout.suit.fair,

--		awful.layout.suit.floating,
--		awful.layout.suit.tile,
--		awful.layout.suit.tile.left,
--		awful.layout.suit.tile.bottom,
--		awful.layout.suit.tile.top,
--		awful.layout.suit.fair,
--		awful.layout.suit.fair.horizontal,
--		awful.layout.suit.spiral,
--		awful.layout.suit.spiral.dwindle,
--		awful.layout.suit.max,
--		awful.layout.suit.max.fullscreen,
--		awful.layout.suit.magnifier,
--		awful.layout.suit.corner.nw,
	})
end)
-- }}}


local function right_click_menu_field()
	local new_widget = wibox.widget {
		{
			markup = [[  Hello, world!  ]],
			widget = wibox.widget.textbox,
		},
		bg = "#FF0000",
		widget = wibox.container.background,
	}

	local new_widget_container = wibox.widget {
		nil,
		new_widget,
		nil,
		layout = wibox.layout.align.horizontal,
	}

	new_widget:connect_signal("mouse::enter", function(w)
		w:set_bg("#FF0040")
	end)

	new_widget:connect_signal("mouse::leave", function(w)
		w:set_bg("#FF0000")
	end)

	new_widget:connect_signal("button::press", function(w)
		w:set_bg("#FF0080")
	end)

	new_widget:connect_signal("button::release", function(w)
		w:set_bg("#FF0040")
	end)

	return new_widget_container
end

-- {{{ Wibar
local absolute_center = require("modules.lib.absolute_center")

local function popup_menu_pro(args)
	args = args or {
		item_widget     = args.item_widget     or function(w) return wibox.widget(w) end,
		widget_template = args.widget_template or function(w) return wibox.widget(w) end,
		items           = args.items, -- a table holding wibox.widget instances
	}

	local items = {}

	for i,v in pairs(items) do
		items[i] = wibox.widget { -- for each individual item
			args.item_widget(v)
		}
	end

	local widget_template = wibox.widget { -- sorrounds all items
	}

	local menu_popup = awful.popup {}

	return menu_popup
end

screen.connect_signal("request::desktop_decoration", function(s)
	-- Disables the wibar on the primary screen
	--if s == screen.primary then return end

	-- Each screen has its own tag table.
	awful.tag({ " 一 ", " 二 ", " 三 ", " 四 ", " 五 ", " 六 ", " 七 ", " 八 ", " 九 ", " 十 " }, s, awful.layout.layouts[1])

	-- Wiboxes, desktop widgets, etc.
	s.boxes = {}

	-- Create the wibar
	s.panels = {}

	s.panels.primary = awful.wibar {
		type     = "dock",
		position = "bottom",
		height   = util.scale(38),
		screen   = s,
		bg       = gears.color.transparent,
	}

	local corner_radius = s.panels.primary.height / 2
	local panel_shape
	if s.panels.primary.position == "top" then
		panel_shape = function(cr,w,h) gears.shape.partially_rounded_rect(cr,w,h, false, false, true, true, corner_radius) end
	elseif s.panels.primary.position == "bottom" then
		panel_shape = function(cr,w,h) gears.shape.partially_rounded_rect(cr,w,h, true, true, false, false, corner_radius) end
	elseif s.panels.primary.position == "left" then
		panel_shape = function(cr,w,h) gears.shape.partially_rounded_rect(cr,w,h, false, true, true, false, corner_radius) end
	elseif s.panels.primary.position == "right" then
		panel_shape = function(cr,w,h) gears.shape.partially_rounded_rect(cr,w,h, true, false, false, true, corner_radius) end
	end
	s.panels.primary.shape = panel_shape

	--[ [
	s.boxes.desktop_clock = wibox {
		width   = 200,
		height  = 100,
		visible = true,
		below   = true,
		type    = "desktop",
		screen  = s,
		bg      = gears.color.transparent,
	}

	awful.placement.top(s.boxes.desktop_clock, { margins = { top = util.scale(100) } })

	s.boxes.desktop_clock.widget = {
		{
			font    = "Source Sans Pro, Bold "..tostring(math.floor(util.scale(24))),
			align   = "center",
			valign  = "top",
			format  = "%T",
			refresh = 1,
			widget  = wibox.widget.textclock,
		},
		{
			font    = "Source Sans Pro, "..tostring(math.floor(util.scale(16))),
			align   = "center",
			valign  = "top",
			format  = "%A, %F",
			refresh = 1,
			widget  = wibox.widget.textclock,
		},
		layout = wibox.layout.fixed.vertical,
	}
	--]]

	s.widgets = {}

	-- Create a promptbox for each screen
	s.widgets.promptbox = awful.widget.prompt()

	-- Attatch a layoutlist to the layoutbox
	s.boxes.layoutlist = awful.popup {
		widget = awful.widget.layoutlist {
			screen      = s,
			base_layout = wibox.layout.flex.vertical
		},
		maximum_height = #awful.layout.layouts * util.scale(24),
		minimum_height = #awful.layout.layouts * util.scale(24),
		screen         = s,
		ontop          = true,
		visible        = false,
	}

	awful.placement.bottom_right(s.boxes.layoutlist, { honor_workarea = true, margins = util.scale(5) })

	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.widgets.layoutbox = wibox.widget {
		{
			awful.widget.layoutbox.new {
				screen = s
			},
			top    = util.scale(4),
			bottom = util.scale(4),
			left   = util.scale(8),
			right  = util.scale(8),
			widget = wibox.container.margin,
		},
		widget = wibox.container.background,
	}

	buttonify {
		s.widgets.layoutbox,
		button_callback_release = function(w, b)
			if b == 1 then
				awful.layout.inc(1)
			elseif b == 3 then
				local vis = s.boxes.layoutlist.visible ---@type boolean
				s.boxes.layoutlist.visible = not vis
				awful.placement.bottom_right(s.boxes.layoutlist, { honor_workarea = true, margins = util.scale(5) })
			elseif b == 4 then
				awful.layout.inc(1)
			elseif b == 5 then
				awful.layout.inc(-1)
			end
		end,
	}

	-- Create a taglist widget
	local taglist_old_cursor, taglist_old_wibox
	s.widgets.taglist = wibox.widget {
		{
			awful.widget.taglist {
				screen  = s,
				filter  = awful.widget.taglist.filter.all,
				buttons = {
					awful.button({ }, 1, function(t) t:view_only() end),
					awful.button({ globals.modkey }, 1, function(t)
						if client.focus then
							client.focus:move_to_tag(t)
						end
					end),
					awful.button({ }, 3, awful.tag.viewtoggle),
					awful.button({ globals.modkey }, 3, function(t)
						if client.focus then
							client.focus:toggle_tag(t)
						end
					end),
					awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
					awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end),
				},
				widget_template = {
					{
						{
							id     = "index_role",
							widget = wibox.widget.textbox,
						},
						{
							id     = "icon_role",
							widget = wibox.widget.imagebox,
						},
						{
							id     = "text_role",
							widget = wibox.widget.textbox,
						},
						layout = wibox.layout.fixed.horizontal,
					},
					id = "background_role",
					create_callback = function(self, c3, index, objects)
						self:connect_signal("mouse::enter", function()
							if self.bg ~= beautiful.button_hover then
								self.backup     = self.bg
								self.has_backup = true
							end

							self.bg = beautiful.button_hover

							local wb = util.default(mouse.current_wibox, {})
							taglist_old_cursor, taglist_old_wibox = wb.cursor, wb
							wb.cursor = "hand1"
						end)
						self:connect_signal("mouse::leave", function()
							if self.has_backup then
								self.bg = self.backup
							end

							if taglist_old_wibox then
								taglist_old_wibox.cursor = taglist_old_cursor
								taglist_old_wibox = nil
							end
						end)
					end,
					widget = wibox.container.background,
				},
			},
			bg                 = "#FFFFFF10",
			shape              = function(cr, w, h) gears.shape.rounded_bar(cr, w, h) end,
			shape_border_color = "#FFFFFF20",
			shape_border_width = util.scale(1),
			widget             = wibox.container.background,
		},
		margins = util.scale(2),
		widget  = wibox.container.margin,
	}

	-- Create a tasklist widget
	s.widgets.tasklist = tasklist {
		screen = s,
	}
	--[[
	s.widgets.tasklist = awful.widget.tasklist {
		screen  = s,
		filter  = awful.widget.tasklist.filter.currenttags,
		buttons = {
			awful.button({ }, 1, function (c)
				c:activate { context = "tasklist", action = "toggle_minimization" }
			end),
			awful.button({ }, 3, function() awful.menu.client_list { theme = { width = 250 } } end),
			awful.button({ }, 4, function() awful.client.focus.byidx(-1) end),
			awful.button({ }, 5, function() awful.client.focus.byidx( 1) end),
		},
		layout = {
			spacing = util.scale(4),
			spacing_widget = {
				valign = "center",
				halign = "center",
				widget = wibox.container.place,
			},
			layout  = wibox.layout.flex.horizontal,
		},
		widget_template = {
			{
				{
					{
						bg                 = "#F8F8F2",
						shape              = gears.shape.circle,
						shape_border_width = util.scale(1),
						shape_border_color = "#00000000",
						widget             = wibox.container.background,
					},
					{
						id         = "icon_role",
						clip_shape = gears.shape.circle,
						widget     = wibox.widget.imagebox,
					},
					layout = wibox.layout.stack,
				},
				margins = util.scale(4),
				widget  = wibox.container.margin,
			},
			bg = {
				type  = "radial",
				from  = { util.scale(19), util.scale(21), util.scale(12) },
				to    = { util.scale(19), util.scale(21), util.scale(16) },
				stops = { { 0, "#000000A0" }, { 1/3, "#00000070" }, { 2/3, "#00000030" }, { 1, "#0000" } }
			  },
			widget = wibox.container.background,
		},
	}
	--]]

	-- Keyboard map indicator and switcher
	--s.widgets.keyboardlayout = awful.widget.keyboardlayout()
	s.widgets.keyboardlayout = require("modules.widgets.keyboard_layout_switcher") {
		--
	}

	screen.connect_signal("request::wallpaper", function(s)
		--[[
		-- Wallpaper
		if beautiful.wallpaper then
			local wp = beautiful.wallpaper

			-- If wallpaper is a function, call it with the screen
			if type(wp) == "function" then
				return wp(s)
			end

			--gears.wallpaper.maximized(wp, s, true)

			local margin = util.scale(150)

			awful.wallpaper {
				screen = s,
				widget = {
					{
						{
							image      = wp,
							resize     = true,
							halign     = "center",
							valign     = "center",
							clip_shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, util.scale(60)) end,
							opacity    = 0.55,
							widget     = wibox.widget.imagebox,
						},
						margins = margin,
						widget  = wibox.container.margin,
					},
					bg = gears.color {
						type  = "linear",
						from  = { 0, 0 },
						to    = { 0, s.geometry.height },
						stops = { { 0, "#666DCC" }, { 1, "#66A0CC" } },
					},
					widget = wibox.container.background,
				}
			}
		end
		--]]
		awful.spawn { "nitrogen", "--restore" }
	end)

	--[[
	s.widgets.launcher = awful.widget.launcher {
		image = beautiful.awesome_icon,
		menu  = main_menu,
	}
	--]]

	local arc = wibox.widget.base.make_widget()

	arc.brightness = 0.1
	function arc:set_brightness(brightness)
		self.brightness = brightness
		self:emit_signal("widget::redraw_needed")
	end

	function arc:fade_to(new_brightness)
		if self.brightness == new_brightness then
			return
		end

		local step = 0.01
		local update
		if new_brightness <= self.brightness then
			update = function()
				if new_brightness < self.brightness then
					self:set_brightness(self.brightness - step)
					return true
				end

				return false
			end
		else
			update = function()
				if new_brightness > self.brightness then
					self:set_brightness(self.brightness + step)
					return true
				end

				return false
			end
		end

		gears.timer.start_new(0.002, function()
			return update()
		end)
	end

	local function dec2hex(n) return string.format("%x", n * 255) end
	arc.draw = function(widget, context, cr, width, height)
		--notify("drawing, brightness is "..tonumber(arc_brightness))
		local br_circ = dec2hex(arc.brightness)
		local br_arc = "ff"
		if arc.brightness * 1.5 < 255 then
			br_arc = dec2hex(arc.brightness * 2)
		end

		-- surrounding circle
		cr:set_source(gears.color("#FFFFFF"..br_circ))
		cr:arc(width/2, height/2, height/2, 0, math.pi*2)
		cr:fill()

		-- inner arc
		cr:set_source(gears.color("#FFFFFF"..br_arc))
		cr:set_line_width(height/10)
		cr:arc(width/2, height/2, height/3.5, 0, math.pi*2)
		cr:stroke()

		-- small central circle
		cr:set_source(gears.color("#FFFFFF"..br_arc))
		cr:arc(width/2, height/2, height/9, 0, math.pi*2)
		cr:fill()
	end

	s.widgets.launcher = wibox.widget {
		{
			{
				{
					forced_width = s.panels.primary.height,
					widget = arc,
				},
				margins = util.scale(4),
				widget = wibox.container.margin,
			},
			layout = wibox.layout.fixed.horizontal,
		},
		bg = gears.color.transparent,
		widget = wibox.container.background,
	}

	local menu_holder = {}
	awesome.connect_signal("slimeos::menu_is_ready", function(menu)
		menu_holder.menus = menus

		-- Create a launcher. Since it is created asynchronously and thus does not
		-- anything, it doesn't need to be assinged to a variable.
		--category_launcher {
		--	screen = s,
		--	menus  = menus,
		--}

		buttonify {
			widget = s.widgets.launcher,
			button_color_hover      = "",
			button_color_normal     = "",
			button_color_press      = "",
			button_color_release    = "",
			button_callback_hover   = function(w, b) arc:fade_to(0.3) end,
			button_callback_normal  = function(w, b) arc:fade_to(0.1) end,
			button_callback_press   = function(w, b) arc:fade_to(0.5) end,
			button_callback_release = function(w, b)
				arc:fade_to(0.1)
				local width  = mouse.current_widget_geometry.width  + beautiful.useless_gap
				local height = mouse.current_widget_geometry.height + beautiful.useless_gap

				if b == 1 then
					--awful.spawn({
					--	"rofi", "-config", globals.config_dir.."/config/rofi/config.rasi",
					--	"-xoffset", tostring(beautiful.useless_gap),
					--	"-yoffset", tostring(-(height)),
					--	"-show", "drun",
					--})
					--awesome.emit_signal("slimeos::toggle_launcher", s)
					menu.main:toggle()
				elseif b == 2 then
					menu.settings:toggle()
				elseif b == 3 then
					menu.tools:toggle()
				end
			end
		}
	end)

	-- Create a textclock widget
	s.widgets.textclock_clock = wibox.widget {
		format = "%H:%M",
		align = "center",
		font = "Roboto, Semibold "..beautiful.font_size,
		forced_width = util.scale(45),
		widget = wibox.widget.textclock,
	}

	s.widgets.textclock = wibox.widget {
		{
			s.widgets.textclock_clock,
			left = util.scale(12),
			right = util.scale(12),
			widget = wibox.container.margin,
		},
		widget = wibox.container.background,
	}

	buttonify {
		s.widgets.textclock,
	}

	s.widgets.month_calendar = awful.widget.calendar_popup.month {
		style_header = {
			shape = function(cr,w,h) gears.shape.rounded_rect(cr,w,h, util.scale(8)) end,
			markup = function(text)
				return util.sstrfmt([[<i> ${text} </i>]], {text = text})
			end,
			border_width = util.scale(1),
			border_color = beautiful.accent_primary_bright,
			bg_color = beautiful.accent_primary_medium,
		},
		screen = s,
	}

	s.boxes.control_center = require("modules.widgets.control_center") {
		screen = s,
	}

	s.widgets.textclock:connect_signal("button::release", function()
		s.boxes.control_center:toggle()
		awful.placement.bottom_right(s.boxes.control_center, {
			honor_workarea = true,
			margins = util.scale(10),
		})

		--s.widgets.month_calendar:toggle()
		--awful.placement.bottom_right(s.widgets.month_calendar, {
		--	honor_workarea = true,
		--})
	end)

	s.widgets.systray = wibox.widget {}
	if s == screen.primary then
		s.widgets.systray = wibox.widget {
			wibox.widget.systray(false),
			top = util.scale(2),
			bottom = util.scale(2),
			left = util.scale(16),
			right = util.scale(2),
			widget = wibox.container.margin,
		}
	end

	s.widgets.media_info = wibox.widget {
		widget = media_info,
	}

	-- Visually merge some components into nicer-looking "blocks"
	s.panel_blocks = {}

	s.panel_blocks.left = wibox.widget {
		s.widgets.launcher,
		s.widgets.taglist,
		s.widgets.promptbox,
		layout = wibox.layout.fixed.horizontal,
	}

	s.widgets.dock = dock()

	local placement = (awful.placement.align)
	placement(s.mydock, {
		position = "top",
		honor_workarea = true,
	})

	s.panel_blocks.center = wibox.widget {
		s.widgets.dock,
		wibox.widget.separator {
			orientation = "vertical",
			span_ratio = 0.8,
			forced_width = util.scale(5),
		},
		s.widgets.tasklist,
		layout = wibox.layout.fixed.horizontal,
	}

	--awesome.connect_signal("slimeos::dock::favorites_update", function(favorites)
	--	s.panel_blocks.center:emit_signal("widget::redraw_needed")
	--end)

	s.panel_blocks.right = wibox.widget {
		beautiful.color.make_dynamic(wibox.widget {
			{
				--s.widgets.keyboardlayout,
				--wibox.widget.systray(),
				s.widgets.systray,
				s.widgets.textclock,
				s.widgets.layoutbox,
				layout = wibox.layout.fixed.horizontal,
			},
			bg = "#FFFFFF10",
			shape = function(cr, w, h) gears.shape.rounded_bar(cr, w, h) end,
			shape_border_color = "#FFFFFF20",
			shape_border_width = util.scale(1),
			widget = wibox.container.background,
		}, {
			bg = "bg",
			fg = "fg",
			shape_border_color = "bc"
		}, {
			dark = {
				bg = "#FFFFFF10",
				fg = beautiful.get_dynamic_color("fg_normal"),
				bc = "#FFFFFF20",
			},
			light = {
				bg = "#00000030",
				fg = beautiful.get_dynamic_color("fg_normal"),
				bc = "#00000060",
			},
		}),
		margins = util.scale(2),
		widget = wibox.container.margin,
	}

	-- Add widgets to the wibox
	s.panels.primary.widget = beautiful.color.make_dynamic(wibox.widget {
		absolute_center(
			{
				s.panel_blocks.left,
				layout = wibox.layout.fixed.horizontal,
			},
			{
				s.panel_blocks.center,
				layout = wibox.layout.fixed.horizontal,
			},
			{
				--s.widgets.media_info,
				s.panel_blocks.right,
				layout = wibox.layout.fixed.horizontal,
			},
			{
				awful.button({}, 3, function()
					--notify(menu_holder.menus.tools)
					--menu_holder.menus.tools:show()
				end)
			}
		),
		bg = beautiful.bg_normal,
		shape = panel_shape,
		--shape_border_width = util.scale(1),
		--shape_border_color = beautiful.accent_secondary_medium,
		widget = wibox.container.background,
	})

	local maximized_clients = 0
	client.connect_signal("property::maximized", function(c)
		if c.screen == s then
			if c.maximized then
				maximized_clients = maximized_clients + 1
			else
				maximized_clients = maximized_clients - 1
			end
		end

		if maximized_clients > 0 then
			s.panels.primary.shape = gears.shape.rectangle
			s.panels.primary.widget.shape = gears.shape.rectangle
		else
			s.panels.primary.shape = panel_shape
			s.panels.primary.widget.shape = panel_shape
		end
	end)

	--[[ ] ]
	s.panels.primary.widget = wibox.widget {
		{
			--{
				s.widgets.launcher,
				s.widgets.taglist,
				s.widgets.promptbox,
				layout = wibox.layout.fixed.horizontal,
			--},
			--halign = "left",
			--layout = wibox.container.place,
		},
		{
			{
				s.widgets.tasklist,
				layout = wibox.layout.fixed.horizontal,
			},
			halign = "center",
			layout = wibox.container.place,
		},
		{
			--{
				s.widgets.keyboardlayout,
				wibox.widget.systray(),
				s.widgets.textclock,
				s.widgets.layoutbox,
				layout = wibox.layout.fixed.horizontal,
			--},
			--halign = "right",
			--layout = wibox.container.place,
		},
		layout = wibox.layout.fixed.horizontal,
	}
	--]]

	--[[
	s.panels.side_dock = awful.wibar {
		bg       = gears.color.transparent,
		width    = 48,
		screen   = s,
		position = "left",
	}

	s.panels.side_dock.widget = wibox.widget {
		nil,
		{
			{
				{
					{
						markup = "  <b>Hello, world!</b>  ",
						widget = wibox.widget.textbox,
					},
					direction = "east",
					layout    = wibox.container.rotate,
				},
				bg     = "#FF0000",
				widget = wibox.container.background,
			},
			layout = wibox.layout.fixed.vertical,
		},
		nil,
		expand = "outside",
		layout = wibox.layout.align.vertical,
	}
	--]]

	s.desktop_icons = desktop_icons {
		screen = s,
	}

	--local gmb = global_menu_bar {
	--	screen = s,
	--}

	--gmb:clear()
	--gmb:add(gmb.create_button {
	--	label = "File",
	--	onclick = function(self)
	--		notify("You clicked 'File'.")
	--	end
	--})
	--gmb:add(gmb.create_button {
	--	label = "Edit",
	--	onclick = function(self)
	--		notify("You clicked 'Edit'.")
	--	end
	--})

	--s.boxes.desktop_search = desktop_search {
	--	screen = s,
	--}

	-- Add desktop icons
	--[[freedesktop.desktop.add_icons {
		screen     = s, ---@type screen Screen where to show icons
		dir        = util.default(os.getenv("XDG_DESKTOP_DIR"), "~/Desktop"), ---@type string Directory to lookup
		showlabels = true, ---@type boolean Define whether to show labels or not
		open_with  = "xdg_open", ---@type string Define file manager to use
		baseicons = {
			{
				label   = "This PC",
				icon    = "computer",
				onclick = "computer://"
			},
			{
				label   = "Home",
				icon    = "user-home",
				onclick = os.getenv("HOME")
			},
			{
				label   = "Trash",
				icon    = "user-trash",
				onclick = "trash://"
			}
		},
		iconsize = {
			width  = 48,
			height = 48,
		},
		labelsize = {
			width  = 140,
			height = 20,
		},
		margin = {
			x = 20,
			y = 20,
		},
	}--]]

	--[[ local W = {
		wibox.widget {
			text   = "CORRECT TEXT!",
			widget = wibox.widget.textbox,
		},
		mt = {
			bg     = "#FF0000",
			widget = wibox.container.background,
		},
	}
	W.mt.__index = W.mt
	setmetatable(W, W.mt)
	local B = wibox {
		x       = 30,
		y       = 30,
		width   = 200,
		height  = 100,
		visible = true,
		ontop   = true,
		screen  = s,
		widget  = W,
	}

	local str = ""
	for k, v in ipairs(W) do
		str = ("%s[%s] = %s,\n"):format(str, k, v)
	end
	notify(str) ]]
end)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function()
	-- All clients will match this rule.
	ruled.client.append_rule {
		id         = "global",
		rule       = { },
		properties = {
			focus     = awful.client.focus.filter,
			raise     = true,
			screen    = awful.screen.preferred,
			placement = awful.placement.no_overlap+awful.placement.no_offscreen
		}
	}

	-- Floating clients.
	ruled.client.append_rule {
		id       = "floating",
		rule_any = {
			instance = { "copyq", "pinentry" },
			class    = {
				"Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv",
				"Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer"
			},
			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name    = {
				"Event Tester",  -- xev.
			},
			role    = {
				"AlarmWindow",    -- Thunderbird's calendar.
				"ConfigManager",  -- Thunderbird's about:config.
				"pop-up",         -- e.g. Google Chrome's (detached) Developer Tools.
			}
		},
		properties = { floating = true }
	}

	-- Add titlebars to normal clients and dialogs
	ruled.client.append_rule {
		id         = "titlebars",
		rule_any   = { type = { "normal", "dialog" } },
		properties = { titlebars_enabled = true      }
	}

	-- Force XAVA (X11 Audio Visualizer for Alsa) to behave nicely
	ruled.client.append_rule {
		rule       = { class = { "XAVA" } },
		properties = {
			sticky = true
		}
	}

	-- Set Firefox to always map on the tag named "2" on screen 1.
	-- ruled.client.append_rule {
	--     rule       = { class = "Firefox"     },
	--     properties = { screen = 1, tag = "2" }
	-- }

	ruled.client.append_rule {
		rule = {
			class = {
				"Xfce4-panel",
			},
		},
		properties = {
			focusable = false,
			sticky = true,
			above = true,
		}
	}
end)

-- }}}

-- {{{ Titlebars
-- Add a titlebar if titlebars_enabled is set to true in the rules.
--[[ ] ]
util.add_package_path(globals.config_dir .. "modules")
util.add_package_path(globals.config_dir .. "modules/external")
local nice = require("modules.external.nice")
nice {
	titlebar_height          = 38,
	titlebar_radius          = 9,
	titlebar_color           = "#1e1e24",
	titlebar_padding_left    = 0,
	titlebar_padding_right   = 0,
	titlebar_font            = "Source Sans Pro, Bold 14",
	titlebar_items           = {
		--left   = {"close", "minimize", "maximize"},
		--middle = "title",
		--right  = {"sticky", "ontop", "floating"},
		left   = {"floating", "sticky", "ontop"},
		middle = "title",
		right  = {"minimize", "maximize", "close"},
	},
	win_shade_enabled        = true,
	no_titlebar_maximized    = false,
	mb_move                  = nice.MB_LEFT,
	mb_contextmenu           = nice.MB_MIDDLE,
	mb_resize                = nice.MB_RIGHT,
	mb_win_shade_rollup      = nice.MB_SCROLL_UP,
	mb_win_shade_rolldown    = nice.MB_SCROLL_DOWN,
	button_size              = 16,
	button_margin_horizontal = 3,
	button_margin_vertical   = nil,
	button_margin_top        = nil,
	button_margin_bottom     = nil,
	button_margin_left       = nil,
	button_margin_right      = nil,
	tooltips_enabled         = nil,
	close_color              = beautiful.accent_tertiary_darker,
	minimize_color           = beautiful.accent_tertiary_brighter,
	maximize_color           = beautiful.accent_tertiary_medium,
	floating_color           = beautiful.accent_primary_darker,
	ontop_color              = beautiful.accent_primary_brighter,
	sticky_color             = beautiful.accent_primary_medium,
	context_menu_theme       = {
		bg_focus     = beautiful.accent_primary_bright,
		bg_normal    = beautiful.accent_dark,
		border_color = "#00000000",
		border_width = 0,
		fg_focus     = beautiful.accent_dark,
		fg_normal    = beautiful.accent_bright,
		font         = "Source Sans Pro, 14",
		height       = 27.5,
		width        = 250,
	},
	tooltip_messages         = {
		close             = "close",
		minimize          = "minimize",
		maximize_active   = "unmaximize",
		maximize_inactive = "maximize",
		floating_active   = "enable tiling mode",
		floating_inactive = "enable floating mode",
		ontop_active      = "don't keep above other windows",
		ontop_inactive    = "keep above other windows",
		sticky_active     = "disable sticky mode",
		sticky_inactive   = "enable sticky mode",
	}
}
--]]

--[[ ] ]
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

	c:connect_signal("property::geometry", function(_)
		local bg = gears.color {
			type = "linear",
			from = { 0, 0 },
			to   = { c.width, c.height},
			stops = {
				{ 0, beautiful.accent_primary_brighter },
				{ 1, beautiful.accent_primary_medium },
			}
		}

		titlebars.top.widget.widget.widget.bg    = bg
		titlebars.bottom.widget.widget.widget.bg = bg
		titlebars.left.widget.widget.widget.bg   = bg
		titlebars.right.widget.widget.widget.bg  = bg
	end)
end)
--]]
-- {{{ Notifications

ruled.notification.connect_signal('request::rules', function()
	-- All notifications will match this rule.
	ruled.notification.append_rule {
		rule       = { },
		properties = {
			screen           = awful.screen.preferred,
			implicit_timeout = 5,
		}
	}
end)

naughty.connect_signal("request::display", function(n)
	naughty.layout.box { notification = n }
end)

-- }}}

-- -- Center all windows on spawn.
-- -- Please note that this will also re-center all clients when restarting awesome in-place.
-- client.connect_signal("manage", function(c)
-- 	c.x = c.screen.geometry.width / 2 - c.width / 2
-- 	c.y = c.screen.geometry.height / 2 - c.height / 2
-- 	if not c.icon then
-- 		notify(string.format("Client '%s' does not appear to have an icon", c.name))
-- 		awful.spawn.easy_async_with_shell([[]])
-- 	end
-- 	--c.shape = function(cr, w, h)
-- 	--	gears.shape.rounded_rect(cr, w, h, 8)
-- 	--end
-- end)

_PLASMA_PANEL_OFFSET_X = -1920
client.connect_signal("manage", function(c)
	if c.class == "Xfce4-panel" and c.type == "dock" then
		--local sh = c.size_hints
		--notify(util.table_to_string(sh), 0)
		c.y = 0
		--c.focusable = false
		--c.sticky = true
		--c.above = true
		c.sticky = true
		c.focusable = false
	end

	if c.class == "plasmashell" then
		c.floating = true
		if c.type == "desktop" then
			--c.sticky = true
			--c.below = true
			--c.focusable = false
			--c.width = 600
			--c.height = 600
			--c.floating = true
			c:kill()
		elseif c.type == "dock" then
			_PLASMA_PANEL_OFFSET_X = _PLASMA_PANEL_OFFSET_X + 1920
			c.sticky = true
			c.focusable = false
			c.x = c.screen.geometry.x + _PLASMA_PANEL_OFFSET_X
			c.y = c.screen.geometry.y
		end
	end

	if c.class == "firefox" then
		if c.role == "PictureInPicture" then
			c.border_width = 0
			c.sticky = true
			c.ontop = true
			c.focusable = false
		end
	end

	if c.type == "normal" then
		c.shape = function(cr, w, h)
			gears.shape.rounded_rect(cr, w, h, util.scale(20))
		end
	end

	--c.x      = sh.program_position.x
	--c.y      = sh.program_position.y
	--c.width  = sh.program_size.width
	--c.height = sh.program_size.height
end)

client.connect_signal("property::fullscreen", function(c)
	if c.fullscreen then
		c.shape = gears.shape.rectangle
	else
		if c.type == "normal" then
			c.shape = function(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, util.scale(20))
			end
		end
	end
end)

client.connect_signal("property::ontop", function(c)
	if c.ontop then
		c.border_color = beautiful.color.current.orange
	else
		c.border_color = nil
	end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	if c.focusable ~= false then
		client.focus = c
	end

	c:activate {
		context = "mouse_enter",
		raise   = false,
	}
end)

--[[
do
	local rasti_launcher = require("modules.widgets.rasti_launcher")
	local menubar_utils = require("modules.widgets.dock.menubar_utils")
	local wibox_layout_overflow = require("wibox_layout_overflow")

	local function create_new_grid_item(app, args)
		args = util.default(args, {})
		args = {
			width  = util.default(args.width,  util.scale(140)), ---@type number
			height = util.default(args.height, util.scale(90)), ---@type number
		}

		local widget_icon = wibox.widget {
			image = menubar_utils.lookup_icon(app.Icon or ""),
			forced_height = util.scale(60),
			halign = "center",
			valign = "center",
			widget = wibox.widget.imagebox,
		}

		local widget_label = wibox.widget {
			text = app.Name or "",
			align = "center",
			valign = "bottom",
			forced_height = util.scale(30),
			widget = wibox.widget.textbox,
		}

		local widget_button = wibox.widget {
			{
				{
					nil,
					widget_icon,
					widget_label,
					layout = wibox.layout.align.vertical,
				},
				halign = "center",
				layout = wibox.container.place,
			},
			bg = gears.color.transparent,
			shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, util.scale(5)) end,
			shape_border_width = util.scale(1),
			shape_border_color = gears.color.transparent,
			widget = wibox.container.background,
		}

		local cmd = ""
		if app.cmdline then
			cmd = app.cmdline
		elseif app.Exec then
			if app.Exec:match("(.*)%%") then
				cmd = app.Exec:match("(.*)%%")
			else
				cmd = app.Exec
			end
		end

		buttonify {
			widget = widget_button,
			button_callback_release = function(w, b)
				if b == 1 then
					notify(util.table_to_string(app), 0)
					awful.spawn.with_shell(cmd)
				end
			end,
		}

		local widget = wibox.widget {
			widget_button,
			forced_width = args.width,
			forced_height = args.height,
			widget = wibox.container.constraint,
		}

		return widget
	end

	local grid = wibox.widget {
		homogeneous   = true,
		expand        = false,
		orientation   = "horizontal",
		spacing       = util.scale(5),
		--min_cols_size = util.scale(140),
		min_rows_size = util.scale(90),
		--forced_num_cols = 100,
		forced_num_rows = 6,
		--forced_width = util.scale(800),
		forced_height = util.scale(600),
		layout        = wibox.layout.grid,
	}

	rasti_launcher.utils.all_apps:run(function(all_apps)
		all_apps = all_apps
			:remove_hidden()
			:sort()

		local firefox = all_apps[1]
		for app in all_apps do
			if app.Name == "Firefox" then
				firefox = app
			end
			grid:add(create_new_grid_item(app))
		end
		util.dump_to_file(util.table_to_string(firefox), "/tmp/firefox.lua")
		--grid:add(create_new_grid_item(all_apps[1]))
	end)

	local widget = wibox.widget {
		grid,
		layout = wibox_layout_overflow.horizontal,
	}

	local wb = wibox {
		width   = util.scale(800),
		height  = util.scale(600),
		visible = false,
		type    = "desktop",
		bg      = gears.color.transparent,
		widget  = {
			widget,
			bg     = "#00000080",
			shape  = function(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, util.scale(10))
			end,
			widget = wibox.container.background,
		},
	}

	awful.placement.centered(wb)

	--rasti_launcher.utils.find_icon("firefox")
end
--]]
