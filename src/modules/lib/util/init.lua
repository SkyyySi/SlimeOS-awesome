--local gears      = require("gears")
--local awful      = require("awful")
--local wibox      = require("wibox")
--local ruled      = require("ruled")
--local naughty    = require("naughty")
local globals    = require("modules.lib.globals")
local xresources = require("beautiful.xresources")

-- Faster lookup
local require = require
local next = next
local math = math
local io = io
local os = os
local pairs = pairs
local ipairs = ipairs
local tonumber = tonumber
local tostring = tostring
local debug = debug
local table = table
local type = type
local setmetatable = setmetatable
local getmetatable = getmetatable

local util = {}

util.color = require("modules.lib.util.color")

--- Returns the current Lua version as a number
---@return number? version
function util.get_lua_version()
	return tonumber(_VERSION:match([[[0-9.]+$]]))
end

--- Converts any type into a boolean, in the same way
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

--- Returns the first argument that is not `nil`
---@generic T1
---@generic T2
---@param value T1
---@vararg T2
---@return T1|T2
function util.default(value, ...)
	if value ~= nil then
		return value
	end

	for _, v in pairs {...} do
		if v ~= nil then
			return v
		end
	end

	return nil
end

--- Call a function *n* times.
---
--- Note that this counts from 1 to the specified number
--- in order to stay consistent with lua's decision to
--- start indicies at 1.
---
--- Usage:
--- ```
--- util.repeat_for(10, function(i)
--- 	print("Hello, this was printed " .. tostring(i) .. " time(s) so far.")
--- end)
--- --stdout> Hello, this was printed 1 time(s) so far.
--- --stdout> Hello, this was printed 2 time(s) so far.
--- --stdout> [...]
--- --stdout> Hello, this was printed 9 time(s) so far.
--- --stdout> Hello, this was printed 10 time(s) so far.
--- ```
---@param n number
---@param callback fun(i?: number)
function util.repeat_for(n, callback)
	for i = 1, n do
		callback(i)
	end
end

--- Calculates the average of all numbers in an array.
---@param t number[]
function util.average(t)
	local sum = 0

	for _,v in pairs(t) do -- Get the sum of all numbers in t
		sum = sum + v
	end

	return sum / #t
end

--- When runing as a script, this function will return the path
--- where it is located.
---
--- Based on [this StackOverflow answer](https://stackoverflow.com/a/23535333/15759700).
---@return string
function util.get_script_path()
	return debug.getinfo(2, "S").source:sub(2):match("(.*/)")
end

--- Loop over each character of a string in a for-loop.
---@param inputstr string
---@return fun(): string
function util.iterstring(inputstr)
	local iterator = 0
	local strlen = #inputstr

	return function()
		if iterator >= strlen then return end

		iterator = iterator + 1
		return inputstr:sub(iterator, iterator)
	end
end

--- Split a string into a string array, optionally with a delimiter.
--- If no delimiter is provided, the string will be split on
--- spaces, tabs and newlines.
---
--- Based on [this StackOverflow answer](https://stackoverflow.com/a/7615129/15759700).
---@param inputstr string
---@param delimiter? string
---@return string[]
function util.split(inputstr, delimiter)
	inputstr  = util.default(inputstr, "")
	delimiter = util.default(delimiter, "%s")

	if not inputstr:match(delimiter) then
		return {inputstr}
	end

	local t = {""} ---@type string[]

	for s in util.iterstring(inputstr) do
		if s == delimiter then
			table.insert(t, "")
		else
			t[#t] = t[#t]..s
		end
	end

	return t
end

--- Combine all elements of an array into a string.
---@param arr table<any, string>
---@param combiner? string
---@return string outstr
function util.join(arr, combiner)
	combiner = util.default(combiner, " ")

	local is_first = true
	local outstr = ""
	for _,v in pairs(arr) do
		if is_first then
			outstr = v .. combiner
			is_first = false
		else
			outstr = outstr .. v .. combiner
		end
	end

	return outstr
end

--- Append to package.path in a simpler way.
--- You just need to provide a path. Both `<path>/?.lua` and `<path>/?/init.lua`
--- will be appended, which cuts down on code repetition.
---@param path string
function util.add_package_path(path)
	package.path = package.path .. ";" .. path .. "/?.lua" .. ";" .. path .. "/?/init.lua"
end

--- Automatically scale UI components. This function is intended to be used for
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

--- Escapes a string for lua's pattern matching.
---@param s string
---@return string, integer
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

--- Replace escape sequences with their litteral representation.
---@param s string
---@return string, integer
function util.string_escape(s)
	return s:gsub("\a", [[\a]])
		:gsub("\b", [[\b]])
		:gsub("\f", [[\f]])
		:gsub("\n", [[\n]])
		:gsub("\r", [[\r]])
		:gsub("\t", [[\t]])
		:gsub("\v", [[\v]])
		:gsub("\\", [[\\]])
		:gsub("\"", [[\"]])
		:gsub("\'", [[\']])
end

---@return number depth The current Lua execution stack level
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

--- Evaluates a string and returns its output.
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

--- Format a string using a nicer syntax than `string.format`.
--- WARNING: This uses `load()`, which will run **any** code
--- you put inbetween {curly brackets}! NEVER, EVER pass
--- a string into this without thought!
---
--- Usage:
--- ```
--- name = "Tom"
--- age = 34
--- util.strfmt [[Hello, my name is ${name} and I am ${age} years old.]]
--- --> "Hello, my name is Tom and I am 52 years old."
--- ```
---
--- ```
--- a = 6
--- b = 4
--- util.strfmt [[The resoult of a * b is ${a * b}]]
--- ```
---@param s string
---@param stack_level? integer How many calls eval should "travel up" to read local values, defaults to `util.get_stack_level()`
---@return string
function util.strfmt(s, stack_level)
	stack_level = stack_level or util.get_stack_level() or 2

	for i in s:gmatch("%${([%g%s]+)}") do
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
		s = s:gsub("%${"..i.."}", v)
	end

	return s
end
--- print(util.strfmt([[Foo ${x} bar]]))

--- Safe string formatting; uses a table as the second parameter
--- instead of trying to parse the data inside of brackets.
--- While this isn't as nice to write, it is guarantied to
--- work, including with local variables
---@param s string
---@param vars table<string, any>
---@return string
function util.sstrfmt(s, vars)
	for i in s:gmatch("%${([%g%s\n\t]+)}") do
		i = tostring(i) ---@type string
		local v = "" ---@type string

		-- A shorthand for writing util.strfmt [[x = {x}]],
		-- just write util.strfmt [[{x = }]]
		if i:find("[%s\t\n]*=[%s\t\n]*$") then
			local ii = i:gsub("[%s\t\n]*=[%s\t\n]*$", "")
			v = i .. tostring(tostring(vars[ii]))
		else
			v = tostring(tostring(vars[i]))
		end

		i = util.lua_escape(i)
		s = s:gsub("%${"..i.."}", v)
	end

	return s
end
--- print(util.sstrfmt([[Foo ${x} bar]], {x = 5}))

--- Try-catch-style error handling
---@param fn fun(...)
---@return { catch: fun(err) }
function util.try(fn, ...)
	local success, result = pcall(fn, ...)

	local retval = {}
	function retval.catch() end
	---@param fn_fin fun(...)
	function retval.finally(fn_fin, ...) fn_fin(...) end

	if not success then
		---@param fn_err fun(err)
		function retval.catch(fn_err)
			fn_err(result)
		end
	end

	return retval
end

--- Create a simple anonymous function with a Ruby-like syntax
---
--- Usage:
---
--- ```
--- local lambda = require("lambda")
--- f = lambda[[|x, y| x + y + 2]]
--- f(3, 6)
--- --> 11
--- ```
---@param expr string The lambda expression to evaluate
---@return function The created function
function util.lambda(expr)
    local args, body = expr:match([[^|([^|]*)|(.*)]]) ---@type string, string
    return load("return function("..args..") return "..body.."; end")() ---@type function
end

--- Create a new array by running a function for
--- each item in an existing array. Similar to
--- JavaScript's <array>.map() method.
---
--- Usage:
---
--- ```
--- local x = { 4, 7, 23, 2, 67 }
--- local y = util.map_array(x, function(item) return item * 2 end)
--- -- y = { 8, 14, 46, 4, 134 }
--- ```
---
--- - You can also add this function as a method to an array,
--- which might be more readable in some cases, in particualr
--- when returning the array to be used somewhere else:
---
--- ```
--- local mt = { map = util.map_array }
--- mt.__index = mt
---
--- local x = setmetatable({}, mt)
---
--- local y = x:map(function(item) return item * 2 end)
--- -- y = { 8, 14, 46, 4, 134 }
--- ```
---@param array any[]
---@param fn fun(item: any)
---@return any[] new_array
function util.map_array(array, fn)
	local new_array = {}

	for i, v in pairs(array) do
		new_array[i] = fn(v)
	end

	return new_array
end

--[==[
---@param path string The directory path to list the contents of
---@param callback fun(item: string)
---@return string[] contents Array of files and directories located in `path` (populated asynchronously!!!)
function util.ls(path, callback)
	if not path:match("^/") then
		error(("ERROR: Your provided path '%s' is not absolute!\nIt needs to start with '/' (forward slash character)."):format(path))
	end

	if not path:match("/$") then
		path = path .. "/"
	end

	local out = {} ---@type string[]

	awful.spawn.easy_async({ "find", "/home/simon/Schreibtisch/", "-maxdepth", "1", "-print0" }, function(stdout, stderr, reason, exit_code)
		stdout = stdout:gsub("\n", "")
		--notify(stdout)
		for k, v in ipairs(util.split(stdout, "\0")) do
			table.insert(out, v)
			callback(v)
		end
	end)

	return out
end
--]==]

--- Check if a file exists in this path; returns `false` when
--- passed a directory instead of a file path
---@param path string
---@return boolean exists
function util.file_exists(path)
	local f=io.open(path, "r")

	if f ~= nil then
		io.close(f)
		return true
	end

	return false
end

--- Check if a file or directory exists in this path
---@param path string
---@return boolean exists, string?
function util.fsobj_exists(path)
	local ok, err, code = os.rename(path, path)

	if not ok and code == 13 then
		-- Permission denied, but it exists
		return true
	end

	return ok, err
end

---@param t table
---@return boolean is_empty True if `t` is empty, otherwise false
function util.table_is_empty(t)
	return next(t) == nil
end

---@param str string The string you want to save into the file
---@param path string The full file path
---@return string? err The error message if something went wrong
function util.dump_to_file(str, path)
	local file,err = io.open(path, "w")

	if file then
		file:write(str)
		file:close()
	elseif err then
		-- Note: I'm aware that `error()` exists, but I find that kind of error handling to be ugly
		print("ERROR: Could not save file: "..err)
	else
		print("ERROR: Could not save file!")
	end

	return err
end

--- Pause execution for a set amount of time.
---
--- WARNING: DO NOT USE THIS FOR ANYTHING BUT TESTING!
--- This is not asynchronous. This means that running this
--- function will cause lag!
---
---@param time number
function util.sleep(time)
	local f = io.popen("sleep "..tostring(time), "r")
	if f == nil then return end
	local out = f:read("*a")
	f:close()
end

---@param str string
---@param n number
---@return string
function util.string_multiply(str, n)
	if n <= 0 then
		return ""
	end

	local outs = ""
	local floor = math.floor(n)
	local point = n - floor

	for i = 1, n do
		outs = outs..str
	end

	if point > 0 then
		local len = #str * floor
		outs = outs..str:sub(1, math.floor(len))
	end

	return outs
end

---@param t table
---@param indent? string
---@param depth? integer
---@return string
function util.table_to_string(t, indent, depth)
	if type(t) ~= "table" then
		return ""
	end

	indent = indent or "    "
	depth = depth or 0
	local bracket_indent = util.string_multiply(indent, depth)
	local full_indent = bracket_indent..indent

	if next(t) == nil then
		if depth > 0 then
			return "{},"
		else
			return "{}"
		end
	end

	local outs = "{\n"

	for k, v in pairs(t) do
		local tv = type(v)
		local tk = type(k)

		if tk == "string" then
			k = '"'..util.string_escape(k)..'"'
		elseif tk == "function" or tk == "thread" or tk == "userdata" then
			k = "[["..tostring(k).."]]"
		end

		if tv == "table" then
			if tv == t then
				return "[[...]]"
			end

			outs = ("%s%s[%s] = %s"):format(outs, full_indent, k, util.table_to_string(v, indent, depth + 1).."\n")
		else
			if tv == "string" then
				v = '"'..util.string_escape(v)..'"'
			elseif tv == "function" or tv == "thread" or tv == "userdata" then
				v = "[["..tostring(v).."]]"
			end

			outs = ("%s%s[%s] = %s,\n"):format(outs, full_indent, k, v)
		end
	end

	if depth > 0 then
		return outs..bracket_indent.."},"
	else
		return outs..bracket_indent.."}"
	end
end

function util.table_to_string_simple(t)
	if type(t) ~= "table" then
		return ""
	end

	local outs
	local first = true

	for k, v in pairs(t) do
		if type(k) == "string" then
			k = '"'..util.string_escape(k)..'"'
		end
		if type(v) == "string" then
			v = '"'..util.string_escape(v)..'"'
		end

		if first then
			first = false
			outs = ("{ [%s] = %s"):format(k, v)
		else
			outs = ("%s, [%s] = %s"):format(outs, k, v)
		end
	end

	return outs.."}"
end

--- Filter out strings in a table that match a specfific pattern
--- and return 2 new tables, the first only containing them,
--- the other only containing non-matching strings.
--- Keys *will* be preserved.
---@param strings table<any, string> The array of strings to search through
---@return table<any, string> does_match, table<any, string> does_not_match
function util.filter_by_pattern(strings, pattern)
	local does_match, does_not_match = {}, {}
	local mt = getmetatable(strings) or {
		__tostring = util.table_to_string_simple
	}
	mt.__index = mt
	setmetatable(does_match, mt)
	setmetatable(does_not_match, mt)

	for k, v in pairs(strings) do
		print("> "..v, v:match(pattern))
		if v:match(pattern) then
			does_match[k] = v
		else
			does_not_match[k] = v
		end
	end

	return does_match, does_not_match
end

--- Rounds a number mathmatically correctly: if its decimal place is <.5
--- it will be rounded down, otherwise up.
---@param x any
function util.round(x)
	local floor = math.floor(x)

	if x - floor < 0.5 then
		return floor
	end

	return floor + 1
end

--- Sets widget properties based on an id. Recusive.
---@param widget any
---@param prop_key any
---@param prop_value any
---@param id string
function util.set_widget_prop_by_id(widget, prop_key, prop_value, id)
	for _, w in ipairs(widget:get_children_by_id(id)) do
		if prop_key then
			w[prop_key] = prop_value
		else
			table.insert(w, prop_value)
		end
	end
end

--- Strip a string (trim whitespaces at the beginning and end)
---@param str str
---@return str
function util.strip(str)
	return str:match("^%s*(.-)%s*$")
end

--- A wrapper around `get_children_by_id()` to make it easier to use.
---@param widget wibox.widget._instance
---@param id string
---@param callback fun(child: wibox.widget._instance)
function util.for_children(widget, id, callback)
	if not widget or not widget.get_children_by_id then
		return
	end

	for _, child in pairs(widget:get_children_by_id(id)) do
		callback(child)
	end
end

return util
