#!/usr/bin/env lua
local gears   = require("gears")
local awful   = require("awful")
local wibox   = require("wibox")
local ruled   = require("ruled")
local naughty = require("naughty")

local util = {}

function util.script_path()
	return debug.getinfo(2, "S").source:sub(2):match("(.*/)")
end

return util
