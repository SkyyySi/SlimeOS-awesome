local awful     = require("awful")
local wibox     = require("wibox") ---@type wibox
local gears     = require("gears")
local beautiful = require("beautiful")
local buttonify = require("modules.lib.buttonify")
local util      = require("modules.lib.util")

local function make_button(widget, args)
	args = {
		normal     = args.normal   or "#FF000060",
		hover      = args.hover    or "#FF0000B0",
		press      = args.press    or "#FF0000FF",
		release    = args.release  or args.normal or"#FF0000B0",
		callback   = args.callback or function() end,
		shape      = args.shape    or function(cr, w, h) gears.shape.circle(cr, w, h) end,
	}

	local new_widget = wibox.widget {
		widget,
		bg     = args.normal or "#FF0000B0",
		shape  = args.shape,
		widget = wibox.container.background,
	}

	buttonify {
		widget                  = new_widget,
		mouse_effects           = false,
		button_color_normal     = args.normal,
		button_color_hover      = args.hover,
		button_color_press      = args.press,
		button_color_release    = args.release,
		button_callback_release = args.callback,
	}

	return new_widget
end

local client_volumes = {} ---@type table<integer, integer>
---@param sink_id integer
local function get_average_volume_of_sink_input(sink_id)
	local sink_id_str = tostring(sink_id)
	local command = {"pulsemixer", "--list-sinks"}
	awful.spawn.easy_async(command, function(stdout) ---@param stdout string
		for _,line in pairs(util.split(stdout, "\n")) do
			line = line:match("Sink%sinput:%s.*ID:%ssink%-input%-.*"..sink_id_str..".*")
			if line then
				line = line:match("Volumes:%s%[.*%]")
					:gsub("Volumes:", "")
					:gsub("'", "")
					:gsub("%s", "")
					:gsub("%[", "")
					:gsub("%]", "")
					:gsub("%%", "")

				local vols = util.split(line, ",") ---@type string[]|integer[]

				for i,v in pairs(vols) do
					vols[i] = tonumber(v)
				end

				local vol = math.floor(util.average(vols))
				client_volumes[sink_id] = vol
				awesome.emit_signal("pulseaudio::volume_of_sink_input", sink_id, vol)

				break
			end
		end
	end)
end

local clients_pids_with_pulse_sink_input_id = {} ---@type table<integer, integer>
local pulse_sink_input_id_with_clients_pids = {} ---@type table<integer, integer>
local function get_clients_pids_with_pulse_sink_input_id()
	local command = [[pacmd list-sink-inputs | tr '\n' '\r' | perl -pe 's/.*? *index: ([0-9]+).+?application\.process\.id = "([^\r]+)"\r.+?(?=index:|$)/\2:\1\r/g' | tr '\r' '\n']]

	awful.spawn.easy_async_with_shell(command, function(stdout)
		clients_pids_with_pulse_sink_input_id = {}
		for _,line in pairs(util.split(stdout, "\n")) do
			local pid, id = unpack(util.split(line, ":")) ---@type string
			local pid_n = tonumber(pid) --or 1
			local id_n = tonumber(id) --or 1
			if pid_n and id_n then
				clients_pids_with_pulse_sink_input_id[pid_n] = id_n
				pulse_sink_input_id_with_clients_pids[id_n] = pid_n
				awesome.emit_signal("pulseaudio::client_is_sink_input", pid_n, id_n)
			end
		end
	end)
end

gears.timer {
	timeout   = 1.5,
	call_now  = true,
	autostart = true,
	callback  = function()
		for i,v in pairs(clients_pids_with_pulse_sink_input_id) do
			get_average_volume_of_sink_input(v)
		end

		get_clients_pids_with_pulse_sink_input_id()
	end,
}

---@param vol integer
---@param sink_id integer
local function set_client_volume(vol, sink_id)
	awful.spawn({"pulsemixer", "--set-volume", tostring(vol), "--id", "sink-input-"..tostring(sink_id)})
end

---@param args table<string, any>
---@return wibox.widget widget
local function volume_slider(args)
	args = {
		client = args.client,
	}

	local pid = args.client.pid ---@type integer
	local sink_id ---@type integer

	---@type wibox.widget.slider
	local slider = wibox.widget {
		bar_shape           = gears.shape.rounded_bar,
		bar_height          = 4,
		bar_color           = beautiful.border_color,
		handle_color        = beautiful.bg_normal,
		handle_shape        = gears.shape.circle,
		handle_border_color = beautiful.border_color,
		handle_border_width = 1,
		minimum             = 0,
		maximum             = 100,
		value               = 50,
		visible             = false,
		forced_width        = util.scale(200),
		widget              = wibox.widget.slider,
	}

	local widget = wibox.widget {
		{
			widget = slider,
		},
		layout = wibox.layout.fixed.horizontal,
	}

	if clients_pids_with_pulse_sink_input_id[pid] then
		slider.visible = true
	end

	slider:connect_signal("property::value", function(w)
		set_client_volume(w.value, sink_id)
	end)

	awesome.connect_signal("pulseaudio::volume_of_sink_input", function(sink_id_sig, vol)
		if pulse_sink_input_id_with_clients_pids[sink_id_sig] == pid then
			sink_id = sink_id_sig
			slider:set_value(vol)
		end
	end)

	awesome.connect_signal("pulseaudio::client_is_sink_input", function(pid_sig, sink_id_sig)
		if pid_sig == pid then
			slider.visible = true
		end
	end)

	return widget
end

local function main(args)
	client.connect_signal("request::titlebars", function(c)
		-- buttons for the titlebar
		local buttons = {
			awful.button({ }, 1, function()
				c:activate { context = "titlebar", action = "mouse_move"  }
			end),
			awful.button({ }, 3, function()
				c:activate { context = "titlebar", action = "mouse_resize"}
			end),
		}

		local titlebars = {}

		get_clients_pids_with_pulse_sink_input_id()

		titlebars.top = awful.titlebar(c, {
			position = "top",
			height   = 16,
			bg       = gears.color.transparent,
		})
		titlebars.top.widget = {
			{
				{
					{
						{
							{
								awful.titlebar.widget.iconwidget(c),
								--make_button(awful.titlebar.widget.floatingbutton(c)),
								--make_button(awful.titlebar.widget.stickybutton(c)),
								--make_button(awful.titlebar.widget.ontopbutton(c)),
								make_button(awful.titlebar.widget.floatingbutton(c), {
									normal = "#00000000",
									hover  = "#2060C0",
									press  = "#3090FF",
								}),
								make_button(awful.titlebar.widget.stickybutton(c), {
									normal = "#00000000",
									hover  = "#2060C0",
									press  = "#3090FF",
								}),
								make_button(awful.titlebar.widget.ontopbutton(c), {
									normal = "#00000000",
									hover  = "#2060C0",
									press  = "#3090FF",
								}),
								volume_slider {
									client = c,
								},
								layout = wibox.layout.fixed.horizontal,
							},
							margins = 2,
							widget = wibox.container.margin,
						},
						{
							{
								align  = "center",
								widget = awful.titlebar.widget.titlewidget(c),
							},
							buttons = buttons,
							layout  = wibox.layout.flex.horizontal,
						},
						{
							{
								--awful.titlebar.widget.minimizebutton(c),
								--awful.titlebar.widget.maximizedbutton(c),
								--awful.titlebar.widget.closebutton(c),
								make_button(awful.titlebar.widget.minimizebutton(c), {
									normal = "#00000000",
									hover  = "#2060C0",
									press  = "#3090FF",
								}),
								make_button(awful.titlebar.widget.maximizedbutton(c), {
									normal = "#00000000",
									hover  = "#2060C0",
									press  = "#3090FF",
								}),
								make_button(awful.titlebar.widget.closebutton(c), {
									normal = "#C01000",
									hover  = "#D83010",
									press  = "#F02010",
								}),
								layout = wibox.layout.fixed.horizontal(),
							},
							margins = 2,
							widget  = wibox.container.margin,
						},
						layout = wibox.layout.align.horizontal
					},
					bg     = beautiful.accent_bright,
					widget = wibox.container.background,
				},
				top    = 1,
				left   = 1,
				right  = 1,
				widget = wibox.container.margin,
			},
			bg     = beautiful.accent_dark,
			widget = wibox.container.background,
		}

		--c:connect_signal("property::geometry", function(c)
		--	titlebars.top.widget.bg = gears.color {
		--		type = "linear",
		--		from = { 0, 0 },
		--		to   = { c.width, 0},
		--		stops = {
		--			{ 0, beautiful.accent_primary_brighter },
		--			{ 1, beautiful.accent_primary_medium },
		--		}
		--	}
		--end)

		titlebars.bottom = awful.titlebar(c, {
			position = "bottom",
			size     = 2,
			bg       = gears.color.transparent,
		})
		titlebars.bottom.widget = wibox.widget {
			{
				{
					bg     = beautiful.accent_bright,
					widget = wibox.container.background,
				},
				bottom = 1,
				left   = 1,
				right  = 1,
				widget = wibox.container.margin,
			},
			bg     = beautiful.accent_dark,
			widget = wibox.container.background,
		}

		titlebars.left = awful.titlebar(c, {
			position = "left",
			size     = 2,
			bg       = gears.color.transparent,
		})
		titlebars.left.widget = wibox.widget {
			{
				{
					bg     = beautiful.accent_bright,
					widget = wibox.container.background,
				},
				left   = 1,
				widget = wibox.container.margin,
			},
			bg     = beautiful.accent_dark,
			widget = wibox.container.background,
		}

		titlebars.right = awful.titlebar(c, {
			position = "right",
			size     = 2,
			bg       = gears.color.transparent,
		})
		titlebars.right.widget = wibox.widget {
			{
				{
					bg     = beautiful.accent_bright,
					widget = wibox.container.background,
				},
				right  = 1,
				widget = wibox.container.margin,
			},
			bg     = beautiful.accent_dark,
			widget = wibox.container.background,
		}
	end)
end

return main
