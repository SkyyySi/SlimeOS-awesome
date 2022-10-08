local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local util  = require("modules.lib.util")
local beautiful = require("beautiful")

local lgi   = require("lgi")
local cairo = lgi.cairo

local bling = require("modules.external.bling")

local tasklist = { mt = {} }
tasklist.mt.__index = tasklist.mt
setmetatable(tasklist, tasklist.mt)

function tasklist.preview(args)
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
		bling.widget.task_preview.enable {
			height = task_preview_geometry.height,
			width  = task_preview_geometry.width,
			placement_fn = function(c)
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
	end

	local buttons = {
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
							id     = "clienticon",
							align  = "center",
							widget = awful.widget.clienticon,
						},
						bg                 = "#F8F8F2",
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
					from  = { util.scale(19), util.scale(21), util.scale(12) },
					to    = { util.scale(19), util.scale(21), util.scale(16) },
					stops = { { 0, "#000000A0" }, { 1/3, "#00000070" }, { 2/3, "#00000030" }, { 1, "#0000" } }
				  },
				widget = wibox.container.background,
			},
			create_callback = function(self, c, index, objects)
				self:get_children_by_id("clienticon")[1].client = c

				self:connect_signal("mouse::enter", function()
					geometry = mouse.current_widget_geometry
					geometry.x = geometry.x + geometry.width/2  - task_preview_geometry.width/2
					geometry.y = geometry.y + geometry.height/2 - task_preview_geometry.height/2
					awesome.emit_signal("bling::task_preview::visibility", args.screen, true, c)
				end)
				self:connect_signal("mouse::leave", function()
					awesome.emit_signal("bling::task_preview::visibility", args.screen, false, c)
				end)
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
