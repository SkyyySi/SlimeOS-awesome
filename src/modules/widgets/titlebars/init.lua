local awful           = require("awful")
local wibox           = require("wibox") ---@type wibox
local gears           = require("gears")
local beautiful       = require("beautiful")
local buttonify       = require("modules.lib.buttonify")
local util            = require("modules.lib.util")
local absolute_center = require("modules.lib.absolute_center")
local bling           = require("modules.external.bling")

awful.titlebar = require(... ..".awful_titlebar_patched")

wibox.layout.overflow = require("wibox_layout_overflow")

local font_size = beautiful.font_size or "12"

local function make_button(widget, args)
	args.normal   = args.normal   or "#FF000060"
	args.hover    = args.hover    or "#FF0000B0"
	args.press    = args.press    or "#FF0000FF"
	args.release  = args.release  or args.hover or"#FF0000B0"
	args.callback = args.callback or function() end
	args.shape    = args.shape    or function(cr, w, h) gears.shape.circle(cr, w, h) end

	---@type "minimize"|"maximize"|"close"|"floating"|"sticky"|"ontop"|"below" "below"=TBA
	args.action = args.action

	do return widget end

	local new_widget = wibox.widget {
		{
			{
				widget,
				margins = util.scale(2),
				widget  = wibox.container.margin,
			},
			id     = "background_role",
			bg     = args.normal or "#FF0000B0",
			shape  = args.shape,
			shape_border_width = 1,
			shape_border_color = gears.color.transparent,
			widget = wibox.container.background,
		},
		margins = util.scale(3),
		widget  = wibox.container.margin,
	}

	util.for_children(new_widget, "background_role", function(child)
		buttonify {
			widget                  = child,
			mouse_effects           = true,
			button_color_normal     = args.normal,
			button_color_hover      = args.hover,
			button_color_press      = args.press,
			button_color_release    = args.release,
			button_callback_release = args.callback,
		}
	end)

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

				local vols = util.split(line, ",") ---@type string[]
				local vols_n = {} ---@type number[]

				for i,v in pairs(vols) do
					vols_n[i] = tonumber(v) or 0
				end

				local vol = math.floor(util.average(vols_n))
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
		bar_color           = beautiful.titlebar_fg_normal,
		handle_color        = beautiful.titlebar_bg_normal,
		handle_shape        = gears.shape.circle,
		handle_border_color = beautiful.titlebar_fg_normal,
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
		if not type(vol) == "number" then
			return
		end

		if pulse_sink_input_id_with_clients_pids[sink_id_sig] == pid then
			sink_id = sink_id_sig
			slider.value = vol
		end
	end)

	awesome.connect_signal("pulseaudio::client_is_sink_input", function(pid_sig, sink_id_sig)
		if pid_sig == pid then
			slider.visible = true
		end
	end)

	return widget
end

local gen_tabbar
do
	local function clear(tb)
		for k, _ in pairs(tb) do
			tb[k] = nil
		end
	end

	local function c_is_valid(c)
		return pcall(function() return c.valid end) and c.valid
	end

	local function gen_tab(base)
		if not c_is_valid(base.client) then
			return
		end

		local widget = wibox.widget {
			{
				{
					{
						{
							nil,
							{
								{
									id     = "icon_role",
									widget = wibox.widget.imagebox,
								},
								{
									id     = "title_role",
									widget = wibox.widget.textbox,
								},
								spacing = util.scale(8),
								layout  = wibox.layout.fixed.horizontal,
							},
							{
								{
									{
										{
											id     = "close_button_icon_role",
											widget = wibox.widget.imagebox,
										},
										margins = util.scale(6),
										widget  = wibox.container.margin,
									},
									id     = "close_button_background_role",
									shape  = gears.shape.circle,
									widget = wibox.container.background,
								},
								margins = util.scale(2),
								widget  = wibox.container.margin,
							},
							layout = wibox.layout.align.horizontal,
						},
						margins = util.scale(8),
						widget  = wibox.container.margin,
					},
					id     = "background_role",
					shape  = function(cr, w, h) gears.shape.partially_rounded_rect(cr, w, h, true, true, false, false, util.scale(12)) end,
					widget = wibox.container.background,
				},
				top    = util.scale(4),
				left   = util.scale(4),
				right  = util.scale(4),
				bottom = 0,
				widget = wibox.container.margin,
			},
			strategy     = "exact",
			forced_width = util.scale(200),
			widget       = wibox.container.constraint,
		}

		util.for_children(widget, "title_role", function(child)
			child.text = base.client.name

			base.client:connect_signal("property::name", function(c)
				child.text = c.name
			end)
			--[==[
			awesome.connect_signal("titlebars::update_title", function(c_sig)
				if not c_is_valid(c_sig) then
					return
				end

				if c_sig == base.client and c_sig._app_title and c_sig._app_title ~= "" then
					child.text = c_sig._app_title
				end
			end)
			--]==]
		end)

		util.for_children(widget, "icon_role", function(child)
			child.image = base.client.icon

			--[= =[
			awesome.connect_signal("titlebars::update_icon", function(c_sig)
				if not c_is_valid(c_sig) then
					return
				end

				if c_sig == base.client and c_sig._app_icon and c_sig._app_icon ~= "" then
					child.icon = c_sig._app_icon
				end
			end)
			--]==]
		end)

		util.for_children(widget, "close_button_icon_role", function(child)
			child.image = gears.color.recolor_image(beautiful.titlebar_close_button_normal, beautiful.fg_normal)
		end)

		util.for_children(widget, "close_button_background_role", function(child)
			buttonify {
				widget = child,
				button_callback_release = function(_, button)
					if button == 1 then
						awesome.emit_signal("tabbar::client::kill", base.client)
					end
				end
			}
		end)

		do
			local function update_bg(c, child)
				if c.active then
					child.bg = c._active_tab_bg or "#FFFFFF20"
				else
					child.bg = gears.color.transparent
				end
			end

			util.for_children(widget, "background_role", function(child)
				update_bg(base.client, child)

				base.client:connect_signal("property::active", function(c)
					update_bg(c, child)
				end)

				child:connect_signal("button::release", function(_,_,_, b)
					awesome.emit_signal("tabbar::client::switch", base.client)
				end)
			end)
		end

		return widget
	end

	local function gen_tab_group(base, on_change)
		on_change = on_change or function(self) end
		local tg, proxy, mt = {}, (base or {}), {}
		setmetatable(tg, mt)

		do
			local i, count = 0, 0
			function mt:__call()
				local ret
				i, ret = next(proxy, count)
				count = count + 1
				if count > #proxy then
					count = 0
					return
				end
				return ret
			end
		end

		function mt:add(item)
			table.insert(proxy, item)
			on_change(self)
		end

		function mt:clear()
			clear(proxy)
			on_change(self)
		end

		function mt:get_selected()
			for _, v in ipairs(proxy) do
				if v.selected then
					return v
				end
			end

			return proxy[1]
		end

		function mt:get_proxy()
			return proxy
		end

		function mt:__index(k)
			local v = proxy[k]
			if v ~= nil then
				return v
			end
			return mt[k]
		end

		function mt:__newindex(k, v)
			proxy[k] = v
			on_change(self)
		end

		return tg
	end

	local function new_instance(c)
		if c._app_data and c._app_data.cmdline then
			awful.spawn(c._app_data.cmdline)
			return
		end

		awful.spawn.easy_async({ "readlink", "-f", "/proc/"..tostring(c.pid).."/exe" }, function(stdout, stderr, reason, exit_code)
			if not stdout or stdout == "" or exit_code > 0 then
				return
			end

			local cmd = util.strip(stdout)
			awful.spawn(cmd)
		end)
	end

	local tab_groups = {}
	local tabs = {}

	gen_tabbar = function(c, args)
		if not c or not c.class then
			error("Error in titlebars/init.lua: Could not generate tab bar")
		end

		local client_class = c.class

		if tab_groups[client_class] then
			tab_groups[client_class]:add {
				client = c,
				selected = false,
			}
		else
			tab_groups[client_class] = gen_tab_group({
				{
					client = c,
					selected = true,
				}
			}, function(self)
				--
			end)
			--for _, cl in ipairs(client.get()) do
			--	if cl.class == client_class and cl ~= c then
			--		cl.tab_group = tab_groups[cl.class] or tab_groups[client_class]
			--		tab_groups[client_class]:add {
			--			client = cl,
			--			selected = false,
			--		}
			--	end
			--end
		end

		c._active_tab_bg = args.active_tab_bg

		awesome.connect_signal("tabbar::client::kill", function(killed_client)
			if not c_is_valid(killed_client) then return end
			--if not tab_groups[client_class] then
			--	return
			--end

			--for k, v in ipairs(tab_groups[client_class]) do
			--	notifyf("%s: %s", v, killed_client == v)
			--end
			killed_client:kill()
			--awesome.emit_signal("tabbar::client::switch")
		end)

		if not tabs[client_class] then
			tabs[client_class] = wibox.widget {
				layout = wibox.layout.overflow.horizontal,
			}
			tabs[client_class].clear = function(self)
				self:remove_widgets(unpack(self.children))
				clear(self.children)
				self:emit_signal("widget::layout_changed")
				self:emit_signal("widget::redraw_needed")
			end
			tabs[client_class].spawn_new_instance_of_selected = function(self)
				for c_tab_group in tab_groups[client_class] do
					if c_tab_group.selected then
						new_instance(c_tab_group.client)
						return
					end
				end
			end
		end

		for c_tab_group in tab_groups[client_class] do
			local w = gen_tab(c_tab_group)
			if w then
				tabs[client_class]:add(w)
			end
		end

		local spawn_new_instance_widget = wibox.widget {
			{
				{
					{
						{
							bg     = "#FFFFFF",
							shape  = function(cr, w, h) gears.shape.cross(cr, w, h, h/10) end,
							widget = wibox.container.background,
						},
						forced_width  = util.scale(16),
						forced_height = util.scale(16),
						widget = wibox.container.constraint,
					},
					margins = util.scale(16),
					widget  = wibox.container.margin,
				},
				id     = "background_role",
				shape  = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, util.scale(4)) end,
				widget = wibox.container.background,
			},
			margins = util.scale(4),
			widget  = wibox.container.margin,
		}

		util.for_children(spawn_new_instance_widget, "background_role", function(child)
			buttonify {
				widget = child,
				button_callback_release = function(_, b)
					if b == 1 then
						tabs[client_class]:spawn_new_instance_of_selected()
					end
				end,
			}
		end)

		local widget = wibox.widget {
			{
				{
					tabs[client_class],
					spawn_new_instance_widget,
					layout = wibox.layout.align.horizontal,
				},
				{
					buttons = args.buttons,
					widget  = wibox.widget.base.make_widget,
				},
				layout = wibox.layout.align.horizontal,
			},
			top    = util.scale(8),
			widget = wibox.container.margin,
		}

		return widget
	end

	local function redraw_tabs_for(c, force_switch_client)
		if not tab_groups[c.class] or not tabs[c.class] then
			return
		end

		tabs[c.class]:clear()
		tab_groups[c.class]:clear()

		for _, cl in ipairs(client.get()) do
			if cl.class == c.class then
				tab_groups[c.class]:add {
					client = cl,
					selected = (cl == c),
					active_tab_bg = c._active_tab_bg
				}
			end
		end

		local force_switch_done = false
		for c_tab_group in tab_groups[c.class] do
			local cl = c_tab_group.client
			if c_is_valid(cl) then
				local w = gen_tab(c_tab_group)
				if w then
					tabs[c.class]:add(w)
				end
				if not cl.minimized then
					local geo = cl:geometry()
					c.x = geo.x
					c.y = geo.y
					c.width = geo.width
					c.height = geo.height
					c.floating = cl.floating
					c.maximized = cl.maximized
				end
				cl.minimized = not (((not force_switch_done) and force_switch_client) or (cl == c))

				if not cl.minimized then
					c:activate {
						raise   = false,
						context = "tab_switched",
					}
				end
			end
			force_switch_done = true
		end
	end

	client.connect_signal("manage",   redraw_tabs_for)
	client.connect_signal("unmanage", function(c)
		redraw_tabs_for(c, true)
	end)
	awesome.connect_signal("tabbar::client::switch", redraw_tabs_for)
end

local function main(args)
	args = util.default(args, {})
	args = {
		border_radius = util.default(args.border_radius, beautiful.border_radius, 0)
	}

	client.connect_signal("request::titlebars", function(c)
		if c.requests_no_titlebar then return end

		if c.maximized or c.fullscreen then
			c.height = c.height - util.scale(40)
		end

		local menu = {
			{ "Close",        function() c:kill() end },
			{ "Maximize",     function() c.maximized = not c.maximized end },
			{ "Minimize",     function() c.minimized = not c.minimized end },
			{ "Sticky",       function() c.sticky = not c.sticky end },
			{ "Float / tile", function() c.floating = not c.floating end },
			{ "Keep above",   function() c.below = false; c.above = not c.above end },
			{ "Keep below",   function() c.above = false; c.below = not c.below end },
		}

		c.title_bar_menu = awful.menu {
			items = menu
		}

		-- buttons for the titlebar
		local buttons = {
			awful.button({}, 1, function()
				c:activate { context = "titlebar", action = "mouse_move"  }
			end),
			awful.button({}, 2, function()
				c.title_bar_menu:toggle()
			end),
			awful.button({}, 3, function()
				c:activate { context = "titlebar", action = "mouse_resize"}
			end),
		}

		c.titlebars = {}
		c.shape = function(cr, w, h)
			gears.shape.rounded_rect(cr, w, h, args.border_radius)
		end

		local bg = "#1E1F29"
		--- I use a custom theme for Firefox called "WaveFox", with
		--- semi-transparency enabled. In addtion, just matching the
		--- litteral string "firefox" is not enough here, because I
		--- also use a fork of Firefox, `firefox-kde-opensuse`, which
		--- uses that string as its WM_CLASS as well.
		if c.class:lower():match("^firefox.*") and c.type == "normal" then
			bg = bg.."B0"
		end

		get_clients_pids_with_pulse_sink_input_id()

		c.titlebars.top = awful.titlebar(c, {
			position = "top",
			font     = util.default(beautiful.titlebar_font, "Roboto, Semibold "..font_size),
			size     = util.scale(64),
			bg       = gears.color.transparent,
			shape = function(cr, w, h)
				gears.shape.rounded_rect(cr, w, h, util.scale(20))
			end,
		})
		local windows_title_widget = wibox.widget {
			align  = "center",
			--widget = awful.titlebar.widget.titlewidget(c),
			text = c.name,
			font = beautiful.titlebar_font or beautiful.font or ("Sans "..tostring(util.round(util.scale(12)))),
			widget = wibox.widget.textbox,
		}
		c.titlebars.top.widget = {
			{
				{
					{
						awful.titlebar.widget.floatingbutton(c),
						awful.titlebar.widget.stickybutton(c),
						awful.titlebar.widget.ontopbutton(c),
						volume_slider {
							client = c,
						},
						spacing = util.scale(2),
						layout  = wibox.layout.fixed.horizontal(),
					},
					gen_tabbar(c, {
						active_tab_bg = bg,
						buttons = buttons,
					}),
					{
						awful.titlebar.widget.minimizebutton(c),
						awful.titlebar.widget.maximizedbutton(c),
						awful.titlebar.widget.closebutton(c),
						spacing = util.scale(2),
						layout  = wibox.layout.fixed.horizontal(),
					},
					layout = wibox.layout.align.horizontal
				},
				bg = gears.color {
					type  = "linear",
					from  = { 0, 0 },
					to    = { 0, util.default(c.titlebars.top.size, c.titlebars.top.height, util.scale(64)) },
					stops = {
						{ 0, "#FFFFFF08" },
						{ 1, "#FFFFFF00" },
					},
				},
				widget = wibox.container.background,
			},
			bg = beautiful.bg_normal,
			--bg = bg,--util.default(beautiful.titlebar_bg_normal, beautiful.accent_bright, bg),
			widget = wibox.container.background,
		}

		--notify(("%s -> %.4f %.4f %.4f"):format(beautiful.color.blue, gears.color.parse_color(beautiful.color.blue)), 0)
		--notify(("%s -> %.4f %.4f %.4f"):format(util.color.alter_hsl(beautiful.color.blue, { l = 0.0 }, "add"), gears.color.parse_color(util.color.alter_hsl(beautiful.color.blue, { l = 0.0 }, "add"))), 0)

		awesome.emit_signal("all_apps::get", function(all_apps)
			if not all_apps then
				return
			end

			for k, app in pairs(all_apps) do
				if app.StartupWMClass == c.class and app.Name then
					windows_title_widget.text = app.Name
					c._app_title = app.Name
					c._app_icon  = app.icon_path
					c._app_cmd   = app.cmdline
					c._app_data  = app
					awesome.emit_signal("titlebars::update_app_data", c)
				end
			end
		end)

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

		--notify(beautiful.titlebar_width)
		c.titlebars.bottom = awful.titlebar(c, {
			position = "bottom",
			size     = 2,
			bg       = gears.color.transparent,
		})
		c.titlebars.bottom.widget = wibox.widget {
			{
				{
					bg     = bg,--util.default(beautiful.titlebar_bg_normal, beautiful.accent_bright, bg),
					widget = wibox.container.background,
				},
				bottom = 1,
				left   = 1,
				right  = 1,
				widget = wibox.container.margin,
			},
			bg     = bg,--util.default(beautiful.titlebar_bg, beautiful.accent_dark, "#DBE1EC"),
			widget = wibox.container.background,
		}

		c.titlebars.left = awful.titlebar(c, {
			position = "left",
			size     = 2,
			bg       = gears.color.transparent,
		})
		c.titlebars.left.widget = wibox.widget {
			{
				{
					bg     = bg,--util.default(beautiful.titlebar_bg_normal, beautiful.accent_bright, bg),
					widget = wibox.container.background,
				},
				left   = 1,
				widget = wibox.container.margin,
			},
			bg     = bg,--util.default(beautiful.titlebar_bg, beautiful.accent_dark, "#DBE1EC"),
			widget = wibox.container.background,
		}

		c.titlebars.right = awful.titlebar(c, {
			position = "right",
			size     = 2,
			bg       = gears.color.transparent,
		})
		c.titlebars.right.widget = wibox.widget {
			{
				{
					bg     = bg,--util.default(beautiful.titlebar_bg_normal, beautiful.accent_bright, bg),
					widget = wibox.container.background,
				},
				right  = 1,
				widget = wibox.container.margin,
			},
			bg     = bg,--util.default(beautiful.titlebar_bg, beautiful.accent_dark, "#DBE1EC"),
			widget = wibox.container.background,
		}

		c._titlebar_sizes = {
			top    = c.titlebars.top.size    or c.titlebars.top.height,
			bottom = c.titlebars.bottom.size or c.titlebars.bottom.height,
			left   = c.titlebars.left.size   or c.titlebars.left.width,
			right  = c.titlebars.right.size  or c.titlebars.right.width,
		}
	end)
end

return main
