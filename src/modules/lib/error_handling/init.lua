local naughty = require("naughty")

local function main(args)
	args = {
		notification_handler = args.notification_handler or "naughty", -- TODO: Add support for other handlers, like dunst or dbus
	}

	-- Check if awesome encountered an error during startup and fell back to
	-- another config (This code will only ever execute for the fallback config)
	naughty.connect_signal("request::display_error", function(message, startup)
		naughty.notification {
			urgency = "critical",
			title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
			message = message,
			timeout = 0,
		}
	end)
end

return main
