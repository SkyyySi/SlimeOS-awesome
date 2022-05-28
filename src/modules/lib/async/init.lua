local awful = require("awful")
local generics = require("modules.lib.generics")
local util = require("modules.lib.util")
local try = util.try

---@class Task
local Task = {
	mt = {},
	states = generics.Enum { "pending", "fulfilled", "rejected" },
}

---@param fn fun(...)
function Task.mt:__call(fn, ...)
	---@type { state: number } 0 = pending, 1 = fulfilled, 2 = rejected
	local obj = {
		state = 0,
	}

	local varargs = {...}
	awful.spawn.easy_async({util.get_script_path() .. "nop-bin/nop"}, function(stdout, stderr, reason, exit_code)
		try(function()
				fn(unpack(varargs))
		end)
		.catch(function(err)
			error("Oh no! Seems like your async function has an error!")
		end)
	end)

	self.__index = self
	return setmetatable(obj, Task)
end

setmetatable(Task, Task.mt)

--- Create an asynchronous function.
---
--- This works by creating a function transforming a value beforehand and passing it.
--- In other words: This will *require* you to write code with side effects. Sorry.
---
--- Usage:
--- ```
--- local tb = {}
--- local function mod_tb()
--- 	for i = 1, 100 do
--- 		table.insert(tb, i)
--- 	end
--- end
---
--- -- The numbers from 1 to 100 will be added asynchronously to the table.
--- local task = async(mod_tb)
--- ```
---@param fn fun() A function to transform the table
---@return Task task
local function async(fn, ...)
	local task = Task(fn, ...)

	return task
end

return async
