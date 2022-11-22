local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local util  = require("modules.lib.util")
local buttonify  = require("modules.lib.buttonify")
local beautiful = require("beautiful")

local lgi   = require("lgi")
local cairo = lgi.cairo

local bling = require("modules.external.bling")

local app_title_map = {}
local app_icon_map = {}
local app_desktop_map = {}
local function update_app_maps(cb)
	awesome.emit_signal("all_apps::get", function(all_apps)
		if not all_apps then
			return
		end

		for _, app in pairs(all_apps) do
			local desktop_file
			if app.file then
				desktop_file = app.file:gsub("^.*/", ""):match("(.*)%.desktop$")
			end

			local class = app.StartupWMClass or desktop_file

			if class then
				app_title_map[class]   = app_title_map[class]   or app.Name      or "???"
				app_icon_map[class]    = app_icon_map[class]    or app.icon_path or beautiful.awesome_icon
				app_desktop_map[class] = app_desktop_map[class] or app.file
			end
		end

		cb(all_apps)
	end)
end

local tasklist = { mt = {} }
tasklist.mt.__index = tasklist.mt
setmetatable(tasklist, tasklist.mt)

function tasklist.preview(c, args)
	args = util.default(args, {})
	args = {
		screen = util.default(args.screen, screen.primary),
	}

	local content = nil
	if c.active then
		content = gears.surface(c.content)
	elseif c.prev_content then
		content = gears.surface(c.prev_content)
	end

	local img = nil
	if content ~= nil then
		local cr = cairo.Context(content)
		local x, y, w, h = cr:clip_extents()
		img = cairo.ImageSurface.create(cairo.Format.ARGB32, w - x, h - y)
		cr = cairo.Context(img)
		cr:set_source_surface(content, 0, 0)
		cr.operator = cairo.Operator.SOURCE
		cr:paint()
	end

	local function widget_placer(c)
		awful.placement.next_to(c, {
			honor_workarea = true,
			screen   = args.screen,
			geometry = geometry,
			margins  = {
				bottom = util.scale(5)
			},
		})
	end

	local widget = wibox.widget({
		{
			{
				id     = "icon_role",
				resize = true,
				forced_height = util.scale(20),
				forced_width  = util.scale(20),
				widget = wibox.widget.imagebox,
			},
			{
				{
					id     = "name_role",
					align  = "center",
					widget = wibox.widget.textbox,
				},
				left   = util.scale(4),
				right  = util.scale(4),
				widget = wibox.container.margin,
			},
			layout = wibox.layout.align.horizontal,
		},
		{
			id     = "image_role",
			resize = true,
			widget = wibox.widget.imagebox,
		},
		fill_space = true,
		layout     = wibox.layout.fixed.vertical,
	})

	for _, w in ipairs(widget:get_children_by_id("image_role")) do
		w.image = img -- TODO: copy it with gears.surface.xxx or something
	end

	for _, w in ipairs(widget:get_children_by_id("name_role")) do
		w.text = c.name
	end

	for _, w in ipairs(widget:get_children_by_id("icon_role")) do
		w.image = c.icon -- TODO: detect clienticon
	end

	local box = wibox {
		widget = widget,
	}

	return box
end

function tasklist:new(args)
	local geometry

	args = util.default(args, {})
	args = {
		screen = util.default(args.screen, screen.primary),
	}

	local task_button_geometry, task_button_screen
	local task_preview_geometry = {
		height = util.scale(200),
		width  = util.scale(200),
	}

	if not _SLIMEOS_BLING_TASK_PREVIEW_ALREADY_ACTIVATED then
		_SLIMEOS_BLING_TASK_PREVIEW_ALREADY_ACTIVATED = true

		--- The shape function for the popup
		---@param cr cairo_surface
		---@param w number Widget width
		---@param h number Widget height
		local function popup_shape(cr, w, h)
			local corner_radius  = util.scale(5)
			local arrow_size     = util.scale(10)
			local arrow_position = w / 2 - arrow_size / 1
			(gears.shape.transform(gears.shape.infobubble)
				:rotate_at(w/2, h/2, math.pi))(cr, w, h, corner_radius, arrow_size, arrow_position)
		end

		--- The shape function for the image of the client
		---@param cr cairo_surface
		---@param w number Widget width
		---@param h number Widget height
		local function client_image_shape(cr, w, h)
			local corner_radius  = util.scale(5)
			gears.shape.rounded_rect(cr, w, h, corner_radius)
		end

		local widget_bg = util.color.alter(beautiful.bg_normal, { a = 0.65 })

		--[== =[
		local space = util.scale(10)
		bling.widget.task_preview.enable {
			width  = task_preview_geometry.width,
			height = task_preview_geometry.height,
			container_shape = popup_shape,
			widget_template = {
				{
					{
						{
							{
								id     = "icon_role",
								resize = true,
								widget = wibox.widget.imagebox,
							},
							{
								id     = "name_role",
								widget = wibox.widget.textbox,
							},
							forced_height = util.scale(25),
							spacing = util.scale(4),
							layout = wibox.layout.fixed.horizontal,
						},
						{
							{
								id     = "image_role",
								resize = true,
								clip_shape = client_image_shape,
								widget = wibox.widget.imagebox,
							},
							shape = client_image_shape,
							shape_border_width = util.scale(1),
							shape_border_color = "#606060",
							widget = wibox.container.background,
						},
						fill_space = true,
						spacing    = util.scale(space),
						layout     = wibox.layout.fixed.vertical,
					},
					margins = {
						top = util.scale(10),
						bottom = util.scale(10 + 10),
						left = util.scale(10),
						right = util.scale(10),
					},
					widget  = wibox.container.margin,
				},
				bg =  widget_bg,
				shape  = popup_shape,
				shape_border_width = util.scale(1),
				shape_border_color = "#FFFFFF",
				widget = wibox.container.background,
			},
			placement_fn = function(c)
				if c.content or c._old_content then
					space = util.scale(10)
				else
					space = 0
				end

				awful.placement.next_to(c, {
					honor_workarea = true,
					screen   = args.screen,
					geometry = geometry,
					margins  = {
						bottom = util.scale(5)
					},
				})
			end,
		}
		--]===]
		--self:preview(c, args)
	end

	local right_click_menu = { {} }
	right_click_menu[2] = awful.menu { items = right_click_menu[1] }

	awesome.connect_signal("slimeos::tasklist::close_all_right_click_menus", function()
		right_click_menu[2]:hide()
	end)

	local buttons = {
		awful.button({}, 1, function(c) ---@param c client._instance
			c:activate { context = "tasklist", action = "toggle_minimization" }
		end),
		awful.button({}, 3, function(c) ---@param c client._instance
			awesome.emit_signal("slimeos::dock::favorites::get", function(favorites)
				update_app_maps(function(all_apps)
					local desktop_file = (app_desktop_map[c.class] or ""):gsub("^.*/", "")

					if not desktop_file or desktop_file == "" then
						awful.spawn.easy_async({ "readlink", "-f", "/proc/"..tostring(c.pid).."/exe" }, function(stdout, stderr, reason, exit_code)
							if not stdout or stdout == "" then
								return
							end

							--local i = 0
							for _, app in pairs(all_apps) do
								local app_exec = util.strip(app.Exec:match(".*/([^%s]*)") or app.Exec)
								local stdout_exec = util.strip(stdout:match(".*/(.*)") or stdout)
								--if i < 3 then
								--	i = i + 1
								--	notify(("%s -> %s"):format(app_exec, stdout_exec))
								--end
								if app_exec == stdout_exec then
									notify(("%s -> %s"):format(app_exec, stdout_exec))
									break
								end
							end
						end)
					end

					if favorites:has_favorite(desktop_file) then
						right_click_menu[1][1] = {
							"Remove from dock",
							function()
								awesome.emit_signal("slimeos::dock::favorites::remove", desktop_file)
							end
						}
					else
						right_click_menu[1][1] = {
							"Pin to dock",
							function()
								awesome.emit_signal("slimeos::dock::favorites::add", desktop_file)
							end
						}
					end
					--notify(c.class)
					--notify(app_desktop_map[c.class])
					--notify(desktop_file)
					--notify(right_click_menu[1][1][1] or "Unknown")

					awesome.emit_signal("slimeos::tasklist::close_all_right_click_menus")
					right_click_menu[2] = awful.menu { items = right_click_menu[1] }
					right_click_menu[2]:show()
				end)
			end)
			--awful.menu.client_list {
			--	theme = {
			--		width = 250,
			--	},
			--}
		end),
		awful.button({}, 4, function()
			awful.client.focus.byidx(-1)
		end),
		awful.button({}, 5, function()
			awful.client.focus.byidx(1)
		end),
	}

	local widget--[[ = awful.widget.tasklist {
		screen  = args.screen,
		filter  = awful.widget.tasklist.filter.currenttags,
		buttons = {
			awful.button({}, 1, function(c)
				c:activate { context = "tasklist", action = "toggle_minimization" }
			end),
			awful.button({}, 3, function()
				awful.menu.client_list {
					theme = {
						width = 250,
					},
				}
			end),
			awful.button({}, 4, function()
				awful.client.focus.byidx(-1)
			end),
			awful.button({}, 5, function()
				awful.client.focus.byidx(1)
			end),
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
				id      = "client_button",
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

	--local color_normal = beautiful.tasklist_bg_normal or beautiful.fg_normal           or "#F8F8F2"
	--local color_focus  = beautiful.tasklist_bg_normal or beautiful.border_color_active or "#BD93F9"

	widget = awful.widget.tasklist {
		screen   = args.screen,
		filter   = awful.widget.tasklist.filter.currenttags,
		buttons  = buttons,
		--layout   = {
		--	spacing = util.scale(4),
		--	spacing_widget = {
		--		valign = "center",
		--		halign = "center",
		--		widget = wibox.container.place,
		--	},
		--	layout  = wibox.layout.flex.horizontal,
		--},
		widget_template = {
			{
				{
					{
						{
							{
									{
									id     = "clienticon",
									align  = "center",
									widget = wibox.widget.imagebox,
								},
								id     = "background_role",
								widget = wibox.container.background,
							},
							shape              = gears.shape.circle,
							shape_border_width = util.scale(1),
							shape_border_color = "#F8F8F2",
							widget             = wibox.container.background,
						},
						margins = util.scale(4),
						widget  = wibox.container.margin,
					},
					bg = {
						type  = "radial",
						from  = { util.scale(19), util.scale(22), util.scale(12) },
						to    = { util.scale(20), util.scale(22), util.scale(16) },
						stops = { { 0, "#000000A0" }, { 1/3, "#00000070" }, { 2/3, "#00000030" }, { 1, "#0000" } }
					},
					widget = wibox.container.background,
				},
				{
					{
						id     = "effect_role",
						shape  = gears.shape.circle,
						widget = wibox.container.background,
					},
					margins = util.scale(1),
					widget  = wibox.container.margin,
				},
				layout = wibox.layout.stack,
			},
			create_callback = function(self, c, index, objects)
				for _, child in ipairs(self:get_children_by_id("effect_role")) do
					buttonify {
						widget = child,
					}

					if c.active then
						-- focused
						child.shape = function(cr, w, h)
							gears.shape.circle(cr, w, h)
						end
					else
						-- not focused
						child.shape = gears.shape.rectangle
					end
				end

				for _, child in ipairs(self:get_children_by_id("background_role")) do
					if c.active then
						-- focused
						child.shape = function(cr, w, h)
							gears.shape.circle(cr, w, h)
						end
					else
						-- not focused
						child.shape = gears.shape.rectangle
					end
				end

				local function update_client_icon()
					for _, child in pairs(self:get_children_by_id("clienticon")) do
						child.client = c
						child.image = app_icon_map[c.class] or c.icon or beautiful.awesome_icon
					end
				end

				update_client_icon()

				local old_cursor, old_wibox
				self:connect_signal("mouse::enter", function()
					local wb = mouse.current_wibox or {}
					old_cursor, old_wibox = wb.cursor, wb
					wb.cursor = "hand1"

					geometry = mouse.current_widget_geometry
					if geometry then
						geometry.x = geometry.x + geometry.width/2  - task_preview_geometry.width/2
						geometry.y = geometry.y + geometry.height/2 - task_preview_geometry.height/2
					end

					awesome.emit_signal("bling::task_preview::visibility", args.screen, true, c)
				end)
				self:connect_signal("mouse::leave", function()
					old_wibox.cursor = old_cursor
					old_wibox = nil

					--- TODO: Instead of instantly closing, we should instead queue the closing;
					--- We can then close it only when the cursor is NEITHER above the tasklist icon
					--- or the task preview. This can be used to, for example, add client media or
					--- volume controls to the preview.

					awesome.emit_signal("bling::task_preview::visibility", args.screen, false, c)
				end)

				update_app_maps(update_client_icon)
			end,
			layout = wibox.layout.align.vertical,
		},
	}

	--util.dump_to_file(util.table_to_string(widget, "\t"), "/tmp/widget.lua")
	--notify(widget:get_children_by_id("client_button")[1])
	--[[
	create_callback = function(self, c, index, objects)
		notify("Fire")
		self:get_children_by_id("clienticon")[1].client = c

		self:connect_signal("mouse::enter", function()
			notify("Foo")
			awesome.emit_signal("bling::task_preview::visibility", args.screen, true, c)
		end)
		self:connect_signal("mouse::leave", function()
			notify("Bar")
			awesome.emit_signal("bling::task_preview::visibility", args.screen, false, c)
		end)
	end,
	--]]

	return widget
end

function tasklist.mt:__call(...)
	return self:new(...)
end

--[[
if c.class == "Org.gnome.Nautilus" then
	local function update_img(c)
		local cairo = require("lgi").cairo

		local content = nil
		if c.active then
			content = gears.surface(c.content)
		elseif c.prev_content then
			content = gears.surface(c.prev_content)
		end

		local img = nil
		if content ~= nil then
			local cr = cairo.Context(content)
			local x, y, w, h = cr:clip_extents()
			img = cairo.ImageSurface.create(cairo.Format.ARGB32, w - x, h - y)
			cr = cairo.Context(img)
			cr:set_source_surface(content, 0, 0)
			cr.operator = cairo.Operator.SOURCE
			cr:paint()
		end

		return img
	end

	local imgbox = wibox.widget {
		resize = true,
		widget = wibox.widget.imagebox,
	}

	local wb = wibox {
		width  = util.scale(500),
		height = util.scale(500),
		visible = false,
		ontop = true,
		widget = {
			{
				imgbox,
				shape = function(cr, w, h)
					gears.shape.rounded_rect(cr, w, h, util.scale(10))
				end,
				shape_border_width = util.scale(2),
				widget = wibox.container.background,
			},
			margins = util.scale(10),
			widget = wibox.container.margin,
		}
	}

	imgbox.image = update_img(c)
	gears.timer {
		timeout = 0.5,
		autostart = true,
		callback = function()
			imgbox.image = update_img(c)
			c.prev_content = gears.surface.duplicate_surface(c.content)
			imgbox:emit_signal("widget::redraw_needed")
		end,
	}

	awful.placement.top_left(wb, { honor_workarea = true, margins = util.scale(20) })
end
--]]

return tasklist
