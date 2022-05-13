#!/usr/bin/env lua
local gears         = require("gears")
local wibox         = require("wibox")
local awful         = require("awful")
local beautiful     = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")
local globals       = require("modules.lib.globals")
local naughty       = require("naughty")
local util          = require("modules.lib.util")

local function icon_button(args)
end

local function main(args)
	args = {
		categories_placement = util.default(args.categories_placement, "left"), ---@type string "top"|"bottom"|"left"|"right"
		item_spacing         = util.default(args.item_spacing, util.scale(10)), ---@type number
		item_size            = util.default(args.item_size, util.scale(60)), ---@type number
	}

	local icon_grid = wibox.widget {
		homogeneous   = true,
		spacing       = util.scale(10),
		min_cols_size = util.scale(60),
		min_rows_size = util.scale(60),
		expand        = true,
		layout        = wibox.layout.grid,
	}

	local categories = wibox.widget {}

	local main_widget = wibox.widget {}
end

return main
