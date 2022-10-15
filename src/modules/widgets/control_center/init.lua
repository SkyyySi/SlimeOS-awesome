local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local naughty   = require("naughty")
local beautiful = require("beautiful")
local util      = require("modules.lib.util")
local globals   = require("modules.lib.globals")
local buttonify = require("modules.lib.buttonify")
local button = require("modules.widgets.control_center.button")

--local ffi = require("ffi")
--ffi.cdef [[
--int run(int buff_size);
--]]
--local sound_meter = ffi.load(util.get_script_path().."sound_meter.so")

local function fixed_widget(widget)
	return wibox.widget {
		{
			{
				widget,
				layout = wibox.layout.fixed.horizontal,
			},
			layout = wibox.layout.fixed.vertical,
		},
		strategy = "exact",
		widget = wibox.container.constraint,
	}
end

---@param widget wibox.widget
---@param args? table<string, any>
local function widget_wrapper(widget, args)
	args = util.default(args, {})
	args = {
		inner_margin = util.default(args.inner_margin, util.scale(10)), ---@type number
		outer_margin = util.default(args.outer_margin, util.scale(20)), ---@type number
	}

	return wibox.widget {
		{
			{
				widget,
				margins = args.inner_margin,
				widget  = wibox.container.margin,
			},
			bg                 = beautiful.color.current.active,
			fg                 = beautiful.color.current.foreground,
			shape              = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, util.scale(15)) end,
			shape_border_width = util.scale(2),
			shape_border_color = beautiful.color.current.background,
			widget             = wibox.container.background,
		},
		top    = args.outer_margin,
		left   = args.outer_margin,
		right  = args.outer_margin,
		widget = wibox.container.margin,
	}
end

local function main(args)
	args = util.default(args, {})
	args = {
		screen = util.default(args.screen, screen.primary),
	}

	if not __SOUND_METER_SIGNALS_ALREADY_CREATED then
		__SOUND_METER_SIGNALS_ALREADY_CREATED = true

		awful.spawn.with_line_callback(util.get_script_path().."ALSASoundMeter/sound_meter", {
			stdout = function(line)
				local line_num = tonumber(line) or 0
				awesome.emit_signal("control_center::sound_meter", line_num)
			end,
		})
	end

	if not __CPU_METER_SIGNALS_ALREADY_CREATED then
		__CPU_METER_SIGNALS_ALREADY_CREATED = true

		gears.timer {
			timeout = 0.25,
			autostart = true,
			call_now = true,
			callback = function()
				awful.spawn.easy_async([[bash -c "cat <(grep 'cpu ' /proc/stat) <(sleep 1 && grep 'cpu ' /proc/stat) | awk -v RS='' '{printf \"%f\n\", ($13-$2+$15-$4)*100/($13-$2+$15-$4+$16-$5)}'"]], function(stdout, stderr, reason, exit)
					local usage = tonumber(stdout) or 0
					awesome.emit_signal("control_center::cpu_meter", usage)
				end)
			end,
		}
	end

	local popup = wibox {
		height  = util.scale(800),
		width   = util.scale(350),
		shape   = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, util.scale(20)) end,
		visible = false,
		ontop   = true,
		screen  = args.screen,
		bg      = beautiful.color.current.background.."80",
	}

	--awful.placement.bottom_right(popup, {
	--	honor_workarea = true,
	--	margins = util.scale(10),
	--})

	function popup:toggle()
		self.visible = not self.visible
	end

	local parts = {}
	parts.media_control = {}
	parts.media_control.current_metadata = {}

	parts.media_control.title = wibox.widget {
		markup = "Title goes here",
		font   = "Roboto, Bold "..beautiful.font_size,
		widget = wibox.widget.textbox,
	}

	parts.media_control.artist = wibox.widget {
		markup = "Artist(s) go(es) here",
		font   = "Roboto "..beautiful.font_size,
		widget = wibox.widget.textbox,
	}

	parts.media_control.title_artist = wibox.widget {
		parts.media_control.title,
		parts.media_control.artist,
		layout = wibox.layout.fixed.vertical,
	}

	parts.media_control.progess_bar = wibox.widget {
		min_value        = 0,
		max_value        = 100,
		color            = beautiful.color.current.accent,
		background_color = beautiful.color.current.background,
		border_color     = beautiful.color.current.background,
		border_width     = util.scale(2),
		shape            = gears.shape.rounded_bar,
		bar_shape        = gears.shape.rounded_bar,
		widget           = wibox.widget.progressbar,
	}

	parts.media_control.cover_art = wibox.widget {
		valign       = "top",
		clip_shape   = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, util.scale(10)) end,
		forced_width = util.scale(200),
		resize       = true,
		widget       = wibox.widget.imagebox,
	}

	parts.media_control.cover_art_container_background = wibox.widget {
		widget = wibox.container.background,
	}

	buttonify {
		widget = parts.media_control.cover_art_container_background,
		button_callback_release = function(w, b)
			if b == 1 and parts.media_control.cover_art and parts.media_control.cover_art ~= "" then
				awful.spawn { util.default(globals.web_browser, "firefox"), parts.media_control.current_metadata.art_url }
			end
		end,
	}

	parts.media_control.cover_art_container = wibox.widget {
		parts.media_control.cover_art,
		parts.media_control.cover_art_container_background,
		layout = wibox.layout.stack,
	}

	parts.media_control.buttons = {}
	parts.media_control.buttons.previous = wibox.widget {
		{
			{
				text   = "<",
				align  = "center",
				widget = wibox.widget.textbox,
			},
			widget = wibox.container.background,
		},
		bg                 = beautiful.color.current.background,
		shape              = gears.shape.circle,
		shape_border_width = util.scale(4),
		shape_border_color = beautiful.color.current.background,
		widget             = wibox.container.background,
	}

	parts.media_control.buttons.play_pause = wibox.widget {
		{
			{
				text   = "||",
				align  = "center",
				widget = wibox.widget.textbox,
			},
			widget = wibox.container.background,
		},
		bg                 = beautiful.color.current.background,
		shape              = gears.shape.circle,
		shape_border_width = util.scale(4),
		shape_border_color = beautiful.color.current.background,
		widget             = wibox.container.background,
	}

	parts.media_control.buttons.next = wibox.widget {
		{
			{
				text   = ">",
				align  = "center",
				widget = wibox.widget.textbox,
			},
			widget = wibox.container.background,
		},
		bg                 = beautiful.color.current.background,
		shape              = gears.shape.circle,
		shape_border_width = util.scale(4),
		shape_border_color = beautiful.color.current.background,
		widget             = wibox.container.background,
	}

	buttonify { parts.media_control.buttons.previous.widget, button_callback_release = function(w, b) if b == 1 then awesome.emit_signal("playerctl::previous") end end, }
	buttonify { parts.media_control.buttons.play_pause.widget, button_callback_release = function(w, b) if b == 1 then awesome.emit_signal("playerctl::play-pause") end end, }
	buttonify { parts.media_control.buttons.next.widget, button_callback_release = function(w, b) if b == 1 then awesome.emit_signal("playerctl::next") end end, }

	parts.media_control.widget_grid = wibox.widget {
		homogeneous     = true,
		expand          = true,
		forced_num_cols = 10,
		forced_num_rows = 10,
		forced_height   = util.scale(140),
		layout          = wibox.layout.grid,
	}

	parts.media_control.widget_grid:add_widget_at(wibox.widget {
		parts.media_control.title,
		widget = wibox.container.background,
	}, 1, 1, 2, 6)

	parts.media_control.widget_grid:add_widget_at(wibox.widget {
		parts.media_control.artist,
		widget = wibox.container.background,
	}, 3, 1, 2, 6)

	parts.media_control.widget_grid:add_widget_at(wibox.widget {
		parts.media_control.cover_art_container,
		bg                 = beautiful.color.current.background,
		shape              = function(cr, w, h) gears.shape.rounded_rect(cr, w, w, util.scale(10)) end, -- Using the width as the height parameter forces the shape to become a square
		shape_border_width = util.scale(2),
		shape_border_color = beautiful.color.current.background,
		widget             = wibox.container.background,
	}, 1, 7, 9, 4)

	parts.media_control.widget_grid:add_widget_at((wibox.widget {
		parts.media_control.progess_bar,
		widget = wibox.container.background,
	}), 10, 1, 1, 10)

	parts.media_control.widget_grid:add_widget_at({
		parts.media_control.buttons.previous,
		margins = util.scale(4),
		widget = wibox.container.margin,
	}, 5, 1, 4, 2)
	parts.media_control.widget_grid:add_widget_at({
		parts.media_control.buttons.play_pause,
		margins = util.scale(4),
		widget = wibox.container.margin,
	}, 5, 3, 4, 2)
	parts.media_control.widget_grid:add_widget_at({
		parts.media_control.buttons.next,
		margins = util.scale(4),
		widget = wibox.container.margin,
	}, 5, 5, 4, 2)

	parts.media_control.widget = widget_wrapper(parts.media_control.widget_grid)

	parts.brightness_control = {}

	parts.brightness_control.widget = wibox.widget {
		{
			{
				id = "brightness_label",
				text   = "50%",
				font   = "MesloLGS NF, Semibold "..beautiful.font_size,
				align  = "center",
				forced_width = util.scale(70),
				widget = wibox.widget.textbox,
			},
			shape              = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, util.scale(10)) end,
			shape_border_width = util.scale(4),
			shape_border_color = beautiful.color.current.background,
			bg                 = beautiful.color.current.background,
			widget             = wibox.container.background,
		},
		{
			{
				{
					id = "brightness_slider",
					bar_shape           = gears.shape.rounded_bar,
					bar_height          = util.scale(4),
					bar_color           = beautiful.color.current.background.."80",
					handle_color        = beautiful.color.current.accent,
					handle_shape        = gears.shape.circle,
					handle_border_color = beautiful.color.current.background,
					handle_border_width = util.scale(2),
					value               = 50,
					minimum             = 0,
					maximum             = 100,
					widget              = wibox.widget.slider,
				},
				left   = util.scale(8),
				widget = wibox.container.margin,
			},
			forced_height = util.scale(30),
			layout        = wibox.layout.fixed.vertical,
		},
		layout = wibox.layout.align.horizontal,
	}

	parts.brightness_control.dynamic_elements = {}

	for _, child in pairs(parts.brightness_control.widget:get_children_by_id("brightness_label")) do
		table.insert(parts.brightness_control.dynamic_elements, child)
	end

	for _, child in pairs(parts.brightness_control.widget:get_children_by_id("brightness_slider")) do
		table.insert(parts.brightness_control.dynamic_elements, child)

		child:connect_signal("property::value", function(self)
			local v = tostring(self.value or 50)
			awful.spawn { "xbacklight", "-set", v }
			for _, element in ipairs(parts.brightness_control.dynamic_elements) do
				if element ~= self then
					element.value = self.value or 50
					element.text = " "..v.."%"
				end
			end
		end)
	end

	parts.brightness_control.update_timer = gears.timer {
		timeout = 1,
		autostart = true,
		call_now = true,
		callback = function(self)
			awful.spawn.easy_async({ "xbacklight", "-get" }, function(stdout, stderr, reason, exit_code)
				stdout = stdout:gsub("%s", "")
				for _, element in ipairs(parts.brightness_control.dynamic_elements) do
					element.value = tonumber(stdout) or 50
					element.text = " "..stdout.."%"
				end
			end)
		end,
	}

	parts.volume_control = {}

	parts.volume_control.icons = {
		muted  = "🔇",
		low    = "🔈",
		medium = "🔉",
		high   = "🔊"
	}

	parts.volume_control.volume_slider = wibox.widget {
		bar_shape           = gears.shape.rounded_bar,
		bar_height          = util.scale(4),
		bar_color           = beautiful.color.current.background.."80",
		handle_color        = beautiful.color.current.accent,
		handle_shape        = gears.shape.circle,
		handle_border_color = beautiful.color.current.background,
		handle_border_width = util.scale(2),
		value               = 50,
		minimum             = 0,
		maximum             = 100,
		widget              = wibox.widget.slider,
	}

	parts.volume_control.volume_label = wibox.widget {
		text   = parts.volume_control.icons.medium.." 50%",
		font   = "MesloLGS NF, Semibold "..beautiful.font_size,
		align  = "center",
		forced_width = util.scale(70),
		widget = wibox.widget.textbox,
	}

	parts.volume_control.volume_label_background_container = wibox.widget {
		{
			parts.volume_control.volume_label,
			widget = wibox.container.background,
		},
		shape              = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, util.scale(10)) end,
		shape_border_width = util.scale(4),
		shape_border_color = beautiful.color.current.background,
		bg                 = beautiful.color.current.background,
		widget             = wibox.container.background,
	}

	buttonify {
		widget = parts.volume_control.volume_label_background_container.widget,
		button_callback_release = function(w, b)
			if b == 1 then
				awesome.emit_signal("pulseaudio::toggle_mute")
			end
		end,
	}

	parts.volume_control.visualizer = wibox.widget {
		max_value        = 80,
		background_color = gears.color.transparent,
		color            = "#00000030",
		step_width       = util.scale(1),
		step_spacing     = util.scale(0),
		step_shape       = gears.shape.rounded_bar,
		widget           = wibox.widget.graph,
	}

	--[[
	function parts.volume_control.visualizer_add_value()
		parts.volume_control.visualizer:add_value(sound_meter.run(2048))
	end

	parts.volume_control.visualizer_timer = gears.timer {
		timeout   = 0.25,
		autostart = true,
		call_now  = true,
		callback  = function()
			async.waterfall({
				function(cb)
					parts.volume_control.visualizer_add_value() -- <- Blocking task, takes about 1/2 second
				end,
			}, function(err, data)
				notify(err)
				notify(data)
			end)
		end,
	}
	--]]

	parts.volume_control.widget_flash_background = wibox.widget {
		bg      = "#FFFFFF",
		opacity = 0,
		widget  = wibox.container.background,
	}

	parts.volume_control.widget_flash = wibox.widget {
		--parts.volume_control.widget_flash_background,
		--{
				{
					parts.volume_control.volume_label_background_container,
					{
						orientation = "horizontal",
						thickness = 0,
						forced_width = util.scale(10),
						widget = wibox.widget.separator,
					},
					{
						parts.volume_control.visualizer,
						parts.volume_control.volume_slider,
						layout = wibox.layout.stack,
					},
					layout = wibox.layout.fixed.horizontal,
				},
				forced_height = util.scale(30),
				layout        = wibox.layout.fixed.vertical,
		--},
		--layout = wibox.layout.stack,
	}

	local function space_widgets(widgets)
		local composed = wibox.widget {
			layout = wibox.layout.fixed.vertical,
		}

		local first = true
		for i, widget in ipairs(widgets) do
			if first then
				first = false
				table.insert(composed.children, widget)
			else
				table.insert(composed.children, wibox.widget {
					orientation = "horizontal",
					forced_height = util.scale(10),
					color = gears.color.transparent,
					widget = wibox.widget.separator,
				})
				table.insert(composed.children, widget)
			end
		end

		composed:emit_signal("widget::layout_changed")
		composed:emit_signal("widget::redraw_needed")

		return composed
	end

	parts.volume_control.widget = widget_wrapper(wibox.widget {
		space_widgets {
			parts.volume_control.widget_flash,
			parts.brightness_control.widget,
		},
		margins = util.scale(10),
		widget  = wibox.container.margin,
	}, {
		inner_margin = 0,
	})

	--awful.spawn.with_line_callback(util.get_script_path().."ALSASoundMeter/sound_meter", {
	--	stdout = function(line)
	--		local line_num = tonumber(line)
	--		parts.volume_control.visualizer:add_value(((line_num or 30) - 30) * 2)
	--		parts.volume_control.widget_flash_background:set_opacity((line_num or 0) / 100)
	--	end,
	--})

	parts.volume_control.widget:connect_signal("button::press", function(_,_,_,b)
		if b == 4 then
			awesome.emit_signal("pulseaudio::increase_volume")
		elseif b == 5 then
			awesome.emit_signal("pulseaudio::decrease_volume")
		end
	end)

	parts.volume_control.volume_slider:connect_signal("property::value", function(_, value) ---@param value number
		awesome.emit_signal("pulseaudio::set_volume", value)
	end)

	local is_muted = false
	function parts.volume_control:select_icon(volume) ---@param volume? number
		if is_muted then
			self.current_icon = parts.volume_control.icons.muted.." "..tostring(volume).."%"
		elseif self.volume >= 35 and self.volume < 60 then
			self.current_icon = parts.volume_control.icons.medium.." "..tostring(volume).."%"
		elseif self.volume >= 60 then
			self.current_icon = parts.volume_control.icons.high.." "..tostring(volume).."%"
		else
			self.current_icon = parts.volume_control.icons.low.." "..tostring(volume).."%"
		end

		return self.current_icon
	end

	local old_fg
	awesome.connect_signal("pulseaudio::is_muted", function(status)
		is_muted = status

		if is_muted then
			parts.volume_control.volume_label_background_container:set_fg("#AAAAAA")
			return
		end

		parts.volume_control.volume_label_background_container:set_fg(nil)
	end)

	---@param volume number
	function parts.volume_control:set_volume(volume)
		self.volume = volume
		self.volume_slider:set_value(volume)
		self:select_icon()
	end

	parts.stats = {}

	parts.stats.audio = {}

	parts.stats.audio.graph = wibox.widget {
		min_value        = 0,
		max_value        = 100,
		color            = beautiful.color.current.cyan,
		background_color = beautiful.color.current.background,
		border_color     = beautiful.color.current.background,
		border_width     = util.scale(2),
		forced_height    = util.scale(16),
		shape            = gears.shape.rounded_bar,
		bar_shape        = gears.shape.rounded_bar,
		widget           = wibox.widget.progressbar,
	}

	parts.stats.audio.label = wibox.widget {
		text         = "📢",
		align        = "center",
		halign       = "center",
		forced_width = util.scale(28),
		widget       = wibox.widget.textbox,
	}

	awesome.connect_signal("control_center::sound_meter", function(gain) ---@param gain number
		parts.stats.audio.graph.value = gain
	end)

	parts.stats.audio.widget = wibox.widget {
		parts.stats.audio.label,
		parts.stats.audio.graph,
		layout = wibox.layout.fixed.horizontal
	}

	parts.stats.cpu = {}

	parts.stats.cpu.graph = wibox.widget {
		min_value        = 0,
		max_value        = 100,
		color            = beautiful.color.current.green,
		background_color = beautiful.color.current.background,
		border_color     = beautiful.color.current.background,
		border_width     = util.scale(2),
		forced_height    = util.scale(16),
		shape            = gears.shape.rounded_bar,
		bar_shape        = gears.shape.rounded_bar,
		widget           = wibox.widget.progressbar,
	}

	parts.stats.cpu.label = wibox.widget {
		text         = "",
		align        = "center",
		halign       = "center",
		forced_width = util.scale(28),
		widget       = wibox.widget.textbox,
	}

	awesome.connect_signal("control_center::cpu_meter", function(usage) ---@param usage number
		parts.stats.cpu.graph.value = usage
	end)

	parts.stats.cpu.widget = wibox.widget {
		parts.stats.cpu.label,
		parts.stats.cpu.graph,
		layout = wibox.layout.fixed.horizontal
	}

	parts.stats.separator = wibox.widget {
		thickness   = util.scale(4),
		forced_height = util.scale(4),
		color       = gears.color.transparent,
		orientation = "horizontal",
		widget      = wibox.widget.separator,
	}

	parts.stats.widget = widget_wrapper(wibox.widget {
		parts.stats.audio.widget,
		parts.stats.separator,
		parts.stats.cpu.widget,
		layout = wibox.layout.fixed.vertical,
	}, {
		--inner_margin = 0;
	})

	parts.notifications = {}

	parts.notifications.dismiss_button = wibox.widget {
		{
			{
				text   = "Dismiss all",
				align  = "center",
				valign = "center",
				widget = wibox.widget.textbox,
			},
			forced_height = util.scale(30),
			widget        = wibox.container.background,
		},
		shape              = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, util.scale(10)) end,
		shape_border_width = util.scale(4),
		shape_border_color = beautiful.color.current.background,
		bg                 = beautiful.color.current.background,
		widget             = wibox.container.background,
	}

	buttonify {
		widget = parts.notifications.dismiss_button.widget,
		button_callback_release = function(w, b)
			if b == 1 then
				naughty.destroy_all_notifications()
			end
		end,
	}

	parts.notifications.container = wibox.widget {
		nil,
		{
			base_layout = wibox.widget {
				spacing_widget = wibox.widget {
					orientation = "horizontal",
					widget      = wibox.widget.separator,
				},
				forced_height = util.scale(30),
				spacing       = util.scale(3),
				layout        = wibox.layout.fixed.vertical,
			},
			widget_template = {
				{
					naughty.widget.icon,
					{
						naughty.widget.title,
						naughty.widget.message,
						{
							layout = wibox.widget {
								-- Adding the wibox.widget allows to share a
								-- single instance for all spacers.
								spacing_widget = wibox.widget {
									orientation = "horizontal",
									span_ratio  = 0.9,
									widget      = wibox.widget.separator,
								},
								spacing = util.scale(3),
								layout  = wibox.layout.flex.vertical,
							},
							widget = naughty.list.widgets,
						},
						layout = wibox.layout.align.vertical,
					},
					spacing    = util.scale(10),
					fill_space = true,
					layout     = wibox.layout.fixed.vertical,
				},
				margins = util.scale(5),
				widget  = wibox.container.margin,
			},
			widget = naughty.list.notifications,
		},
		parts.notifications.dismiss_button,
		layout = wibox.layout.align.vertical,
	}

	parts.notifications.widget = wibox.widget {
		widget_wrapper(parts.notifications.container),
		bottom = util.scale(20),
		widget = wibox.container.margin,
	}

	parts.buttongrid = {}

	parts.buttongrid.container = wibox.widget {
		homogeneous     = true,
		expand          = true,
		forced_num_cols = 3, -- y
		forced_num_rows = 3, -- x
		spacing = util.scale(10),
		layout = wibox.layout.grid,
	}

	parts.buttongrid.container:add(button {
		is_active    = true,
		label_normal = "Dark\nMode",
		label_active = "Dark\nMode",
		onclick      = function(self, b)
			--local retval = ("The button '%s' was clicked (with mouse button %s).\nIs active: %s"):format(self, b, self.is_active)
			--notify(retval)
			beautiful.color.switch_scheme()
		end,
	})

	--for i = 1, parts.buttongrid.container.forced_num_cols * parts.buttongrid.container.forced_num_rows do
	--	parts.buttongrid.container:add(button {
	--		label_normal = "Btn #" .. tostring(i),
	--		label_active = "Btn #" .. tostring(i),
	--	})
	--end

	parts.buttongrid.widget = wibox.widget {
		widget_wrapper(parts.buttongrid.container),
		bottom = util.scale(20),
		widget = wibox.container.margin,
	}

	popup.widget = wibox.widget {
		{
			{
				parts.media_control.widget,
				parts.volume_control.widget,
				parts.stats.widget,
				layout = wibox.layout.fixed.vertical,
			},
			parts.buttongrid.widget,
			nil,--parts.notifications.widget,
			layout = wibox.layout.align.vertical,
		},
		bg                 = gears.color.transparent,
		shape              = popup.shape,
		shape_border_width = util.scale(2),
		shape_border_color = beautiful.color.current.active,
		widget             = wibox.container.background,
	}

	awesome.connect_signal("pulseaudio::volume", function(volume) ---@param volume number
		parts.volume_control:set_volume(volume)
		parts.volume_control.volume_label:set_text(parts.volume_control:select_icon(volume))
	end)

	awesome.connect_signal("playerctl::metadata", function(metadata) ---@param metadata playerctl_metadata
		metadata = util.default(metadata, {})
		parts.media_control.current_metadata = metadata

		parts.media_control.cover_art:set_image(metadata.art_cairo)
		parts.media_control.title:set_text(metadata.title)
		parts.media_control.artist:set_text(metadata.artist)
		parts.media_control.progess_bar:set_value(metadata.completion)
		popup.widget:emit_signal("widget::redraw_needed")
	end)

	return popup
end

return main
