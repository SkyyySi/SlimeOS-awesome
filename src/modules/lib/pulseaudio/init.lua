if __PULSEAUDIO_SIGNALS_ALREADY_CREATED then
	return function() end
end

local awful = require("awful")
local gears = require("gears")
local util = require("modules.lib.util")

local function send_is_muted_signal()
	awful.spawn.easy_async({ "pamixer", "--get-mute" }, function(stdout, stderr, reason, exit_code)
		local out = false

		stdout = stdout:gsub("\n", "")
		if stdout:gsub("\n", "") == "true" then
			out = true
		end

		awesome.emit_signal("pulseaudio::is_muted", out)
	end)
end

local function main(args)
	args = util.default(args)
	args = {}

	awesome.connect_signal("pulseaudio::set_volume", function(volume) ---@param volume number
		awful.spawn { "pamixer", "--set-volume", tostring(volume) }
		awesome.emit_signal("pulseaudio::volume", volume)
	end)

	awesome.connect_signal("pulseaudio::increase_volume", function(volume) ---@param volume number
		awful.spawn { "pamixer", "--increase", tostring(volume or 5) }
	end)

	awesome.connect_signal("pulseaudio::decrease_volume", function(volume) ---@param volume number
		awful.spawn { "pamixer", "--decrease", tostring(volume or 5) }
	end)

	awesome.connect_signal("pulseaudio::toggle_mute", function()
		awful.spawn { "pamixer", "--toggle-mute" }
		send_is_muted_signal()
	end)

	local timer = gears.timer {
		timeout = 0.5,
		autostart = true,
		call_now = true,
		callback = function()
			awful.spawn.easy_async({ "pamixer", "--get-volume" }, function(stdout, stderr, reason, exit_code)
				awesome.emit_signal("pulseaudio::volume", tonumber(stdout))
			end)

			send_is_muted_signal()
		end,
	}

	__PULSEAUDIO_SIGNALS_ALREADY_CREATED = true
end

return main
