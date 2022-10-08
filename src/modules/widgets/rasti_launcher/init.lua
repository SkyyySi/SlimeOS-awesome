local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local wibox_layout_overflow = require("wibox_layout_overflow")
local buttonify = require("modules.lib.buttonify")
local util      = require("modules.lib.util")
local tts = util.table_to_string
local ttss = util.table_to_string_simple

--- This function returns a table which will be asynchronously populated with
--- the actual menu widget.
local function main(args)
	local rasti_launcher = {}

	return rasti_launcher
end

local rasti_launcher = { mt = {} }
rasti_launcher.mt.__index = rasti_launcher.mt
setmetatable(rasti_launcher, rasti_launcher.mt)

function rasti_launcher.mt:__call(...)
	return main(...)
end

rasti_launcher.utils = require("modules.widgets.rasti_launcher.utils")

return rasti_launcher
