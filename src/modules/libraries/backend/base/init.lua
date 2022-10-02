#!/usr/bin/env lua
local wibox = require('wibox')
local gears = require('gears')
local awful = require('awful')
local class = require("modules.libraries.backend.class")
local base = class:new()

function base.round(x)
	return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

-- https://stackoverflow.com/questions/1426954/split-string-in-lua#comment73602874_7615129
-- Splits a variable into a table, using the second argument as the field seperator.
function base.split(inputstr, sep)
	sep=sep or '%s'
	local t={}
	for field,s in string.gmatch(inputstr, '([^'..sep..']*)('..sep..'?)') do
		table.insert(t,field)
		if s=='' then
			return t
		end
	end
end

-- Splits an environment variable with a $PATH-like syntax.
function base.split_env(var)
	local var_split = base.split(os.getenv('PATH'), ':')
	return var_split
end

-- Convert a table into a human readable string. Primarily for debugging.
function base.untable(table)
	local str = ''
	for i,v in pairs(table) do
		str = str .. tostring(i) .. ':\t' .. tostring(v) .. '\n'
	end
	return str
end

--[[ Returns true if the array contains the entry, otherwise returns false. ]]
function base.inArray(array, entry)
	for _, v in ipairs(array) do
		if v == entry then
			return true
		end
	end
	return false
end

--[[ List all wallpapers by calling a callback function for each wallpaper. ]]
awful.spawn.with_shell([[
	mkdir -p "/tmp/.awesome_cache_$USER/wallpapers";
	rm -rf "/tmp/.awesome_cache_$USER/wallpapers_db.txt";
	touch "/tmp/.awesome_cache_$USER/wallpapers_db.txt"
]])

	local function wallpaper_ffmpeg(wallpaper)
	return [[wallpaper="]]..wallpaper..[["; filename="/tmp/.awesome_cache_$USER/wallpapers/$(xxhsum --quiet -- "$wallpaper" | awk '{print $1}').jpg"; yes n | ffmpeg -i "$wallpaper" -vf "crop=w='min(iw\,ih)':h='min(iw\,ih)',scale=300:169,setsar=1" -vframes 1 "$filename"; echo "$filename" >> "/tmp/.awesome_cache_$USER/wallpapers_db.txt"]]
end

function base.list_wallpapers(callback)
	local wplist = {}

	awful.spawn.with_line_callback({ gears.filesystem.get_configuration_dir()..'scripts/get_wallpapers.sh' }, {
		stdout = function(wallpaper)
			awful.spawn.easy_async_with_shell(wallpaper_ffmpeg(wallpaper), function()
				--notify(wallpaper)
				awful.spawn.with_line_callback({ 'cat', '/tmp/.awesome_cache_'..os.getenv('USER')..'/wallpapers_db.txt' }, { stdout = function(wallpaper_comp)
					if not base.inArray(wplist, wallpaper_comp) then
						wplist[#wplist+1] = wallpaper_comp
						--notify(wallpaper_comp)
						callback(wallpaper_comp)
					end
				end })
			end)
		end
	})
end

function base.draw_shape(args, ...)
	args = args or {}
	args = {
		color = args.color or gears.color("#FF0000"),
		shape = args.shape or gears.shape.rounded_rect,
	}

	local additional_args = ...

	local shape_widget = wibox.widget.base.make_widget()

	shape_widget.draw = function(widget, context, cr, width, height)
		cr:set_source(args.color)
		cr:move_to(0, 0)
		args.shape(cr, width, height, additional_args)
		cr:fill()
	end

	return shape_widget
end

function base.clamp_string_length(string, max_length, do_not_append_tripple_period)
    if #string <= max_length then
		return string
    end

	if not do_not_append_tripple_period then
		max_length = max_length - 3
	end

	local new_string = ""

	for i = 1, max_length do
		new_string = new_string .. string:sub(i, i)
	end

	if not do_not_append_tripple_period then
		new_string = new_string .. "..."
	end

	return new_string
end

return base:new()
