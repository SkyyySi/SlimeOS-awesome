#!/usr/bin/env lua
local awful = require("awful")
local gears = require("gears")

-- depends on the inotify-tools package

local function main()
	awful.spawn.easy_async({"sleep", "1"}, function(stdout, stderr, reason, exit_code)
		awful.spawn.easy_async({"inotifywait", "--event", "modify", "--recursive", gears.filesystem.get_configuration_dir(), "--include", [[.*\.lua]]}, function(stdout, stderr, reason, exit_code)
			awesome.restart()
		end)
	end)
end

return main
