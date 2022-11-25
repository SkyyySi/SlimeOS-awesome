local gears   = require("gears")
local awful   = require("awful")
local wibox   = require("wibox")
local ruled   = require("ruled")
local naughty = require("naughty")
local util    = require("modules.lib.util")

local script_dir = util.get_script_path()
local defualt_config_file_path = script_dir.."/picom.conf"

local function main(args)
	args = {
		foo = args.foo or "bar",
	}

	local picom = {}

	function picom.get_option(option, new_value, config_file_path)
		config_file_path = config_file_path or defualt_config_file_path
		awful.spawn.with_shell(
			[[grep -E ']]..option..[[(. *|)=(. *|).*(\;|)' ']]..config_file_path..[[' | sed -E 's/^]]..option..[[(. *|)=//g' | sed 's/;//g']]
		)
	end

	function picom.set_option(option, new_value, config_file_path)
		config_file_path = config_file_path or defualt_config_file_path
		awful.spawn.with_shell(
			[[sed -E -i 's/]]..option..[[(. *|)=(. *)/]]..option.."="..new_value..[[;/' ]]..config_file_path
		)
	end

	return picom
end

return main
