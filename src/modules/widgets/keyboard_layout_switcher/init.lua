---@author: SkyyySi 2022-04-23 23:42:36
local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local util      = require("modules.lib.util")
local globals   = require("modules.lib.globals")
local buttonify = require("modules.lib.buttonify")
local beautiful = require("beautiful")

---@class Args
---@field enabled_layouts string[]?
---@field color_normal string?
---@field color_hover string?
---@field color_press string?
---@field color_release string?

---@param layouts string[]
---@return string[][]
local function build_menu_from_layouts(layouts)
	local out = {}

	for i, v in pairs(layouts) do
		out[i] = { v }
	end

	return out
end

---@param args Args
local function main(args)
	args.enabled_layouts = util.default(args.enabled_layouts, globals.enabled_layouts, { "us" })
	args.color_normal    = util.default(args.color_normal, beautiful.button_normal)
	args.color_hover     = util.default(args.color_hover, beautiful.button_enter)
	args.color_press     = util.default(args.color_press, beautiful.button_press)
	args.color_release   = util.default(args.color_release, beautiful.button_release)

	awful.spawn { "setxkbmap", args.enabled_layouts[1] }

	local layouts_popup = awful.menu(util.map_array(args.enabled_layouts, function(layout)
		return { layout }
	end))

	local bar_widget = wibox.widget {
		awful.widget.keyboardlayout,
		widget = wibox.container.background,
	}

	buttonify {
		bar_widget,
		button_callback_release = function(w, b)
			if b == 1 then
				layouts_popup:toggle()
			end
		end
	}

	return bar_widget
end

return main
