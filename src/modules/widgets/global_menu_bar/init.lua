local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local util  = require("modules.lib.util")
local beautiful = require("beautiful")
local buttonify = require("modules.lib.buttonify")

local gmb = { mt = {} }
gmb.__index = gmb
gmb.mt.__index = gmb.mt
setmetatable(gmb, gmb.mt)

function gmb.create_button(args)
	args = util.default(args, {})
	args = {
		label = util.default(args.label, "-"),
		onclick = util.default(args.onclick, function() end),
	}

	local widget = wibox.widget {
		{
			{
				markup = args.label,
				widget = wibox.widget.textbox,
			},
			top    = util.scale(4),
			bottom = util.scale(4),
			left   = util.scale(12),
			right  = util.scale(12),
			widget = wibox.container.margin,
		},
		--shape  = function(cr, w, h)
		--	gears.shape.rounded_rect(cr, w, h, util.scale(4))
		--end,
		--shape_border_width = util.scale(1),
		--shape_border_color = "#808080",
		widget = wibox.container.background,
	}

	buttonify {
		widget = widget,
		button_callback_release = args.onclick,
	}

	--local full_widget = wibox.widget {
	--	widget,
	--	margins = util.scale(4),
	--	widget  = wibox.container.margin,
	--}

	return widget
end

function gmb:update()
	if #self.mt.holder > #self.mt.widget then
		for i = 1, #self.mt.widget do
			if self.mt.widget[i] ~= self.mt.holder[i] then
				self.mt.widget[i] = nil
			end
		end
	end

	for k, v in pairs(self.mt.holder) do
		if type(k) == "number" then
			self.mt.widget[k] = v
		end
	end

	self.mt.bar.widget.widget = wibox.widget {
		layout = wibox.layout.fixed.horizontal, -- I'm not sure why, but everything after `unpack()` gets discarded, so this has to be placed before it.
		unpack(self.mt.holder),
	}
end

function gmb:clear()
	for k, v in pairs(self.mt.holder) do
		self.mt.holder[k] = nil
	end

	self:update()
end

function gmb:__index(k)
	if self.mt.holder[k] then
		return self.mt.holder[k]
	elseif getmetatable(self)[k] then
		return getmetatable(self)[k]
	end
end

function gmb:__newindex(k, v)
	self.mt.holder[k] = v
	self:update()
end

function gmb:add(v)
	table.insert(self.mt.holder, v)
	self:update()
end

function gmb:pop(v)
	self.mt.holder[#self.mt.holder] = nil
	self:update()
end

function gmb.mt:new(args)
	args = util.default(args, {})
	args = {
		position = util.default(args.position, "top"),
		height = util.default(args.height, util.scale(28)),
		screen = util.default(args.screen, screen.primary),
	}

	local bar_widget_container = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
	}

	local bar_widget = wibox.widget {
		bar_widget_container,
		bg     = "#303030",
		widget = wibox.container.background,
	}

	local bar = awful.wibar {
		type     = "dock",
		position = "top",
		height   = util.scale(28),
		screen   = args.screen,
		bg       = gears.color.transparent,
		widget   = bar_widget,
	}

	local proxy = {
		mt = {
			bar    = bar,
			widget = bar_widget_container,
			holder = {},
		},
	}

	return setmetatable(proxy, self)
end

function gmb.mt:__call(...)
	return self.new(self, ...)
end

return gmb
