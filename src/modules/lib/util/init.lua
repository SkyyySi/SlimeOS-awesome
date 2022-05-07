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
--- not not x
--- ```
--- does (because this function is just a more
--- readable wrapper for that).
---@param x any
---@return boolean
function util.tobool(x)
	return not not x
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

-- Escapes a string for lua's pattern matching.
---@param s string
---@return string
function util.lua_escape(s)
	return s:gsub("%%", "%%%%")
		:gsub("^%^", "%%^")
		:gsub("%$$", "%%$")
		:gsub("%(", "%%(")
		:gsub("%)", "%%)")
		:gsub("%.", "%%.")
		:gsub("%[", "%%[")
		:gsub("%]", "%%]")
		:gsub("%*", "%%*")
		:gsub("%+", "%%+")
		:gsub("%-", "%%-")
		:gsub("%?", "%%?")
end

function util.get_stack_level()
	local depth = 0
	while true do
		if not debug.getinfo(3 + depth) then
			break
		end

		depth = depth + 1
	end

	return depth - 4
end

---@param stack_level? integer How many calls eval should "travel up" to read local values, defaults to `util.get_stack_level()`
---@return table variables
function util.get_locals(stack_level)
	stack_level = stack_level or util.get_stack_level() or 2
	local variables = {} ---@type table
	local idx = 1 ---@type integer

	while true do
		local ln, lv = debug.getlocal(stack_level, idx)
		if ln == nil then break end

		variables[ln] = lv
		idx = 1 + idx
	end

	return variables
end

---@param stack_level? integer How many calls eval should "travel up" to read local values, defaults to `util.get_stack_level()`
---@return table variables
function util.get_upvalues(stack_level)
	stack_level = stack_level or util.get_stack_level() or 2
	local variables = {} ---@type table
	local idx = 1 ---@type integer
	local func = debug.getinfo(stack_level, "f").func ---@type function

	while true do
		local ln, lv = debug.getupvalue(func, idx)
		if ln == nil then break end

		variables[ln] = lv
		idx = 1 + idx
	end

	return variables
end

-- Evaluates a string and returns its output.
---
--- **Please note**: This function has to temporarily make values global.
--- While it tries its best to revert those as quickly as possible,
--- this may create a [race condition](https://en.wikipedia.org/wiki/Race_condition) with asynchronous code.
--- Unfortunately, the only way to avoid that is to not evaluate
--- expressions that contain values that may also be used by
--- asynchronous code. With vanilla lua, there is no way around that.
---
--- Usage:
--- ```
--- x = "3 * 7 + 4" ---@type string
--- util.eval(x)
--- --> 25
--- ```
---@param s string
---@param stack_level? integer How many calls eval should "travel up" to read local values, defaults to `util.get_stack_level()`
---@return any
function util.eval(s, stack_level)
	stack_level = stack_level or util.get_stack_level() or 2
	local vars = util.get_locals(stack_level)
	local previous_values = {} ---@type table<string, any>

	for i,v in pairs(vars) do
		previous_values[i] = _G[i]
		_G[i] = v
	end

	local out = load("return " .. s)()

	for i,v in pairs(previous_values) do
		_G[i] = v
	end

	return out
end

-- Format a string using a nicer syntax than `string.format`.
--- WARNING: This uses `load()`, which will run **any** code
--- you put inbetween {curly brackets}! NEVER, EVER pass
--- a string into this without thought!
---
--- Usage:
--- ```
--- name = "Tom"
--- age = 34
--- util.strfmt [[Hello, my name is {name} and I am {age} years old.]]
--- --> "Hello, my name is Tom and I am 52 years old."
--- ```
---
--- ```
--- a = 6
--- b = 4
--- util.strfmt [[The resoult of a * b is {a * b}]]
--- ```
---@param s string
---@param stack_level? integer How many calls eval should "travel up" to read local values, defaults to `util.get_stack_level()`
---@return string
function util.strfmt(s, stack_level)
	stack_level = stack_level or util.get_stack_level() or 2

	for i in s:gmatch("{([%g%s]+)}") do
		i = tostring(i) ---@type string
		local v = "" ---@type string

		-- A shorthand for writing util.strfmt [[x = {x}]],
		-- just write util.strfmt [[{x = }]]
		if i:find("[%s\t\n]*=[%s\t\n]*$") then
			local ii = i:gsub("[%s\t\n]*=[%s\t\n]*$", "")
			v = i .. tostring(util.eval(ii, stack_level))
		else
			v = tostring(util.eval(i, stack_level))
		end

		i = util.lua_escape(i)
		s = s:gsub("{"..i.."}", v)
	end

	return s
end
--- print(util.strfmt("Foo {x} bar"))

return util
