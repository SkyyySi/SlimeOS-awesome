#!/usr/bin/env lua
local gears      = require("gears")
local awful      = require("awful")
local wibox      = require("wibox")
local ruled      = require("ruled")
local naughty    = require("naughty")
local globals    = require("modules.lib.globals")
local xresources = require("beautiful.xresources")

local util = {}

-- Converts any type into a boolean, in the same way
--- ```
--- if x then
--- ```
--- does (because this function is just a wrapper for that).
---@param x any
---@return boolean
function util.tobool(x)
	if x then
		return true
	end

	return false
end

--- Returns `value` it it is not nil, otherwise returns `default`.
function util.default(value, default)
	if value == nil then
		return default
	end

	return value
end

-- When runing as a script, this function will return the path
--- where it is located.
---
--- Based on [this StackOverflow answer](https://stackoverflow.com/a/23535333/15759700).
---@return string
function util.script_path()
	return debug.getinfo(2, "S").source:sub(2):match("(.*/)")
end

-- Split a string into a string array, optionally with a delimiter.
--- If no delimiter is provided, the string will be split on
--- spaces, tabs and newlines.
---
--- Based on [this StackOverflow answer](https://stackoverflow.com/a/7615129/15759700).
---@param inputstr string
---@param delimiter string
---@return string[]
function util.split(inputstr, delimiter)
	delimiter = util.default(delimiter, "%s")

	local t = {}

	for s in string.gmatch(inputstr, "([^" .. delimiter .. "]+)") do
		table.insert(t, s)
	end

	return t
end

-- Append to package.path in a simpler way.
--- You just need to provide a path. Both `<path>/?.lua` and `<path>/?/init.lua`
--- will be appended, which cuts down on code repetition.
---@param path string
function util.add_package_path(path)
	package.path = package.path .. ";" .. path .. "/?.lua" .. ";" .. path .. "/?/init.lua"
end

-- Automatically scale UI components. This function is intended to be used for
--- widget sizing, to make them appear in a fitting size dependig on their
--- respective monitor. This will return the input value if your monitor ppi is 96
--- and globals.scaling_factor is either `1` or `nil`.
---@param x number
---@return number
function util.scale(x)
	local dpi = xresources.apply_dpi(1)
	dpi = dpi * util.default(globals.scaling_factor, 1)

	return x * dpi
end

return util
