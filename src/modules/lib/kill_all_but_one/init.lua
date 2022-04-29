#!/usr/bin/env lua
local awful = require("awful")

local function main(args)
	args = {
		pattern = args.pattern, -- typically, you want this to be something like "^pasystray$".
		max_allowed_processes = args.max_allowed_processes or 1,
	}

	local i = args.max_allowed_processes - 1
	awful.spawn.with_line_callback("pgrep"..args.pattern, {
		stdout = function(line)
			if i < args.max_allowed_processes - 1 then
				i = i + 1
				return
			end

			awful.spawn { "kill", line }
		end
	})
end

return main
