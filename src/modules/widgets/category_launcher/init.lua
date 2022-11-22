local require = require
local table = table
local pairs = pairs
local ipairs = ipairs
local math = math
local pcall = pcall
local setmetatable = setmetatable
local getmetatable = getmetatable
local next = next
local os = os

local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local menubar   = require("menubar")
local menubar_utils = require("modules.widgets.dock.menubar_utils")
wibox.layout.overflow = require("wibox_layout_overflow")
awful.widget.inputbox = require("awful_widget_inputbox")

local buttonify = require("modules.lib.buttonify")
local globals = require("modules.lib.globals")
local util      = require("modules.lib.util")
local tts = util.table_to_string
local ttss = util.table_to_string_simple

local inf, neginf = math.huge, -math.huge
--- A fuzzy finder, see https://github.com/swarn/fzy-lua
local fzy
pcall(function() fzy = require("fzy") end)
fzy = fzy or require("modules.widgets.category_launcher.fzy_lua")

--- Get the initials from a full name
---@generic T1 : str
---@param name? T1
---@return T1
local function get_initials(name)
	if not name then
		return name
	end

	local inits = name:sub(1, 1)

	for i = 2, #name do
		if name:sub(i, i) == " " then
			inits = inits..name:sub(i+1, i+1)
		end
	end

	return inits
end

local function search_highlight(str, pattern)
	if not fzy.has_match(str, pattern) then
		return
	end

	local positions, newstr = fzy.positions(str, pattern), "";
	for i = 1, #pattern do
		local c = pattern:sub(i, i)
		if i == positions[1] then
			newstr = newstr.."<b>"..c.."</b>"
			table.remove(positions, 1)
		else
			newstr = newstr..c
		end
	end

	return newstr
end

local all_apps = {}
local all_apps_mt = {}
all_apps_mt.__index = all_apps_mt
setmetatable(all_apps, all_apps_mt)

function all_apps_mt:is_empty()
	return next(self) == nil
end

function all_apps_mt:update(fn, do_not_regenerate)
	if not self:is_empty() and do_not_regenerate then
		fn(self)
		return
	end

	local app_dirs = {}
	do
		local data_dirs = gears.filesystem.get_xdg_data_dirs()
		for k, dir in ipairs(data_dirs) do
			--- Clean the paths to always be in `/foo/bar/biz/baz` format
			data_dirs[k] = dir:gsub("[/]+", "/"):gsub("[/]+$", "")
		end

		do
			local share_dir = os.getenv("HOME").."/.local/share"
			local has_dir = false
			for _, dir in ipairs(data_dirs) do
				if dir == share_dir then
					has_dir = true
					break
				end
			end
			if not has_dir then
				table.insert(data_dirs, 1, share_dir)
			end
		end

		do
			local share_dir = "/usr/share"
			local has_dir = false
			for _, dir in ipairs(data_dirs) do
				if dir == share_dir then
					has_dir = true
					break
				end
			end
			if not has_dir then
				table.insert(data_dirs, share_dir)
			end
		end

		for _, dir in ipairs(data_dirs) do
			table.insert(app_dirs, dir.."/applications/")
		end
	end

	local function assemble_app_list(apps)
		for k, _ in pairs(self) do
			self[k] = nil
		end

		--- Remove all desktop entries that aren't supposed to be shown
		for _, app in ipairs(apps) do
			if app.show then
				table.insert(self, app)
			end
		end

		table.sort(self, function(a, b)
			return (a.Name or "") < (b.Name or "")
		end)

		fn(self)
	end

	do
		local parsed_apps = {}
		local function proceed(k)
			menubar_utils.parse_dir(app_dirs[k], function(parsed_apps_temp)
				parsed_apps = gears.table.join(parsed_apps, parsed_apps_temp)
				local next_k, next_v = next(app_dirs, k)
				if next_v then
					proceed(next_k)
				else
					assemble_app_list(parsed_apps)
				end
			end)
		end
		proceed(1)
	end
end

function all_apps_mt:filter(pattern)
	local matches = {}
	setmetatable(matches, getmetatable(self))

	for k, app in ipairs(self) --[[ or (v.Comment ~= nil and v.Comment:match(pattern)) ]] do
		if app.Name ~= nil and app.Name:match(pattern) then
			table.insert(matches, app)
		end
	end

	return matches
end

function all_apps_mt:run(fn)
	if self:is_empty() then
		self:update(fn)
		return
	end

	fn(self)
end

all_apps_mt._return_key_mt = { --- If no icon is defined, just return the input
	__index = function(self, k)
		return k
	end
}

all_apps_mt.category_icon_map = setmetatable({
	All         = "applications-all",
	Favorites   = "applications-featured",
	Recent      = "history",

	Accessibility = "accessibility",
	AudioVideo  = "applications-multimedia",
	Development = "applications-development",
	Education   = "applications-education",
	Game        = "applications-games",
	Graphics    = "applications-graphics",
	Network     = "applications-internet",
	Office      = "applications-office",
	Science     = "applications-science",
	Settings    = "preferences-desktop",
	System      = "applications-system",
	Utility     = "applications-utilities",
	Other       = "applications-other",

	Wine        = "wine",
}, all_apps_mt._return_key_mt)

all_apps_mt.category_id_map = setmetatable({
	All         = "applications-all",
	Favorites   = "applications-featured",
	Recent      = "history",

	Accessibility = "accessibility",
	AudioVideo  = "applications-multimedia",
	Development = "applications-development",
	Education   = "applications-education",
	Game        = "applications-games",
	Graphics    = "applications-graphics",
	Network     = "applications-internet",
	Office      = "applications-office",
	Science     = "applications-science",
	Settings    = "preferences-desktop",
	System      = "applications-system",
	Utility     = "applications-utilities",
	Other       = "applications-other",
}, all_apps_mt._return_key_mt)

all_apps_mt.category_name_map = setmetatable({
	All         = "All",
	Favorites   = "Favorites",
	Recent      = "Recent",

	Accessibility = "Accessibility",
	AudioVideo  = "Multimedia",
	Development = "Development",
	Education   = "Education",
	Game        = "Games",
	Graphics    = "Graphics",
	Network     = "Internet",
	Office      = "Office",
	Science     = "Science",
	Settings    = "Settings",
	System      = "System",
	Utility     = "Utilities",
	Other       = "Other",

	Wine        = "Wine",
}, all_apps_mt._return_key_mt)

do
	local i = 0

	function all_apps_mt:__call()
		i = i + 1

		if not self[i] then
			i = 0
			return
		end

		return self[i]
	end
end

function all_apps_mt:fuzzy_find_app(matcher_string)
	local found_matches = {}

	for _, app in ipairs(self) do
		if app and app.Name and fzy.has_match(matcher_string, app.Name) then
			table.insert(found_matches, { fzy.score(matcher_string, app.Name), app })
		end
	end

	table.sort(found_matches, function(a, b)
		return a[1] > b[1]
	end)

	--notify(#found_matches, 0)
	--notify(("3 closest matches for '%s': %s, %s and %s"):format(matcher_string, found_matches[1][2].Name, found_matches[2][2].Name, found_matches[3][2].Name), 0)

	return found_matches
end

--menubar.menu_gen.generate(function(menu)
--	util.dump_to_file(tts(menu), "/tmp/menu.lua")
--end)

--all_apps:run(function(self)
	--local str = ""
	--local filtered_apps = self:filter("Ala")
	--for k, v in pairs(filtered_apps) do
	--	str = str..v.Exec.."\n"
	--end
	--notify(str, 0)
--	notify(util.table_to_string(self[1]), 0)
--end)

--notify(tts(menubar.menu_gen.all_categories), 0)

awesome.connect_signal("all_apps::get", function(cb)
	all_apps:update(cb, true)
end)

--- A wrapper around `get_children_by_id()` to make it easier to use.
---@param widget wibox.widget._instance
---@param id string
---@param callback fun(child: wibox.widget._instance)
local function for_children(widget, id, callback)
	if not widget or not widget.get_children_by_id then
		return
	end

	for _, child in pairs(widget:get_children_by_id(id)) do
		callback(child)
	end
end

local function nop() end

local function flexi_launcher(args)
	args = util.default(args, {})
	args.auto_close = util.default(args.auto_close, false) --- Automatically close wheneven the cursor leaves the container
	args.id = util.default(args.id, args.screen) --- Used to summon it with a signal, in order to allow as many different launchers as the user desires

	args.app_template = args.app_template --- For each individual app, like Firefox, VLC, VScode, etc.
	args.widget_template = args.widget_template --- For the wibox.widget that'll hold the apps
	args.container = util.default(args.container, awful.popup) --- A container box, must have an API similar to a wibox, like awful.popup
	args.container_template = args.container_template --- Template for the wibox/popup/bar/etc.

	--- TODO: These two should be passed with the signal to show the widget,
	--- which would mean that we'd only need to create one instance for multiple screens.
	args.screen = util.default(args.screen, screen.primary)
	args.placement_fn = util.default(args.placement_fn, function(w) awful.placement.bottom_left(w, { honor_workarea = true, margins = util.scale(10) }) end)

	--- IMPORTANT: Although this is returned, you should not rely on it being populated
	--- immediatly. Instead, you should use a callback. This is, however, OK to use
	--- if your code is written with that in mind, for example when accessing it lazily
	--- (in that case, make sure to check that `fl.generated` == true).
	local fl = {
		generated = false,
		show = nop,
		hide = nop,
		toggle = nop,
	}

	all_apps:run(function(apps) ---@param apps FreeDesktop.desktop_entry[]
		---@type table<string, {apps: FreeDesktop.desktop_entry[], name: string, icon?: string}>
		fl.category_names = {
			"Accessibility",
			"AudioVideo",
			"Development",
			"Education",
			"Game",
			"Graphics",
			"Network",
			"Office",
			"Science",
			"Settings",
			"System",
			"Utility",
			"Wine",
			"Other",
		}

		fl.all_apps = apps

		---@param fn fun(name: string)
		function fl.for_category_names(fn)
			for _, name in ipairs(fl.category_names) do
				fn(name)
			end
		end

		fl.categories = {}
		fl.for_category_names(function(cat)
			fl.categories[cat] = {}
			fl.categories[cat].apps = {}
			fl.categories[cat].name = all_apps.category_name_map[cat]
			fl.categories[cat].icon = menubar_utils.lookup_icon(all_apps.category_icon_map[cat])
		end)

		for app in apps do
			if app.Categories then
				for _, app_category in pairs(app.Categories) do
					if fl.categories[app_category] then
						table.insert(fl.categories[app_category].apps, app)
					end
				end
			elseif app.file:match("/wine/") then
				table.insert(fl.categories.Wine.apps, app)
			else
				table.insert(fl.categories.Other.apps, app)
			end
		end

		for _, category in pairs(fl.categories) do
			table.sort(category.apps, function(a, b)
				return a.Name < b.Name
			end)
		end

		--- Assemple a table to serve as a structure for `awful.menu`.
		--- It won't be further used by this widget from here on, but
		--- I think it's better to consistently generate it in here
		--- rather than ending up with everyone needing to implement
		--- it themselves.
		---
		--- Usage:
		---
		--- ```
		--- local my_menu = awful.menu { items = flexi_launcher.menu_items }
		--- ```
		do
			local submenus = {}
			fl.for_category_names(function(name)
				submenus[name] = {}
				for _, app in pairs(fl.categories[name].apps) do
					table.insert(submenus[name], { app.Name, function()
						awful.spawn(app.cmdline)
						fl.visible = false
					end, app.icon_path })
				end
			end)

			local default_apps = {}
			default_apps.terminal = terminal or "xterm"
			default_apps.editor   = editor or (terminal or "xterm").." -e "..(os.getenv("EDITOR") or os.getenv("VISUAL") or "nano")

			fl.menu_items = {
				{
					"Awesome",
					{
						{ "Show hotkeys", function() awful.hotkeys_popup.show_help(nil, awful.screen.focused()) end, menubar_utils.lookup_icon("input-keyboard-symbolic") },
						{ "Show manual", default_apps.terminal .. " -e man awesome",                                 menubar_utils.lookup_icon("help-info-symbolic") },
						{ "Edit config", default_apps.editor .. " " .. globals.config_dir,                   menubar_utils.lookup_icon("edit-symbolic") },
						{ "Restart awesome", awesome.restart,                                                        menubar_utils.lookup_icon("system-restart-symbolic") },
						{ "Quit awesome", function() awesome.quit() end,                                             menubar_utils.lookup_icon("application-exit-symbolic") },
					},
					beautiful.awesome_icon,
				},
				{ "Power",
					{
						{ "Lock session", "xdg-screensaver lock",           menubar_utils.lookup_icon("system-lock-screen") }, -- loginctl lock-session
						{ "Shutdown",     "gnome-session-quit --power-off", menubar_utils.lookup_icon("system-shutdown") },
						{ "Reboot",       "gnome-session-quit --reboot",    menubar_utils.lookup_icon("system-reboot") },
						{ "Suspend",      "systemctl suspend",              menubar_utils.lookup_icon("system-suspend") },
						{ "Hibernate",    "systemctl hibernate",            menubar_utils.lookup_icon("system-hibernate") },
						{ "Log out",      "gnome-session-quit --logout",    menubar_utils.lookup_icon("system-log-out") },
					},
					menubar_utils.lookup_icon("system-shutdown-symbolic"),
				},
				{ "-----------" },
				{ fl.categories.Accessibility.name, submenus.Accessibility, fl.categories.Accessibility.icon, },
				{ fl.categories.AudioVideo.name,    submenus.AudioVideo,    fl.categories.AudioVideo.icon,    },
				{ fl.categories.Development.name,   submenus.Development,   fl.categories.Development.icon,   },
				{ fl.categories.Education.name,     submenus.Education,     fl.categories.Education.icon,     },
				{ fl.categories.Game.name,          submenus.Game,          fl.categories.Game.icon,          },
				{ fl.categories.Graphics.name,      submenus.Graphics,      fl.categories.Graphics.icon,      },
				{ fl.categories.Network.name,       submenus.Network,       fl.categories.Network.icon,       },
				{ fl.categories.Office.name,        submenus.Office,        fl.categories.Office.icon,        },
				{ fl.categories.Science.name,       submenus.Science,       fl.categories.Science.icon,       },
				{ fl.categories.Settings.name,      submenus.Settings,      fl.categories.Settings.icon,      },
				{ fl.categories.System.name,        submenus.System,        fl.categories.System.icon,        },
				{ fl.categories.Utility.name,       submenus.Utility,       fl.categories.Utility.icon,       },
				{ fl.categories.Wine.name,          submenus.Wine,          fl.categories.Wine.icon,          },
				{ fl.categories.Other.name,         submenus.Other,         fl.categories.Other.icon,         },
			}

			fl.awful_menu = awful.menu { items = fl.menu_items }
		end

		local function gen_app_button(app, parent)
			local widget = wibox.widget(args.app_template or {
				{
					{
						{
							id     = "app-icon-role",
							widget = wibox.widget.imagebox,
						},
						{
							{
								id     = "app-title-role",
								halign = "left",
								valign = "center",
								widget = wibox.widget.textbox,
							},
							{
								{
									id     = "app-description-role",
									halign = "left",
									valign = "center",
									widget = wibox.widget.textbox,
								},
								fg     = util.color.alter(beautiful.fg_normal, { a = 0.7 }),
								widget = wibox.container.background,
							},
							layout  = wibox.layout.fixed.vertical,
						},
						spacing       = util.scale(10),
						forced_height = util.scale(40),
						layout        = wibox.layout.fixed.horizontal,
					},
					margins = util.scale(5),
					widget  = wibox.container.margin,
				},
				id     = "background-role",
				shape  = function(cr, w, h)
					gears.shape.rounded_rect(cr, w, h, util.scale(10))
				end,
				widget = wibox.container.background,
			})

			for_children(widget, "app-icon-role", function(child)
				child.image = app.icon_path
			end)

			for_children(widget, "app-title-role", function(child)
				child.markup = app.Name
			end)

			for_children(widget, "app-description-role", function(child)
				if app.Comment and app.Comment ~= "" then
					child.markup = "<i>"..app.Comment.."</i>"
				else
					child.forced_heigth = 0
				end
			end)

			local right_click_menu_items = {}
			if app.file then
				local desktop_file_name = app.file:match(".*/(.*%.desktop)$")
				table.insert(right_click_menu_items, {
					"Pin to dock",
					function()
						awesome.emit_signal("slimeos::dock::favorites::add", desktop_file_name)
					end,
				})

				if app.actions_table and next(app.actions_table) ~= nil then
					table.insert(right_click_menu_items, { "-----------" })
				end
			end

			if app.actions_table and next(app.actions_table) ~= nil then
				for _, action in pairs(app.actions_table) do
					table.insert(right_click_menu_items, { action.Name, function() awful.spawn(action.Exec:gsub("%%.*", "")) end, action.Icon })
				end
			end

			local right_click_menu = awful.menu {
				items = right_click_menu_items,
			}

			awesome.connect_signal("flexi_launcher::collapse_right_click_menus_except", function(menu)
				if right_click_menu ~= menu then
					right_click_menu:hide()
				end
			end)

			for_children(widget, "background-role", function(child)
				buttonify {
					widget = child,
					button_callback_release = function(w, b)
						if b == 1 then
							awful.spawn(app.cmdline)
							awesome.emit_signal("flexi_launcher::visibility::hide", args.id)
						elseif b == 3 then
							awesome.emit_signal("flexi_launcher::collapse_right_click_menus_except", right_click_menu)
							right_click_menu:show()
						elseif b == 4 or b == 5 then
							for_children(parent, "button-holder-role", function(app_button_list)
								for _, app_button in pairs(app_button_list.children) do
									for_children(app_button, "background-role", function(background_widget)
										background_widget.bg = gears.color.transparent
									end)
								end
							end)
						end
					end,
				}
			end)

			return widget
		end

		local function gen_app_list_widget()
			local function shape(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, util.scale(15))
			end

			local widget = wibox.widget(util.default(args.widget_template, {
				{
					{
						{
							{
								id            = "button-holder-role",
								homogeneous   = true,
								expand        = true,
								orientation   = "vertical",
								spacing       = util.scale(10),
								min_cols_size = util.scale(160),
								forced_width  = util.scale(160),
								layout        = wibox.layout.grid,
							},
							right  = util.scale(10),
							widget = wibox.container.margin,
						},
						layout = wibox.layout.overflow.vertical,
					},
					margins = util.scale(10),
					widget  = wibox.container.margin,
				},
				bg     = "#FFFFFF10",
				shape  = shape,
				widget = wibox.container.background,
			}))

			function widget:add_app(app)
				for_children(widget, "button-holder-role", function(child)
					child:add(app)
				end)
			end

			return widget
		end

		local function gen_category_switcher_widget()
			local function shape(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, util.scale(15))
			end

			local widget = wibox.widget(util.default(args.widget_template, {
				{
					{
						{
							id            = "button-holder-role",
							homogeneous   = true,
							expand        = true,
							orientation   = "vertical",
							spacing       = util.scale(5),
							min_cols_size = util.scale(160),
							forced_width  = util.scale(160),
							layout        = wibox.layout.grid,
						},
						margins = util.scale(5),
						widget  = wibox.container.margin,
					},
					layout = wibox.layout.overflow.vertical,
				},
				bg     = "#FFFFFF10",
				shape  = shape,
				widget = wibox.container.background,
			}))

			function widget:add_app(app)
				for_children(widget, "button-holder-role", function(child)
					child:add(app)
				end)
			end

			return widget
		end

		--[[ Test code; to be removed
		do
			local wb = wibox {
				type    = "desktop",
				width   = 800,
				height  = 800,
				visible = true,
				beind   = true,
				shape   = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, util.scale(5)) end,
				bg      = gears.color.transparent,
				widget  = {
					{
						{
							{
								id            = "app-holder-role",
								orientation   = "vertical",
								min_cols_size = util.scale(160),
								spacing       = util.scale(10),
								layout        = wibox.layout.grid,
							},
							layout = wibox.layout.overflow.vertical,
						},
						marings = util.scale(10),
						widget  = wibox.container.margin,
					},
					bg     = "#000A",
					shape  = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, util.scale(5)) end,
					widget = wibox.container.background,
				}
			}
			awful.placement.centered(wb)

			for_children(wb.widget, "app-holder-role", function(child)
				for _, app in ipairs(fl.all_apps) do
					child:add(gen_app_button(app, wb.widget))
				end
			end)
		end
		--]]

		do
			local function shape(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, util.scale(20))
			end

			local app_grid_widget = gen_app_list_widget()
			for i = 1, #apps do
				app_grid_widget:add_app(gen_app_button(apps[i], app_grid_widget))
			end

			fl.container = args.container(util.default(args.container_template, {
				ontop   = true,
				visible = false,
				screen  = args.screen,
				bg      = gears.color.transparent,
				shape   = shape,
				widget  = {
					{
						{
							app_grid_widget,
							margins = util.scale(20),
							widget  = wibox.container.margin,
						},
						bg     = beautiful.bg_normal,
						shape  = shape,
						widget = wibox.container.background,
					},
					strategy = "exact",
					width    = util.scale(600),
					height   = util.scale(700),
					widget   = wibox.container.constraint,
				},
			}))
		end

		function fl:show(placement_fn)
			--fl.awful_menu:show()
			self.visible = true
			self.container.visible = true
			(placement_fn or args.placement_fn)(self.container)

			--- For some reason, the placement seems to not apply
			--- the first time this function is executed. To force it to work,
			--- we re-run the placement function after a short period of time.
			gears.timer {
				timeout   = 0.05,
				autostart = true,
				callback  = function(timer)
					(placement_fn or args.placement_fn)(self.container)
					timer:stop()
				end,
			}
		end

		function fl:hide()
			--fl.awful_menu:hide()
			self.visible = false
			self.container.visible = false
		end

		function fl:toggle()
			if self.visible then
				self:hide()
			else
				self:show()
			end
		end

		awesome.connect_signal("flexi_launcher::visibility::show", function(id, placement_fn)
			if id == args.id then
				fl:show(placement_fn)
			end
		end)

		awesome.connect_signal("flexi_launcher::visibility::hide", function(id)
			if id == args.id then
				fl:hide()
			end
		end)

		awesome.connect_signal("flexi_launcher::visibility::toggle", function(id)
			if id == args.id then
				fl:toggle()
			end
		end)

		fl.generated = true
	end)

	return fl
end

local function category_launcher(args)
	args = util.default(args, {})
	args = {
		screen = util.default(args.screen, screen.primary),
		auto_close = util.default(args.auto_close, false),
	}

	-- TODO: Switch away from automatic category detection and use https://specifications.freedesktop.org/menu-spec/latest/apa.html instead

	all_apps:run(function(apps) ---@param apps FreeDesktop.desktop_entry[]
		--util.dump_to_file(tts(apps), "/tmp/apps.lua")
		---@type string[]
		local category_names = {
			"AudioVideo",  "Development", "Education",
			"Game",        "Graphics",    "Network",
			"Office",      "Science",     "Settings",
			"System",      "Utility",     "Other",
		}
		local categorized_apps = {
			AudioVideo  = {},
			--Audio       = {}, -- (hidden/ignored)
			--Video       = {}, -- (hidden/ignored)
			Development = {},
			Education   = {},
			Game        = {}, -- Games
			Graphics    = {},
			Network     = {}, -- Internet
			Office      = {},
			Science     = {},
			Settings    = {},
			System      = {},
			Utility     = {},
			Other       = {},
		}

		_ghfjd = 0
		for k, app in ipairs(apps) do
			if app.Categories then
				--app.category = app.Categories[1]
				local category_was_found = false
				for _, app_category in ipairs(app.Categories) do
					for _, known_category in ipairs(category_names) do
						if app_category == known_category then
							table.insert(categorized_apps[app_category], app)
							--app.category = app_category
							--category_was_found = true
							--break
						end
					end
					--if category_was_found then
					--	break
					--end
				end
			else
				table.insert(categorized_apps.Other, app)
			end

			app.category = app.category or "Other"

			--categorized_apps[app.category][#(categorized_apps[app.category]) + 1] = app
		end
		for _, cat in pairs(categorized_apps) do
			table.sort(categorized_apps, function(a, b)
				return a.Name < b.Name
			end)
		end
		table.sort(category_names)

		--util.dump_to_file(tts(category_names), "/tmp/category_names.lua")

		local items = {} ---@type table[]
		for k,category in ipairs(category_names) do
			local subm = {}
			local subm_keys = {}

			for _, app in pairs(categorized_apps[category]) do
				table.insert(subm_keys, app.Name)
			end
			table.sort(subm_keys)

			for sk, name in pairs(subm_keys) do
				local app = categorized_apps[category][sk]
				local cmd = ""
				if app.cmdline then
					cmd = app.cmdline
				elseif app.Exec then
					cmd = app.Exec:match("(.+)%%")
				end
				table.insert(subm, { app.Name, cmd, app.icon_path,  app = app })
			end

			-- TODO Add a proper categorization
			local category_icon = "/usr/share/icons/Papirus-Dark/24x24/categories/"..all_apps.category_icon_map[category]..".svg" -- = menubar_utils.lookup_icon("applications-"..category)

			items[k] = { category, subm, category_icon }
		end

		--util.dump_to_file(tts(items), "/tmp/items.lua")

		local rasti_menu_wibox = wibox {
			width   = util.scale(500),
			height  = util.scale(700),
			ontop   = true,
			visible = false,
			screen  = args.screen,
			bg      = gears.color.transparent,
			shape   = function(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, util.scale(20))
			end,
		}

		local rasti_menu_wibox_subwidgets = {}

		local function create_app_entry(args)
			args = args or {}
			args.name = args.name or ""
			args.icon = args.icon or ""
			args.cmd  = args.cmd  or ""
			args.actions = args.actions or {}
			args.app = args.app or {}
			args.parent_grid = args.parent_grid

			local app_widget_icon
			if args.icon then
				app_widget_icon = wibox.widget {
					{
						image  = args.icon,
						widget = wibox.widget.imagebox,
					},
					right  = util.scale(10),
					widget = wibox.container.margin,
				}
			end

			local app_widget = wibox.widget {
				{
					{
						app_widget_icon,
						{
							markup = args.name,
							halign = "left",
							valign = "center",
							widget = wibox.widget.textbox,
						},
						forced_height = util.scale(35),
						layout        = wibox.layout.fixed.horizontal,
					},
					margins = util.scale(5),
					widget  = wibox.container.margin,
				},
				shape  = function(cr, w, h)
					gears.shape.rounded_rect(cr, w, h, util.scale(10))
				end,
				widget = wibox.container.background,
			}

			local right_click_menu_items = {}
			if args.app.file then
				local desktop_file_name = args.app.file:match(".*/(.*%.desktop)$")
				table.insert(right_click_menu_items, {
					"Pin to dock",
					function()
						awesome.emit_signal("slimeos::dock::favorites::add", desktop_file_name)
					end,
				})

				if args.app.actions_table and next(args.app.actions_table) ~= nil then
					table.insert(right_click_menu_items, { "-----------" })
				end
			end

			if args.app.actions_table and next(args.app.actions_table) ~= nil then
				for k, v in pairs(args.app.actions_table) do
					table.insert(right_click_menu_items, { v.Name, function() awful.spawn(v.Exec:gsub("%%.*", "")) end, v.Icon })
				end
			end

			local right_click_menu = awful.menu {
				items = right_click_menu_items,
			}

			awesome.connect_signal("category_launcher::collapse_right_click_menus_except", function(menu)
				if right_click_menu ~= menu then
					right_click_menu:hide()
				end
			end)

			buttonify {
				app_widget,
				button_callback_release = function(w, b)
					if b == 1 then
						awful.spawn(args.cmd)
						rasti_menu_wibox:hide()
					elseif b == 3 then
						awesome.emit_signal("category_launcher::collapse_right_click_menus_except", right_click_menu)
						right_click_menu:show()
					elseif b == 4 or b == 5 then
						for _, child in pairs(args.parent_grid.children) do
							child.widget.bg = gears.color.transparent
						end
					end
				end,
			}

			return wibox.widget {
				app_widget,
				right  = util.scale(10),
				widget = wibox.container.margin,
			}
		end

		--notify(tts(apps[1]), 0)
		local search_prompt_textbox = wibox.widget.textbox()
		local search_prompt_is_running = false
		local search_prompt_app_list_grid = wibox.widget {
			homogeneous   = true,
			expand        = true,
			orientation   = "vertical",
			spacing       = util.scale(5),
			min_cols_size = util.scale(160),
			forced_width  = util.scale(160),
			layout        = wibox.layout.grid,
		}

		local function search_prompt()
			search_prompt_is_running = true
			local _old_category = rasti_menu_wibox_subwidgets.current_app_list_widget._current_app_category
			awful.prompt.run {
				prompt = "<b>Search: </b>",
				textbox = search_prompt_textbox,
				done_callback = function()
					search_prompt_is_running = false
					if rasti_menu_wibox_subwidgets.current_app_list_widget._current_app_category == "_search" then
						rasti_menu_wibox_subwidgets.current_app_list_widget:change_category(_old_category)
					end
					rasti_menu_wibox:hide()
				end,
				exe_callback = function(input)
					if not input or #input == 0 then return end
					--notify("The input was: "..input)
					--notify("The the closest match is: "..tts(apps:fuzzy_find_app(input)[1]), 0)
					local found_app = apps:fuzzy_find_app(input)[1][2]
					local cmd = ""
					if found_app.cmdline then
						cmd = found_app.cmdline
					elseif found_app.Exec then
						cmd = found_app.Exec:match("(.+)%%")
					end
					--notify(tts(found_app), 0)
					awful.spawn(cmd)
					rasti_menu_wibox:hide()
				end,
				keypressed_callback = function(mod, key, input)
					if key == "Escape" then
						return
					end

					if not input or #input == 0 then
						if rasti_menu_wibox_subwidgets.current_app_list_widget._current_app_category == "_search" then
							rasti_menu_wibox_subwidgets.current_app_list_widget:change_category(_old_category)
						end
						return
					end

					if #key == 1 then -- Only append characters, not things like `BackSpace`
						input = input..key
					end

					rasti_menu_wibox_subwidgets.current_app_list_widget:change_category("_search")

					local found_apps = apps:fuzzy_find_app(input)

					--for k, _ in pairs(search_prompt_app_list_grid.children) do
					--	search_prompt_app_list_grid.children[k] = nil
					--end
					search_prompt_app_list_grid:reset()

					for _, app_pair in pairs(found_apps) do
						if app_pair and next(app_pair[2]) ~= nil then
							--search_prompt_app_list_grid:add(wibox.widget {
							--	markup = search_highlight(input, found_apps[i][2].Name),
							--	widget = wibox.widget.textbox,
							--})
							local app = app_pair[2]
							local cmd = ""
							if app.cmdline then
								cmd = app.cmdline
							elseif app.Exec then
								cmd = app.Exec:match("(.+)%%")
							end
							local app_widget = create_app_entry {
								name = search_highlight(input, app.Name),
								icon = app.icon_path,
								cmd = cmd,
								parent_grid = search_prompt_app_list_grid,
								app = app,
							}

							search_prompt_app_list_grid:add(app_widget)
						end
					end

					search_prompt_app_list_grid:emit_signal("widget::layout_changed")
					search_prompt_app_list_grid:emit_signal("widget::redraw_needed")
					--local top_matches_str = tts(search_prompt_app_list)
					--tmp_wibox.widget.markup = (top_matches_str)
					--tmp_wibox.widget.text = ("X")
					--tmp_wibox.widget.text = (top_matches_str)
					--tmp_wibox.widget:emit_signal("widget::layout_changed")
					--tmp_wibox.widget:emit_signal("widget::redraw_needed")
					--notify(tmp_wibox.widget.text)
					--notify(found_app.Name, 0.5)
				end,
			}
		end

		local search_prompt_widget = wibox.widget {
			{
				{
					search_prompt_textbox,
					left   = util.scale(8),
					right  = util.scale(8),
					widget = wibox.container.margin,
				},
				bg = beautiful.bg_normal,
				fg = beautiful.fg_normal,
				shape = function(cr, w, h)
					gears.shape.rounded_rect(cr, w, h, util.scale(10))
				end,
				widget = wibox.container.background,
			},
			left   = util.scale(10),
			right  = util.scale(10),
			bottom = util.scale(10),
			widget = wibox.container.margin,
		}

		-- TODO: Link the search with the app list and fzy

		function rasti_menu_wibox:show()
			self.visible = true
			rasti_menu_wibox_subwidgets.current_app_list_widget:change_category(category_names[1])
			search_prompt()
		end

		function rasti_menu_wibox:hide()
			self.visible = false
			-- This sucks, but there's no better solution right now,
			-- see https://stackoverflow.com/a/67381002
			--keygrabber.stop()
			if search_prompt_is_running then
				local char = "Escape"
				root.fake_input("key_press",   char)
				root.fake_input("key_release", char)
				search_prompt_is_running = false
			end
			search_prompt_textbox.text = ""
		end

		function rasti_menu_wibox:toggle()
			if self.visible then
				rasti_menu_wibox:hide()
			else
				rasti_menu_wibox:show()
			end
		end

		awful.placement.bottom_left(rasti_menu_wibox, { margins = util.scale(5), honor_workarea = true })

		rasti_menu_wibox_subwidgets.categories = {}
		rasti_menu_wibox_subwidgets.app_lists = {}

		rasti_menu_wibox_subwidgets.category_switcher_grid = wibox.widget {
			homogeneous = true,
			expand      = true,
			orientation = "vertical",
			spacing     = util.scale(5),
			min_cols_size = util.scale(160),
			forced_width = util.scale(160),
			--min_rows_size = util.scale(50),
			layout      = wibox.layout.grid,
		}

		for _, category in ipairs(items) do
			--if _ghfjd < 3 then
			--	_ghfjd = _ghfjd + 1
			--	notify(ttss(category[2][1]), 0)
			--end
			local name, category_apps, icon = category[1], category[2], menubar_utils.lookup_icon(category[3] or "") or nil

			local app_list_widget_grid = wibox.widget {
				homogeneous = true,
				expand      = true,
				orientation = "vertical",
				spacing     = util.scale(5),
				layout      = wibox.layout.grid,
			}

			for _, app in pairs(category_apps) do
				local app_name, app_cmd, app_icon = app[1], app[2], menubar_utils.lookup_icon(app[3] or "") or nil

				--[[
				local app_widget_icon
				if app_icon then
					app_widget_icon = wibox.widget {
						{
							image  = app_icon,
							widget = wibox.widget.imagebox,
						},
						right  = util.scale(10),
						widget = wibox.container.margin,
					}
				end

				local app_widget = wibox.widget {
					{
						{
							app_widget_icon,
							{
								text   = app_name,
								halign = "left",
								valign = "center",
								widget = wibox.widget.textbox,
							},
							forced_height = util.scale(35),
							layout        = wibox.layout.fixed.horizontal,
						},
						margins = util.scale(5),
						widget  = wibox.container.margin,
					},
					shape  = function(cr, w, h)
						gears.shape.rounded_rect(cr, w, h, util.scale(10))
					end,
					widget = wibox.container.background,
				}

				buttonify {
					app_widget,
					button_callback_release = function(w, b)
						if b == 1 then
							awful.spawn(app_cmd)
							rasti_menu_wibox:hide()
						elseif b == 4 or b == 5 then
							for _, child in pairs(app_list_widget_grid.children) do
								child.widget.bg = gears.color.transparent
							end
						end
					end,
				}
				--]]

				local app_widget = create_app_entry {
					name = app_name,
					icon = app_icon,
					cmd = app_cmd,
					parent_grid = app_list_widget_grid,
					app = app.app,
				}

				app_list_widget_grid:add(app_widget)
			end

			local app_list_widget = wibox.widget {
				app_list_widget_grid,
				layout = wibox.layout.overflow.vertical,
			}
			--app_list_widget_grid:set_step(40)

			rasti_menu_wibox_subwidgets.app_lists[name] = app_list_widget_grid

			local category_widget_icon
			if icon then
				category_widget_icon = wibox.widget {
					{
						image  = icon,
						widget = wibox.widget.imagebox,
					},
					right  = util.scale(10),
					widget = wibox.container.margin,
				}
			end

			rasti_menu_wibox_subwidgets.categories[name] = wibox.widget {
				{
					{
						category_widget_icon,
						{
							text   = name,
							halign = "left",
							valign = "center",
							widget = wibox.widget.textbox,
						},
						forced_height = util.scale(25),
						layout        = wibox.layout.fixed.horizontal,
					},
					margins = util.scale(5),
					widget  = wibox.container.margin,
				},
				shape  = function(cr, w, h)
					gears.shape.rounded_rect(cr, w, h, util.scale(10))
				end,
				widget = wibox.container.background,
			}

			buttonify {
				rasti_menu_wibox_subwidgets.categories[name],
				auto_set_bg           = false,
				button_color_normal   = util.default(beautiful.button_hover, beautiful.accent_primary_darker),
				button_callback_hover = function(w)
					for k, v in pairs(rasti_menu_wibox_subwidgets.categories) do
						v.bg = util.default(beautiful.button_normal,  beautiful.accent_primary_dark, gears.color.transparent)
					end

					rasti_menu_wibox_subwidgets.current_app_list_widget:change_category(name)
				end,
			}

			rasti_menu_wibox_subwidgets.category_switcher_grid:add(rasti_menu_wibox_subwidgets.categories[name])
		end

		rasti_menu_wibox_subwidgets.category_switcher = wibox.widget {
			{
				{
					{
						rasti_menu_wibox_subwidgets.category_switcher_grid,
						layout = wibox.layout.overflow.vertical,
					},
					margins = util.scale(8),
					widget  = wibox.container.margin,
				},
				bg     = beautiful.bg_normal,
				fg     = beautiful.fg_normal,
				shape  = function(cr, w, h)
					gears.shape.rounded_rect(cr, w, h, util.scale(10))
				end,
				widget = wibox.container.background,
			},
			margins = util.scale(10),
			widget  = wibox.container.margin,
		}
		--rasti_menu_wibox_subwidgets.category_switcher.widget:set_step(40)

		rasti_menu_wibox_subwidgets.current_app_list_widget = wibox.widget {
			rasti_menu_wibox_subwidgets.app_lists[category_names[1]],
			layout = wibox.layout.overflow.vertical,
		}
		--rasti_menu_wibox_subwidgets.current_app_list_widget:set_step(40)

		rasti_menu_wibox_subwidgets.current_app_list = wibox.widget {
			{
				{
					rasti_menu_wibox_subwidgets.current_app_list_widget,
					margins = util.scale(8),
					widget  = wibox.container.margin,
				},
				bg     = beautiful.bg_normal,
				fg     = beautiful.fg_normal,
				shape  = function(cr, w, h)
					gears.shape.rounded_rect(cr, w, h, util.scale(10))
				end,
				widget = wibox.container.background,
			},
			margins = util.scale(10),
			widget  = wibox.container.margin,
		}

		---@param category_name string
		function rasti_menu_wibox_subwidgets.current_app_list_widget:change_category(category_name)
			self._current_app_category = category_name

			if category_name == "_search" then
				self.children[1] = wibox.widget {
					search_prompt_app_list_grid,
					layout = wibox.layout.overflow.vertical,
				}
				self:emit_signal("widget::layout_changed")
				self:emit_signal("widget::redraw_needed")
				return
			end

			self.children[1] = wibox.widget {
				rasti_menu_wibox_subwidgets.app_lists[category_name],
				layout = wibox.layout.overflow.vertical,
			}
			self:emit_signal("widget::layout_changed")
			self:emit_signal("widget::redraw_needed")
		end

		rasti_menu_wibox_subwidgets.power_menu_button = wibox.widget {
			{
				{
					image  = "/usr/share/icons/Papirus-Dark/symbolic/actions/system-shutdown-symbolic.svg", --menubar_utils.lookup_icon("system-shutdown"),
					widget = wibox.widget.imagebox,
				},
				margins = util.scale(5),
				widget  = wibox.container.margin,
			},
			shape  = function(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, util.scale(4))
			end,
			forced_height = util.scale(40),
			widget = wibox.container.background,
		}

		rasti_menu_wibox_subwidgets.power_menu_options = wibox.widget {
			{
				{
					image  = menubar_utils.lookup_icon("arrow-right") or "/usr/share/icons/Papirus-Dark/24x24/actions/arrow-right.svg",
					widget = wibox.widget.imagebox,
				},
				margins = util.scale(5),
				widget  = wibox.container.margin,
			},
			shape  = function(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, util.scale(4))
			end,
			forced_height = util.scale(40),
			widget = wibox.container.background,
		}

		--t.menu_submenu_icon

		rasti_menu_wibox_subwidgets.power_menu = wibox.widget {
			{
				{
					{
						rasti_menu_wibox_subwidgets.power_menu_button,
						right  = util.scale(1),
						widget = wibox.container.margin,
					},
					rasti_menu_wibox_subwidgets.power_menu_options,
					layout = wibox.layout.fixed.horizontal
				},
				shape  = function(cr, w, h)
					gears.shape.rounded_rect(cr, w, h, util.scale(10))
				end,
				widget = wibox.container.background,
			},
			right  = util.scale(10),
			bottom = util.scale(10),
			widget = wibox.container.margin,
		}

		local power_menu = awful.menu {
			items = {
				{ "Lock session", "xdg-screensaver lock",           menubar_utils.lookup_icon("system-lock-screen") }, -- loginctl lock-session
				{ "Shutdown",     "gnome-session-quit --power-off", menubar_utils.lookup_icon("system-shutdown") },
				{ "Reboot",       "gnome-session-quit --reboot",    menubar_utils.lookup_icon("system-reboot") },
				{ "Suspend",      "systemctl suspend",              menubar_utils.lookup_icon("system-suspend") },
				{ "Hibernate",    "systemctl hibernate",            menubar_utils.lookup_icon("system-hibernate") },
				{ "Log out",      "gnome-session-quit --logout",    menubar_utils.lookup_icon("system-log-out") },
			},
		}

		buttonify {
			rasti_menu_wibox_subwidgets.power_menu_button,
			button_callback_release = function(w, b)
				if b == 1 then
					power_menu:toggle()
				elseif b == 3 then
					power_menu:toggle()
				end
			end,
		}

		buttonify {
			rasti_menu_wibox_subwidgets.power_menu_options,
			button_callback_release = function(w, b)
				power_menu:toggle()
			end,
		}

		rasti_menu_wibox_subwidgets.terminal = wibox.widget {
			{
				{
					image  = "/usr/share/icons/Papirus-Dark/symbolic/apps/utilities-terminal-symbolic.svg", --menubar_utils.lookup_icon("system-shutdown"),
					widget = wibox.widget.imagebox,
				},
				margins = util.scale(5),
				widget  = wibox.container.margin,
			},
			shape  = function(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, util.scale(10))
			end,
			forced_height = util.scale(40),
			widget = wibox.container.background,
		}

		buttonify {
			rasti_menu_wibox_subwidgets.terminal,
			button_callback_release = function(w, b)
				awful.spawn(globals.terminal or terminal or "xterm")
				rasti_menu_wibox:hide()
			end,
		}

		rasti_menu_wibox.user_info = wibox.widget {
			{
				{
					{
						{
							{
								id         = "user-pfp-role",
								align      = "left",
								clip_shape = gears.shape.circle,
								widget     = wibox.widget.imagebox,
							},
							shape              = gears.shape.circle,
							shape_border_width = util.scale(1),
							shape_border_color = "#808080",
							widget             = wibox.container.background,
						},
						{
							{
								orientation = "vertical",
								forced_width = util.scale(1),
								widget = wibox.widget.separator,
							},
							left   = util.scale(8),
							right  = util.scale(8),
							widget = wibox.container.margin
						},
						{
							id     = "user-name-role",
							font   = "Source Sans Pro, Semibold 20",
							align  = "left",
							valign = "center",
							widget = wibox.widget.textbox,
						},
						layout = wibox.layout.fixed.horizontal,
					},
					margins = util.scale(8),
					widget  = wibox.container.margin
				},
				shape = function(cr, w, h)
					gears.shape.rounded_rect(cr, w, h, util.scale(10))
				end,
				bg = beautiful.bg_normal,
				fg = beautiful.fg_normal,
				forced_height = util.scale(60),
				widget = wibox.container.background,
			},
			margins = util.scale(10),
			widget = wibox.container.margin
		}

		for _, child in ipairs(rasti_menu_wibox.user_info:get_children_by_id("user-pfp-role")) do
			local pfp

			awful.spawn.easy_async_with_shell([[getent passwd "${USER:-$(whoami)}" | cut -d ':' -f 5 | cut -d ',' -f 1]], function(stdout, stderr, reason, exit_code)
				local initials = "NaN"
				if stdout and not stdout:match("^%s*$") then
					initials = get_initials(stdout:gsub("\n", ""))
				end
				child.image =  wibox.widget.draw_to_image_surface(wibox.widget {
					{
						text   = initials,
						font   = "Source Sans Pro, Bold 20",
						align  = "center",
						widget = wibox.widget.textbox,
					},
					bg = gears.color {
						type  = "linear",
						from  = { 0,  0 },
						to    = { 0, util.scale(60) },
						stops = { { 0, "#FFFFFF40" }, { 1, "#00000040" } },
					},
					widget = wibox.container.background,
				}, util.scale(60), util.scale(60))
			end)

			--child.image = beautiful.awesome_icon
		end

		for _, child in ipairs(rasti_menu_wibox.user_info:get_children_by_id("user-name-role")) do
			--awful.spawn.easy_async({ "whoami" }, function(stdout, stderr, reason, exit_code)
			awful.spawn.easy_async_with_shell([[getent passwd "${USER:-$(whoami)}" | cut -d ':' -f 5 | cut -d ',' -f 1]], function(stdout, stderr, reason, exit_code)
				local full_name = (stdout or "NAME NOT FOUND"):gsub("\n", "")
				child.text = full_name
			end)
		end

		rasti_menu_wibox.widget = wibox.widget {
			{
				{
					rasti_menu_wibox.user_info,
					--nil,
					{
						-- App view, categories
						nil,
						rasti_menu_wibox_subwidgets.current_app_list,
						rasti_menu_wibox_subwidgets.category_switcher,
						layout = wibox.layout.align.horizontal,
					},
					{
						-- Search bar, power menu
						search_prompt_widget,
						nil,
						{
							{
								rasti_menu_wibox_subwidgets.terminal,
								right  = util.scale(1),
								bottom = util.scale(10),
								widget = wibox.container.margin,
							},
							rasti_menu_wibox_subwidgets.power_menu,
							layout = wibox.layout.fixed.horizontal,
						},
						layout = wibox.layout.align.horizontal,
					},
					layout = wibox.layout.align.vertical,
				},
				margins = util.scale(0),
				widget  = wibox.container.margin,
			},
			bg    = beautiful.color.black.."C0",
			shape = function(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, util.scale(20))
			end,
			shape_border_width = beautiful.border_width,
			shape_border_color = beautiful.border_color_active,
			widget = wibox.container.background,
		}

		awesome.connect_signal("slimeos::toggle_launcher", function(s) ---@param s screen
			if s == args.screen then
				rasti_menu_wibox:toggle()
			end
		end)

		if args.auto_close then
			rasti_menu_wibox:connect_signal("mouse::leave", function()
				rasti_menu_wibox:hide()
			end)
		end
	end)
end

return setmetatable({
	category_launcher = category_launcher,
	flexi_launcher = flexi_launcher
}, {
	__call = function(self, ...)
		return self.category_launcher(...)
	end,
})
