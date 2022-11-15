local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local bling = require("modules.external.bling")

local util = require("modules.lib.util")
local globals = require("modules.lib.globals")

--- The tag preview can be shared across all tasklists, so
--- there is no point in creating one for each `main()` call.
if not _SLIMEOS_BLING_TAG_PREVIEW_ALREADY_ACTIVATED then
	_SLIMEOS_BLING_TAG_PREVIEW_ALREADY_ACTIVATED = true

	bling.widget.tag_preview.enable {
		show_client_content = true,
		scale = 0.5,
		honor_padding = false,
		honor_workarea = false,
		placement_fn = function(c)
			awful.placement.centered(c, {
				margins = util.scale(10),
				honor_workarea = true,
			})
		end,
		background_widget = beautiful.wallpaper_widget,
	}
end

local function main(args)
	args = util.default(args, {})
	args.screen = util.default(args.screen, screen.primary)

	local widget = wibox.widget {
		beautiful.color.make_dynamic(wibox.widget {
			awful.widget.taglist {
				screen  = args.screen,
				filter  = awful.widget.taglist.filter.all,
				--style   = {
				--	shape = gears.shape.powerline
				--},
				--layout   = {
				--	spacing = -12,
				--	spacing_widget = {
				--		color  = "#dddddd",
				--		shape  = gears.shape.powerline,
				--		widget = wibox.widget.separator,
				--	},
				--	layout  = wibox.layout.fixed.horizontal
				--},
				widget_template = {
					{
						--{
						--	id     = "index_role",
						--	widget = wibox.widget.textbox,
						--},
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
					id     = "background_role",
					widget = wibox.container.background,
					-- Add support for hover colors and an index label
					create_callback = function(self, c3, index, objects)
						local old_cursor, old_wibox

						for _, child in pairs(self:get_children_by_id("index_role")) do
							child.markup = index
						end

						self:connect_signal("mouse::enter", function()
							-- BLING: Only show widget when there are clients in the tag
							if #c3:clients() > 0 then
								-- BLING: Update the widget with the new tag
								awesome.emit_signal("bling::tag_preview::update", c3)
								-- BLING: Show the widget
								awesome.emit_signal("bling::tag_preview::visibility", args.screen, true)
							end

							if self.bg ~= "#ff0000" then
								self.backup     = self.bg
								self.has_backup = true
							end

							self.bg = "#ff0000"

							local wb = mouse.current_wibox or {}
							old_cursor, old_wibox = wb.cursor, wb
							wb.cursor = "hand1"
						end)

						self:connect_signal("mouse::leave", function()
							-- BLING: Turn the widget off
							awesome.emit_signal("bling::tag_preview::visibility", args.screen, false)

							if self.has_backup then
								self.bg = self.backup
							end

							old_wibox.cursor = old_cursor
							old_wibox = nil
						end)

						self:connect_signal("button::press", function(_,_,_, b)
							awesome.emit_signal("bling::tag_preview::visibility", args.screen, false)
						end)
					end,
					update_callback = function(self, c3, index, objects)
						for _, child in pairs(self:get_children_by_id("index_role")) do
							child.markup = index
						end
					end,
				},
				buttons = {
					awful.button({}, 1, function(t) t:view_only() end),
					awful.button({ globals.modkey }, 1, function(t)
						if client.focus then
							client.focus:move_to_tag(t)
						end
					end),
					awful.button({}, 3, awful.tag.viewtoggle),
					awful.button({ globals.modkey }, 3, function(t)
						if client.focus then
							client.focus:toggle_tag(t)
						end
					end),
					awful.button({}, 4, function(t) awful.tag.viewprev(t.screen) end),
					awful.button({}, 5, function(t) awful.tag.viewnext(t.screen) end),
				},
			},
			bg                 = "#FFFFFF10",
			shape              = gears.shape.rounded_bar,
			shape_border_color = "#FFFFFF20",
			shape_border_width = util.scale(1),
			widget             = wibox.container.background,
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
		widget  = wibox.container.margin,
	}

	return widget
end

return main
