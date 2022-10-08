if __PLAYERCTL_SIGNALS_ALREADY_CREATED then
	return function() end
end

local gears     = require("gears")
local awful     = require("awful")
local beautiful = require("beautiful")
local globals   = require("modules.lib.globals")
local naughty   = require("naughty")
local util      = require("modules.lib.util")
local lgi       = require("lgi")
local cairo     = lgi.cairo

awful.spawn.once { "playerctld" }

local cache_dir = ""
local XDG_CACHE_HOME = os.getenv("XDG_CACHE_HOME")
local HOME = os.getenv("HOME")

if XDG_CACHE_HOME and XDG_CACHE_HOME ~= "" then
	cache_dir = XDG_CACHE_HOME .. "/awesome"
else
	cache_dir = HOME .. "/.cache/awesome"
end

awful.spawn { "mkdir", "-p", cache_dir }

local art_path = cache_dir .. "/coverart"
local art_script_fmt = ([[
	curl -o '%s' -fsSL '%s'
	ffmpeg -y -i '%s' '%s.png'
]]):format(art_path, "%s", art_path, art_path)

---@param metadata playerctl_metadata
---@return string
local function gen_art_script(metadata)
	return art_script_fmt:format(metadata.art_url)
end

---@param status_string "Playing"|"Paused"
---@return boolean status Whether the current media is playing or paused
local function is_playing_status_parser(status_string)
	local status = false

	if status_string == "Playing" then
		status = true
	end

	awesome.emit_signal("playerctl::is_playing", status)

	return status
end

local old_metadata = {} ---@type playerctl_metadata|table
---@param line string?
local function send_metadata_signal(line)
	if not line or line == "" then return end
	local tmp = util.split(line, "\t")

	---@class playerctl_metadata
	---@field art_path string
	---@field art_cairo userdata
	local metadata = {
		player_name = tmp[1],
		position    = tonumber(tmp[2]) or 0,
		status      = is_playing_status_parser(tmp[3]) or false,
		volume      = tmp[4],
		album       = tmp[5],
		artist      = tmp[6],
		title       = tmp[7],
		length      = tonumber(tmp[8]) or 0,
		art_url     = tmp[9],
	}

	metadata.completion = metadata.position / (metadata.length / 100)

	if not metadata.art_url or metadata.art_url == "" or metadata.art_url == old_metadata.art_url then
		metadata.art_path = old_metadata.art_path
		metadata.art_cairo = old_metadata.art_cairo

		awesome.emit_signal("playerctl::metadata", metadata)
		old_metadata = metadata
		return
	end

	awful.spawn.easy_async_with_shell(gen_art_script(metadata), function(stdout, stderr, reason, exit_code)
		metadata.art_path = art_path..".png"
		metadata.art_cairo = cairo.ImageSurface.create_from_png(metadata.art_path)
		awesome.emit_signal("playerctl::metadata", metadata)
		old_metadata = metadata
	end)
end

local function make_metadata_update_signal_listener()
	--local metadata_script = [[bash -c "while true;do playerctl metadata --format \$'{{playerName}}\t{{position}}\t{{status}}\t{{volume}}\t{{album}}\t{{artist}}\t{{title}}\t{{mpris:length}}\t{{mpris:artUrl}}'; sleep 0.5; done"]]
	local metadata_script = [[bash -c "playerctl metadata --format \$'{{playerName}}\t{{position}}\t{{status}}\t{{volume}}\t{{album}}\t{{artist}}\t{{title}}\t{{mpris:length}}\t{{mpris:artUrl}}'"]]

	gears.timer {
		timeout   = 0.5,
		autostart = true,
		call_now  = true,
		callback  = function()
			awful.spawn.with_line_callback(metadata_script, {
				stdout = send_metadata_signal,
			})
		end,
	}
end

local function make_control_signal_listeners()
	awesome.connect_signal("playerctl::play", function()
		awful.spawn {"playerctl", "play"}
	end)

	awesome.connect_signal("playerctl::pause", function()
		awful.spawn {"playerctl", "pause"}
	end)

	awesome.connect_signal("playerctl::play-pause", function()
		awful.spawn {"playerctl", "play-pause"}
	end)

	awesome.connect_signal("playerctl::next", function()
		awful.spawn {"playerctl", "next"}
	end)

	awesome.connect_signal("playerctl::previous", function()
		awful.spawn {"playerctl", "previous"}
	end)
end

local function main()
	make_metadata_update_signal_listener()
	make_control_signal_listeners()

	__PLAYERCTL_SIGNALS_ALREADY_CREATED = true
end

return main
