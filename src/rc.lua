#!/usr/bin/env lua
pcall(require, "luarocks.loader") -- Enable LuaRocks package manager support

-- Standard awesome libraries
local gears              = require("gears")
local awful              = require("awful")
local wibox              = require("wibox") -- Widget and layout library
local beautiful          = require("beautiful") -- Theme handling library
local naughty            = require("naughty") -- Notification library
local ruled              = require("ruled") -- Declarative object management
local menubar            = require("menubar")
local hotkeys_popup      = require("awful.hotkeys_popup")
local hotkeys_popup_keys = require("awful.hotkeys_popup.keys") -- Hotkeys help widget for VIM and other apps when client with a matching name is opened

local error_handling = require("modules.lib.error_handling")
error_handling {}

local config_auto_reload = require("modules.lib.config_auto_reload")
config_auto_reload {}

-- {{{ Variable definitions
-- Themes define colors, icons, font and wallpapers.
local globals = require("modules.lib.global")

beautiful.init(gears.filesystem.get_configuration_dir().."themes/"..globals.theme.."/theme.lua")
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", globals.terminal .. " -e man awesome" },
   { "edit config", globals.editor .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu {
	items = {
		{ "awesome", myawesomemenu, beautiful.awesome_icon },
		{ "open terminal", globals.terminal },
	}
}

--local awesome_menu = require("modules.widgets.awesome_menu")()
--mymainmenu = awesome_menu()
--mymainmenu = awful.menu({ "restart", awesome.restart })

mylauncher = awful.widget.launcher {
	image = beautiful.awesome_icon,
	menu = mymainmenu,
}

menubar.utils.terminal = globals.terminal
-- }}}

-- {{{ Tag
-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal("request::default_layouts", function()
	awful.layout.append_default_layouts({
		awful.layout.suit.floating,
		awful.layout.suit.spiral,

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

-- {{{ Wibar

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- Create a textclock widget
mytextclock = wibox.widget.textclock()

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

screen.connect_signal("request::desktop_decoration", function(s)
	-- Each screen has its own tag table.
	awful.tag({ "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X" }, s, awful.layout.layouts[1])

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()

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
	s.mytaglist = awful.widget.taglist {
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
	s.mytasklist = awful.widget.tasklist {
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

	-- Create the wibox
	s.mywibox = awful.wibar({ position = "top", screen = s })

	-- Add widgets to the wibox
	s.mywibox.widget = {
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			mylauncher,
			s.mytaglist,
			s.mypromptbox,
		},
		s.mytasklist, -- Middle widget
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			mykeyboardlayout,
			wibox.widget.systray(),
			mytextclock,
			s.mylayoutbox,
		},
	}
end)
-- }}}

-- {{{ Mouse bindings
awful.mouse.append_global_mousebindings({
	awful.button({ }, 3, function () mymainmenu:toggle() end),
	awful.button({ }, 4, awful.tag.viewprev),
	awful.button({ }, 5, awful.tag.viewnext),
})
-- }}}

-- {{{ Key bindings

-- General Awesome keys
awful.keyboard.append_global_keybindings({
	awful.key({ globals.modkey,           }, "s",      hotkeys_popup.show_help,
			  {description="show help", group="awesome"}),
	awful.key({ globals.modkey,           }, "w", function () mymainmenu:show() end,
			  {description = "show main menu", group = "awesome"}),
	awful.key({ globals.modkey, "Control" }, "r", awesome.restart,
			  {description = "reload awesome", group = "awesome"}),
	awful.key({ globals.modkey, "Shift"   }, "q", awesome.quit,
			  {description = "quit awesome", group = "awesome"}),
	awful.key({ globals.modkey }, "x",
			  function ()
				  awful.prompt.run {
					prompt       = "Run Lua code: ",
					textbox      = awful.screen.focused().mypromptbox.widget,
					exe_callback = awful.util.eval,
					history_path = awful.util.get_cache_dir() .. "/history_eval"
				  }
			  end,
			  {description = "lua execute prompt", group = "awesome"}),
	awful.key({ globals.modkey,           }, "Return", function () awful.spawn(globals.terminal) end,
			  {description = "open a terminal", group = "launcher"}),
	awful.key({ globals.modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
			  {description = "run prompt", group = "launcher"}),
	awful.key({ globals.modkey }, "p", function() menubar.show() end,
			  {description = "show the menubar", group = "launcher"}),
})

-- Tags related keybindings
awful.keyboard.append_global_keybindings({
	awful.key({ globals.modkey,           }, "Left",   awful.tag.viewprev,
			  {description = "view previous", group = "tag"}),
	awful.key({ globals.modkey,           }, "Right",  awful.tag.viewnext,
			  {description = "view next", group = "tag"}),
	awful.key({ globals.modkey,           }, "Escape", awful.tag.history.restore,
			  {description = "go back", group = "tag"}),
})

-- Focus related keybindings
awful.keyboard.append_global_keybindings({
	awful.key({ globals.modkey,           }, "j",
		function ()
			awful.client.focus.byidx( 1)
		end,
		{description = "focus next by index", group = "client"}
	),
	awful.key({ globals.modkey,           }, "k",
		function ()
			awful.client.focus.byidx(-1)
		end,
		{description = "focus previous by index", group = "client"}
	),
	awful.key({ globals.modkey,           }, "Tab",
		function ()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end,
		{description = "go back", group = "client"}),
	awful.key({ globals.modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
			  {description = "focus the next screen", group = "screen"}),
	awful.key({ globals.modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
			  {description = "focus the previous screen", group = "screen"}),
	awful.key({ globals.modkey, "Control" }, "n",
			  function ()
				  local c = awful.client.restore()
				  -- Focus restored client
				  if c then
					c:activate { raise = true, context = "key.unminimize" }
				  end
			  end,
			  {description = "restore minimized", group = "client"}),
})

-- Layout related keybindings
awful.keyboard.append_global_keybindings({
	awful.key({ globals.modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
			  {description = "swap with next client by index", group = "client"}),
	awful.key({ globals.modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
			  {description = "swap with previous client by index", group = "client"}),
	awful.key({ globals.modkey,           }, "u", awful.client.urgent.jumpto,
			  {description = "jump to urgent client", group = "client"}),
	awful.key({ globals.modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
			  {description = "increase master width factor", group = "layout"}),
	awful.key({ globals.modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
			  {description = "decrease master width factor", group = "layout"}),
	awful.key({ globals.modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
			  {description = "increase the number of master clients", group = "layout"}),
	awful.key({ globals.modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
			  {description = "decrease the number of master clients", group = "layout"}),
	awful.key({ globals.modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
			  {description = "increase the number of columns", group = "layout"}),
	awful.key({ globals.modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
			  {description = "decrease the number of columns", group = "layout"}),
	awful.key({ globals.modkey,           }, "space", function () awful.layout.inc( 1)                end,
			  {description = "select next", group = "layout"}),
	awful.key({ globals.modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
			  {description = "select previous", group = "layout"}),
})


awful.keyboard.append_global_keybindings({
	awful.key {
		modifiers   = { globals.modkey },
		keygroup    = "numrow",
		description = "only view tag",
		group       = "tag",
		on_press    = function (index)
			local screen = awful.screen.focused()
			local tag = screen.tags[index]
			if tag then
				tag:view_only()
			end
		end,
	},
	awful.key {
		modifiers   = { globals.modkey, "Control" },
		keygroup    = "numrow",
		description = "toggle tag",
		group       = "tag",
		on_press    = function (index)
			local screen = awful.screen.focused()
			local tag = screen.tags[index]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end,
	},
	awful.key {
		modifiers = { globals.modkey, "Shift" },
		keygroup    = "numrow",
		description = "move focused client to tag",
		group       = "tag",
		on_press    = function (index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end,
	},
	awful.key {
		modifiers   = { globals.modkey, "Control", "Shift" },
		keygroup    = "numrow",
		description = "toggle focused client on tag",
		group       = "tag",
		on_press    = function (index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end,
	},
	awful.key {
		modifiers   = { globals.modkey },
		keygroup    = "numpad",
		description = "select layout directly",
		group       = "layout",
		on_press    = function (index)
			local t = awful.screen.focused().selected_tag
			if t then
				t.layout = t.layouts[index] or t.layout
			end
		end,
	}
})

client.connect_signal("request::default_mousebindings", function()
	awful.mouse.append_client_mousebindings({
		awful.button({ }, 1, function (c)
			c:activate { context = "mouse_click" }
		end),
		awful.button({ globals.modkey }, 1, function (c)
			c:activate { context = "mouse_click", action = "mouse_move"  }
		end),
		awful.button({ globals.modkey }, 3, function (c)
			c:activate { context = "mouse_click", action = "mouse_resize"}
		end),
	})
end)

client.connect_signal("request::default_keybindings", function()
	awful.keyboard.append_client_keybindings({
		awful.key({ globals.modkey,           }, "f",
			function (c)
				c.fullscreen = not c.fullscreen
				c:raise()
			end,
			{description = "toggle fullscreen", group = "client"}),
		awful.key({ globals.modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
				{description = "close", group = "client"}),
		awful.key({ globals.modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
				{description = "toggle floating", group = "client"}),
		awful.key({ globals.modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
				{description = "move to master", group = "client"}),
		awful.key({ globals.modkey,           }, "o",      function (c) c:move_to_screen()               end,
				{description = "move to screen", group = "client"}),
		awful.key({ globals.modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
				{description = "toggle keep on top", group = "client"}),
		awful.key({ globals.modkey,           }, "n",
			function (c)
				-- The client currently has the input focus, so it cannot be
				-- minimized, since minimized clients can't have the focus.
				c.minimized = true
			end ,
			{description = "minimize", group = "client"}),
		awful.key({ globals.modkey,           }, "m",
			function (c)
				c.maximized = not c.maximized
				c:raise()
			end ,
			{description = "(un)maximize", group = "client"}),
		awful.key({ globals.modkey, "Control" }, "m",
			function (c)
				c.maximized_vertical = not c.maximized_vertical
				c:raise()
			end ,
			{description = "(un)maximize vertically", group = "client"}),
		awful.key({ globals.modkey, "Shift"   }, "m",
			function (c)
				c.maximized_horizontal = not c.maximized_horizontal
				c:raise()
			end ,
			{description = "(un)maximize horizontally", group = "client"}),
	})
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

	awful.titlebar(c).widget = {
		{ -- Left
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout  = wibox.layout.fixed.horizontal
		},
		{ -- Middle
			{ -- Title
				align  = "center",
				widget = awful.titlebar.widget.titlewidget(c)
			},
			buttons = buttons,
			layout  = wibox.layout.flex.horizontal
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton (c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton   (c),
			awful.titlebar.widget.ontopbutton    (c),
			awful.titlebar.widget.closebutton    (c),
			layout = wibox.layout.fixed.horizontal()
		},
		layout = wibox.layout.align.horizontal
	}
end)

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
	c:activate { context = "mouse_enter", raise = false }
end)

-- Center all windows on spawn.
-- Please note that this will also re-center all clients when restarting awesome in-place.
client.connect_signal("manage", function(c)
	c.x = c.screen.geometry.width / 2 - c.width / 2
	c.y = c.screen.geometry.height / 2 - c.height / 2
end)