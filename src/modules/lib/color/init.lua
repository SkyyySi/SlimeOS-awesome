#!/usr/bin/env lua
local gears   = require("gears")
local awful   = require("awful")
local wibox   = require("wibox")
local ruled   = require("ruled")
local naughty = require("naughty")
local lgi     = require("lgi")
local cairo   = lgi.cairo

local color = {}

function color.normalized_rgb_to_pattern(r, g, b, a)
	if not a then a = 1 end

	return cairo.Pattern.create_rgb(r, g, b, a)
end

function color.rgb_to_pattern(r, g, b, a)
	r = r / 255
	g = g / 255
	b = b / 255
	if a then a = a / 255 end

	return color.normalized_rgb_to_pattern(r, g, b, a)
end

color.rgb = color.rgb_to_pattern -- shorthand

function color.normalized_hsl_to_rgb(h, s, l, a)
    local r, g, b
    if not a then a = 1 end

    if s == 0 then
        r, g, b = l, l, l -- achromatic
    else
        local function hue2rgb(p, q, t)
            if t < 0 then t = t + 1 end
            if t > 1 then t = t - 1 end
            if t < 1 / 6 then return p + (q - p) * 6 * t end
            if t < 1 / 2 then return q end
            if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
            return p
        end

        local q = l < 0.5 and l * (1 + s) or l + s - l * s
        local p = 2 * l - q
        r = hue2rgb(p, q, h + 1 / 3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1 / 3)
    end

    return r, g, b, a
end

function color.hsl_to_rgb(h, s, l, a)
    h = h / 360
    s = s / 100
    l = l / 100
	if a then a = a / 100 end

	return color.normalized_hsl_to_rgb(h, s, l, a)
end

function color.normalized_hsl_to_pattern(h, s, l, a)
	return cairo.Pattern.create_rgb(color.normalized_hsl_to_rgb(h, s, l, a))
end

function color.hsl_to_pattern(h, s, l, a)
	return cairo.Pattern.create_rgb(color.hsl_to_rgb(h, s, l, a))
end

color.hsl = color.hsl_to_pattern -- shorthand

return color
