--local gears         = require("gears")
--local awful         = require("awful")
--local beautiful     = require("beautiful")
--local hotkeys_popup = require("awful.hotkeys_popup")
--local globals       = require("modules.lib.globals")
--local naughty       = require("naughty")
local util          = require("modules.lib.util")

---@class generics
local generics = {}

--- Arrays can only hold number indecies and will throw an error if
--- an attempt is made to add any other index type.
---@class Array
generics.Array = { mt = {} }

function generics.Array.mt:__call(arr)
	local function throw_error_if_key_is_not_a_number(k, v)
		local type_of_key = type(k) ---@type string

		if type_of_key ~= "number" then
			error("Arrays can only have numerical indecies, but the type of '" .. tostring(v) .. "' is '" .. type_of_key .. "'.")
		end
	end

	for k,v in pairs(arr) do
		throw_error_if_key_is_not_a_number(k, v)
	end

	---@generic T : any
	local proxy = {} ---@type T
	local mt = {}

	mt.__index = arr

	function mt.__newindex(t, k, v)
		throw_error_if_key_is_not_a_number(k, v)

		--rawset(t, k, v)
		t[k] = v
	end

	function mt:__call(t)
		local i = 0 ---@type number
		local n = #t
		return function()
			i = i + 1
			if i <= n then return t[i] end
		end
	end

	function mt:__tostring()
		local out = "Array { " ---@type string

		local is_first = true
		for i,v in pairs(arr) do
			if is_first then
				out = out .. util.sstrfmt([[${v}, ]], {v = v})
				is_first = false
			else
				out = out .. util.sstrfmt([[${v} ]], {v = v})
			end
		end

		return out .. "}"
	end

	---@param cb fun(value: any)
	function mt:map(cb)
		for _,v in pairs(arr) do
			cb(v)
		end
	end

	setmetatable(proxy, mt)
	return proxy
end

setmetatable(generics.Array, generics.Array.mt)

--- Enums can be seen as "named integers", in the sense
--- that they are tables that assign one number to each
--- item in `fields`. The advantage compared to using
--- strings directly is that enums take less memory when
--- using a value a lot, since you don't need to create
--- a new string every time you want to, for example, check
--- for equality.
---@class Enum
---@return Enum
generics.Enum = { mt = {} }

---@param fields string[]
---@return Enum
function generics.Enum.mt:__call(fields)
	local new_enum = {}
	local i = 0

	for _,v in pairs(fields) do
		new_enum[v] = i
		i = i + 1
	end

	self.__index = self

	return setmetatable(new_enum, self)
end

function generics.Enum:__tostring()
	local out = "Enum { " ---@type string

	local is_first = true
	for _,v in pairs(self) do
		if is_first then
			out = out .. util.sstrfmt([[${v}, ]], {v = v})
			is_first = false
		else
			out = out .. util.sstrfmt([[${v} ]], {v = v})
		end
	end

	return out .. "}"
end

setmetatable(generics.Enum, generics.Enum.mt)

---@class Class
generics.Class = { mt = {} }

---@param tb table
function generics.Class.mt:__call(tb)
	tb.__call = util.default(tb.constructor, function(o)
		o = util.default(o, {})
		self.__index = self
		return setmetatable(o, self)
	end)
	tb.__gc = util.default(tb.destructor, nil)

	local new_object = setmetatable({}, tb)

	return new_object
end

setmetatable(generics.Class, generics.Class.mt)

return generics
