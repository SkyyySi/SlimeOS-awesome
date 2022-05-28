pcall(require, "luarocks.loader") -- Enable LuaRocks package manager support

-- Error handling. Should be loaded as soon as possible to be able
-- to properly catch all errors.
local error_handling = require("modules.lib.error_handling")
error_handling {}

-- Standard awesome libraries
local gears              = require("gears")
local awful              = require("awful")
local wibox              = require("wibox") ---@type wibox Widget and layout library
local beautiful          = require("beautiful") -- Theme handling library
local naughty            = require("naughty") -- Notification library
local ruled              = require("ruled") -- Declarative object management
local menubar            = require("menubar")
local hotkeys_popup      = require("awful.hotkeys_popup")
local hotkeys_popup_keys = require("awful.hotkeys_popup.keys") -- Hotkeys help widget for VIM and other apps when client with a matching name is opened

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
local async = require("modules.lib.async")

-- {{{ Variable definitions
-- Themes define colors, icons, font and wallpapers.
local globals = require("modules.lib.globals")

util.add_package_path(globals.config_dir .. "modules")
util.add_package_path(globals.config_dir .. "modules/external")

local autostart = require("modules.lib.autostart")
--[ [
autostart {
	apps = {
		{ "picom", "--config", globals.config_dir.."/config/picom/picom.conf" },
	}
}
--]]

local theme_dir = gears.filesystem.get_configuration_dir().."themes/"..globals.theme
beautiful.init(theme_dir.."/theme.lua")

local bling = require("modules.external.bling") -- needs to be loaded after running beautiful.init
bling.module.flash_focus.enable()

local media_info = require("modules.widgets.media_info")

-- }}}

-- {{{ Menu
local awesome_xdg_menu = require("modules.widgets.awesome_xdg_menu")
local menus = awesome_xdg_menu {}

local main_menu
awesome.connect_signal("slimeos::menu_is_ready", function(menu)
	main_menu = menu.main
end)

local freedesktop = require("modules.external.awesome-freedesktop")

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
local function absolute_center_wibar(left, center, right)
	-- TODO: Add an empty widget with a click handler to the ends of the left and right,
	-- in order to add a right click functionality similarly to the one from the Windows taskbar.
	return wibox.widget {
		{ -- Left widgets
			{
				left,
				--right_click_menu_field(),
				layout = wibox.layout.fixed.horizontal,
			},
			nil,
			nil,
			expand = "outside",
			layout = wibox.layout.align.horizontal,
		},
		{ -- Middle widget
			nil,
			{
				center,
				layout = wibox.layout.fixed.horizontal,
			},
			nil,
			layout = wibox.layout.align.horizontal,
		},
		{ -- Right widgets
			nil,
			nil,
			{
				right,
				layout = wibox.layout.fixed.horizontal,
			},
			layout = wibox.layout.align.horizontal,
		},
		expand = "outside",
		layout = wibox.layout.align.horizontal,
	}
end

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
	-- Each screen has its own tag table.
	awful.tag({ " 一 ", " 二 ", " 三 ", " 四 ", " 五 ", " 六 ", " 七 ", " 八 ", " 九 ", " 十 " }, s, awful.layout.layouts[1])

	s.boxes = {} --- Wiboxes, desktop widgets, etc.

	--[[
	s.boxes.desktop_clock = wibox {
		x       = 10,
		y       = 10,
		width   = 200,
		height  = 100,
		visible = true,
		ontop   = true,
		type    = "desktop",
		bg      = gears.color.transparent,
	}

	s.boxes.desktop_clock.widget = {
		{
			font    = "Source Sans Pro, Bold "..tostring(math.floor(util.scale(24))),
			align   = "left",
			valign  = "top",
			format  = "%T",
			refresh = 1,
			widget  = wibox.widget.textclock,
		},
		{
			font    = "Source Sans Pro, "..tostring(math.floor(util.scale(16))),
			align   = "left",
			valign  = "top",
			format  = "%F",
			refresh = 1,
			widget  = wibox.widget.textclock,
		},
		layout = wibox.layout.fixed.vertical,
	}
	--]]

	s.widgets = {}

	-- Create a promptbox for each screen
	s.widgets.promptbox = awful.widget.prompt()

	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox {
		screen  = s,
		buttons = {
			awful.button({ }, 1, function () awful.layout.inc( 1) end),
			awful.button({ }, 3, function () awful.layout.inc(-1) end),
			awful.button({ }, 4, function () awful.layout.inc(-1) end),
			awful.button({ }, 5, function () awful.layout.inc( 1) end),
		}
	}

	-- Create a taglist widget
	s.widgets.taglist = awful.widget.taglist {
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
		}
	}

	-- Create a tasklist widget
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
		}
	}

	s.widgets.tasklist = awful.widget.tasklist {
		screen   = s,
		filter   = awful.widget.tasklist.filter.currenttags,
		buttons  = {
			awful.button({ }, 1, function (c)
				c:activate { context = "tasklist", action = "toggle_minimization" }
			end),
			awful.button({ }, 3, function() awful.menu.client_list { theme = { width = 250 } } end),
			awful.button({ }, 4, function() awful.client.focus.byidx(-1) end),
			awful.button({ }, 5, function() awful.client.focus.byidx( 1) end),
		},
		layout   = {
			spacing_widget = {
				{
					forced_width  = 5,
					forced_height = 24,
					thickness     = 1,
					color         = '#777777',
					widget        = wibox.widget.separator
				},
				valign = 'center',
				halign = 'center',
				widget = wibox.container.place,
			},
			spacing = 1,
			layout  = wibox.layout.fixed.horizontal
		},
		-- Notice that there is *NO* wibox.wibox prefix, it is a template,
		-- not a widget instance.
		widget_template = {
			{
				wibox.widget.base.make_widget(),
				forced_height = 5,
				id            = 'background_role',
				widget        = wibox.container.background,
			},
			{
				{
					id     = 'clienticon',
					widget = awful.widget.clienticon,
				},
				margins = 5,
				widget  = wibox.container.margin
			},
			nil,
			create_callback = function(self, c, index, objects) --luacheck: no unused args
				self:get_children_by_id('clienticon')[1].client = c

				-- BLING: Toggle the popup on hover and disable it off hover
				self:connect_signal('mouse::enter', function()
					awesome.emit_signal("bling::task_preview::visibility", s, true, c)
				end)
				self:connect_signal('mouse::leave', function()
					awesome.emit_signal("bling::task_preview::visibility", s, false, c)
				end)
			end,
			layout = wibox.layout.align.vertical,
		},
	}

	-- Keyboard map indicator and switcher
	--s.widgets.keyboardlayout = awful.widget.keyboardlayout()
	s.widgets.keyboardlayout = require("modules.widgets.keyboard_layout_switcher") {
		
	}

	screen.connect_signal("request::wallpaper", function(s)
		-- Wallpaper
		if beautiful.wallpaper then
			local wallpaper = beautiful.wallpaper
			-- If wallpaper is a function, call it with the screen
			if type(wallpaper) == "function" then
				wallpaper = wallpaper(s)
			end
			gears.wallpaper.maximized(wallpaper, s, true)
		end
	end)

	--[[
	s.widgets.launcher = awful.widget.launcher {
		image = beautiful.awesome_icon,
		menu  = main_menu,
	}
	--]]

	s.widgets.launcher = wibox.widget {
		{
			markup = "  a  ",
			widget = wibox.widget.textbox,
		},
		bg = beautiful.bg_focus,
		widget = wibox.container.background,
	}

	awesome.connect_signal("slimeos::menu_is_ready", function(menu)
		buttonify {
			widget               = s.widgets.launcher,
			mouse_effects        = true,
			button_color_hover   = beautiful.accent_primary_medium,
			button_color_normal  = beautiful.accent_primary_darker,
			button_color_press   = beautiful.accent_primary_brighter,
			button_color_release = beautiful.accent_primary_medium,
			button_callback_release = function(w, b)
				local width  = mouse.current_widget_geometry.width  + beautiful.useless_gap
				local height = mouse.current_widget_geometry.height + beautiful.useless_gap

				if b == 1 then
					awful.spawn({
						"rofi", "-config", globals.config_dir.."/config/rofi/config.rasi",
						"-xoffset", tostring(beautiful.useless_gap),
						"-yoffset", tostring(-(height)),
						"-show", "drun",
					})
				elseif b == 2 then
					menu.settings:toggle()
				elseif b == 3 then
					menu.tools:toggle()
				end
			end
		}
	end)

	s.widgets.layoutbox = awful.widget.layoutbox()

	-- Create a textclock widget
	s.widgets.textclock = wibox.widget {
		wibox.widget.textclock(),
		widget = wibox.container.background,
	}

	buttonify { s.widgets.textclock }

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
	}

	s.widgets.textclock:connect_signal("button::release", function()
		s.widgets.month_calendar:toggle()
		awful.placement.bottom_right(s.widgets.month_calendar, {
			honor_workarea = true,
		})
	end)

	-- Create the wibar
	s.panels = {}

	s.panels.primary = awful.wibar {
		position = "bottom",
		screen = s,
		height = 38,
	}

	-- Add widgets to the wibox
	--[[ ]]
	s.panels.primary.widget = absolute_center_wibar(
		{
			s.widgets.launcher,
			s.widgets.taglist,
			s.widgets.promptbox,
			layout = wibox.layout.fixed.horizontal,
		},
		{
			s.widgets.tasklist,
			layout = wibox.layout.fixed.horizontal,
		},
		{
			media_info {},
			s.widgets.keyboardlayout,
			wibox.widget.systray(),
			s.widgets.textclock,
			s.widgets.layoutbox,
			layout = wibox.layout.fixed.horizontal,
		}
	) --]]

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

	-- Add desktop icons
	freedesktop.desktop.add_icons {
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
	}
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

	-- Set Firefox to always map on the tag named "2" on screen 1.
	-- ruled.client.append_rule {
	--     rule       = { class = "Firefox"     },
	--     properties = { screen = 1, tag = "2" }
	-- }
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

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:activate {
		context = "mouse_enter",
		raise   = false,
	}
end)

-- Center all windows on spawn.
-- Please note that this will also re-center all clients when restarting awesome in-place.
client.connect_signal("manage", function(c)
	c.x = c.screen.geometry.width / 2 - c.width / 2
	c.y = c.screen.geometry.height / 2 - c.height / 2
	if not c.icon then
		notify(string.format("Client '%s' does not appear to have an icon", c.name))
		awful.spawn.easy_async_with_shell([[]])
	end
	--c.shape = function(cr, w, h)
	--	gears.shape.rounded_rect(cr, w, h, 8)
	--end
end)
