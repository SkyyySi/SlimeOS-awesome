#!/usr/bin/env lua
---@author: SkyyySi 2022-04-23 23:42:36
local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local util      = require("modules.lib.util")
local globals   = require("modules.lib.globals")
local beautiful = require("beautiful")

---@class Args
---@field enabled_layouts string[]?
---@field color_normal string?
---@field color_hover string?
---@field color_press string?
---@field color_release string?

notify(type(gears.color))

---@param args Args
local function main(args)
	args.enabled_layouts = util.default(args.enabled_layouts, globals.enabled_layouts or {"us"})
	args.color_normal    = util.default(args.color_normal,    beautiful.button_normal)
	args.color_hover     = util.default(args.color_hover,     beautiful.button_enter)
	args.color_press     = util.default(args.color_press,     beautiful.button_press)
	args.color_release   = util.default(args.color_release,   beautiful.button_release)

	local bar_widget = wibox.widget {
		awful.widget.keyboardlayout,
		widget = wibox.container.background,
	}
end

return main
