local gears   = require("gears")
local awful   = require("awful")
local wibox   = require("wibox")
local ruled   = require("ruled")
local naughty = require("naughty")

local function main(args)
	args = {
		foo = args.foo or "bar",
	}

	local picom = {}

	function picom.get_option(option, config_file, new_value)
		awful.spawn.with_shell(
			[[grep -E ']]..option..[[(. *|)=(. *|).*(\;|)' ']]..config_file..[[' | sed -E 's/^]]..option..[[(. *|)=//g' | sed 's/;//g']]
		)
	end

	function picom.set_option(option, new_value, config_file)
		awful.spawn.with_shell(
			[[sed -E -i 's/]]..option..[[(. *|)=(. *)/]]..option.."="..new_value..[[;/' ]]..config_file
		)
	end

	return picom
end

return main
