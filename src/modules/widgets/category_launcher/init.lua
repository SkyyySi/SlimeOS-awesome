local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local menubar   = require("menubar")
local menubar_utils = require("modules.widgets.dock.menubar_utils")
local wibox_layout_overflow = require("wibox_layout_overflow")

local buttonify = require("modules.lib.buttonify")
local util      = require("modules.lib.util")
local tts = util.table_to_string
local ttss = util.table_to_string_simple


local all_apps, all_apps_mt = {}, { is_generated = false }
all_apps_mt.__index = all_apps_mt
setmetatable(all_apps, all_apps_mt)
function all_apps_mt:update(fn)
	if self.is_generated then
		self.is_generated = false
		for k, v in pairs(self) do
			self[k] = nil
		end
	end

	menubar_utils.parse_dir("/usr/share/applications", function(system_apps)
		menubar_utils.parse_dir(os.getenv("HOME").."/.local/share/applications", function(user_apps)
			local apps = {}
			local sorted_app_names = {}

			for k, v in ipairs(system_apps) do
				sorted_app_names[#sorted_app_names + 1] = k
				apps[#apps + 1] = v
			end

			for k, v in ipairs(user_apps) do
				sorted_app_names[#sorted_app_names + 1] = k
				apps[#apps + 1] = v
			end

			-- TODO: Remove apps with .NoDisplay = true

			table.sort(sorted_app_names)

			local tmp = {}
			for _, k in ipairs(sorted_app_names) do
				table.insert(tmp, apps[k])
			end
			for k, v in ipairs(tmp) do
				local do_insert = true
				for k2, v2 in pairs(self) do
					if v == v2 then
						do_insert = false
					end
				end
				if do_insert then
					table.insert(self, v)
				end
			end

			getmetatable(self).is_generated = true

			local dump_table = {}
			for _, app in pairs(self) do
				dump_table[#dump_table+1] = app.Name
			end
			util.dump_to_file(tts(apps), "/tmp/apps.lua")

			fn(self)
		end)
	end)
end

function all_apps_mt:filter(pattern)
	local matches = {}
	setmetatable(matches, getmetatable(self))

	for k, v in pairs(self) --[[ or (v.Comment ~= nil and v.Comment:match(pattern)) ]] do
		if (v.Name ~= nil and v.Name:match(pattern)) then
			table.insert(matches, v)
		end
	end

	return matches
end

function all_apps_mt:run(fn)
	if not self.is_generated then
		self:update(fn)
	else
		fn(self)
	end
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

all_apps_mt.category_id_map = setmetatable({
	All         = "applications-all",
	Favorites   = "applications-featured",
	Recent      = "history",

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

menubar.menu_gen.generate(function(menu)
	util.dump_to_file(tts(menu), "/tmp/menu.lua")
end)

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

local function category_launcher(args)
	args = util.default(args, {})
	args = {
		screen = util.default(args.screen, screen.primary),
	}

	-- TODO: Switch away from automatic category detection and use https://specifications.freedesktop.org/menu-spec/latest/apa.html instead

	all_apps:run(function(apps)
		util.dump_to_file(tts(apps), "/tmp/apps.lua")
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
			end

			app.category = app.category or "Other"

			--categorized_apps[app.category][#(categorized_apps[app.category]) + 1] = app
		end
		table.sort(category_names)

		util.dump_to_file(tts(category_names), "/tmp/category_names.lua")

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
				table.insert(subm, { app.Name, cmd, app.Icon })
			end

			-- TODO Add a proper categorization
			local category_icon -- = menubar_utils.lookup_icon("applications-"..category)

			items[k] = { category, subm, category_icon }
		end

		util.dump_to_file(tts(items), "/tmp/items.lua")

		local rasti_menu_wibox = wibox {
			width   = util.scale(500),
			height  = util.scale(600),
			ontop   = true,
			visible = false,
			screen  = args.screen,
			bg      = gears.color.transparent,
			shape   = function(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, util.scale(20))
			end,
		}

		function rasti_menu_wibox:toggle()
			self.visible = not self.visible
		end

		awful.placement.bottom_left(rasti_menu_wibox, { margins = util.scale(5), honor_workarea = true })

		local rasti_menu_wibox_subwidgets = {}
		rasti_menu_wibox_subwidgets.categories = {}
		rasti_menu_wibox_subwidgets.app_lists = {}

		rasti_menu_wibox_subwidgets.category_switcher_grid = wibox.widget {
			homogeneous = true,
			expand      = false,
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
				expand      = false,
				orientation = "vertical",
				spacing     = util.scale(5),
				layout      = wibox.layout.grid,
			}

			for _, app in pairs(category_apps) do
				local app_name, app_cmd, app_icon = app[1], app[2], menubar_utils.lookup_icon(app[3] or "") or nil

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
							rasti_menu_wibox:toggle()
						end
					end,
				}

				app_list_widget_grid:add(wibox.widget {
					app_widget,
					right  = util.scale(10),
					widget = wibox.container.margin,
				})
			end

			local app_list_widget = wibox.widget {
				app_list_widget_grid,
				layout = wibox_layout_overflow.vertical,
			}

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
				rasti_menu_wibox_subwidgets.category_switcher_grid,
				layout = wibox_layout_overflow.vertical,
			},
			margins = util.scale(10),
			widget  = wibox.container.margin,
		}

		rasti_menu_wibox_subwidgets.current_app_list_widget = wibox.widget {
			rasti_menu_wibox_subwidgets.app_lists[category_names[1]],
			layout = wibox_layout_overflow.vertical,
		}

		rasti_menu_wibox_subwidgets.current_app_list = wibox.widget {
			rasti_menu_wibox_subwidgets.current_app_list_widget,
			margins = util.scale(10),
			widget  = wibox.container.margin,
		}

		---@param category_name string
		function rasti_menu_wibox_subwidgets.current_app_list_widget:change_category(category_name)
			self.children[1] = wibox.widget {
				rasti_menu_wibox_subwidgets.app_lists[category_name],
				layout = wibox_layout_overflow.vertical,
			}
			self:emit_signal("widget::layout_changed")
			self:emit_signal("widget::redraw_needed")
		end

		rasti_menu_wibox_subwidgets.power_menu_button = wibox.widget {
			{
				{
					image  = menubar_utils.lookup_icon("system-shutdown"),
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
				{ "Lock session", "xdg-screensaver lock", menubar_utils.lookup_icon("system-lock-screen") }, -- loginctl lock-session
				{ "Shutdown",     "sudo poweroff",        menubar_utils.lookup_icon("system-shutdown") },
				{ "Reboot",       "sudo reboot",          menubar_utils.lookup_icon("system-reboot") },
				{ "Suspend",      "systemctl suspend",    menubar_utils.lookup_icon("system-suspend") },
				{ "Hibernate",    "systemctl hibernate",  menubar_utils.lookup_icon("system-hibernate") },
				{ "Log out",      function() awesome.exit() end, menubar_utils.lookup_icon("system-log-out") },
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

		rasti_menu_wibox.widget = wibox.widget {
			{
				{
					nil,
					{
						-- App view, categories
						nil,
						rasti_menu_wibox_subwidgets.current_app_list,
						rasti_menu_wibox_subwidgets.category_switcher,
						layout = wibox.layout.align.horizontal,
					},
					{
						-- Search bar, power menu
						nil,
						nil,
						rasti_menu_wibox_subwidgets.power_menu,
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
	end)
end

return category_launcher