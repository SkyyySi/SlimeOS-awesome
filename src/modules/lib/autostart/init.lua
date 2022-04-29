#!/usr/bin/env lua
local awful = require("awful")
local gears = require("gears")

local function main(args)
	args = {
		apps    = args.apps,                       -- a table of tables for awful.spawn
		once    = not (not args.once    or false), -- double inversion is needed for `true` as a default value
		restart = not (not args.restart or false),
		restart_delay = args.restart_delay or 5,   -- the delay in seconds until a restart should be attempted; waiting for a process to exit and restarting it only then is possible, but not done here because it is very resource intensive to do so. It would also mean that applications that exit almost immediatly (for example, because of a syntax error in their respecitve configs) would potentially be restarted hundreds of time a second - which will make your CPU scream in pain.
	}

	local spawn = awful.spawn
	if args.once then
		spawn = awful.spawn.once
	end

	for _,v in pairs(args.apps) do
		spawn(v)
	end

	if args.restart then
		gears.timer {
			autostart = true,
			timeout   = args.restart_delay,
		}
	end
end

return main
