-- Faster lookup
local require = require
--local next = next
local math = math
--local io = io
--local os = os
--local pairs = pairs
--local ipairs = ipairs
local tonumber = tonumber
--local tostring = tostring
--local debug = debug
--local table = table
--local type = type
--local setmetatable = setmetatable
--local getmetatable = getmetatable

local gears = require("gears")

local uc = {}

--[===[
--- Convert hex strings to RGB colors.
---
--- This function allows for multiple color formats:
--- 
--- - RGB
--- - RRGGBB
--- - RGBA
--- - RRGGBBAA
---@deprecated Use gears.color.parse_color instead
---@param hex_str str The color in hexadecimal format; can be prefixed with a `#`
---@return num r, num g, num b, num a RGBA values from 0 to 1
function uc.hex_to_rgb(hex_str)
	---@type num, num, num, num
	local r, g, b, a

	--- Remove the `#`-character at the beginning
	hex_str = hex_str:gsub("^#", "")

	if #hex_str == 3 then --- RGB
		a = 1
		r, g, b =    tonumber(hex_str:sub(1, 1), 16) / 255, tonumber(hex_str:sub(2, 2), 16) / 255, tonumber(hex_str:sub(3, 3), 16) / 255
	elseif #hex_str == 4 then --- RGBA
		r, g, b, a = tonumber(hex_str:sub(1, 1), 16) / 255, tonumber(hex_str:sub(2, 2), 16) / 255, tonumber(hex_str:sub(3, 3), 16) / 255, tonumber(hex_str:sub(4, 4), 16) / 255
	elseif #hex_str == 6 then --- RRGGBB
		a = 1
		r, g, b =    tonumber(hex_str:sub(1, 2), 16) / 255, tonumber(hex_str:sub(3, 4), 16) / 255, tonumber(hex_str:sub(5, 6), 16) / 255
	elseif #hex_str == 8 then --- RRGGBBAA
		r, g, b, a = tonumber(hex_str:sub(1, 2), 16) / 255, tonumber(hex_str:sub(3, 4), 16) / 255, tonumber(hex_str:sub(5, 6), 16) / 255, tonumber(hex_str:sub(7, 8), 16) / 255
	end

	return r, g, b, a
end
--]===]

--- Convert RGB(A) colors to HSLA format.
---@param r num Red color value, from 0 to 1
---@param g num Green color value, from 0 to 1
---@param b num Blue color value, from 0 to 1
---@param a num Alpha (opacity) color value, from 0 to 1
---@return num h, num s, num l, num a HSLA values, each from 0 to 1
function uc.rgb_to_hsl(r, g, b, a)
	r, g, b, a = r, g, b, (a or 1)

	---@type num, num, num
	local h, s, l

	local max, min = math.max(r, g, b), math.min(r, g, b)
	b = max + min
	h = b / 2

	if max == min then
		return 0, 0, h, a
	end

	s, l = h, h

	local d = max - min

	if l > 0.5 then
		s = d / (2 - b)
	else
		s = d / b
	end

	if max == r then
		h = (g - b) / d + (g < b and 6 or 0)
	elseif
		max == g then h = (b - r) / d + 2
	elseif
		max == b then h = (r - g) / d + 4
	end

	h = h * (1/6)

	return h, s, l, a
end

function uc.hsl_to_rgb(h, s, l, a)
	a = a or 1

	if s == 0 then
		return l, l, l
	end

	local function to(p, q, t)
		if t < 0 then
			t = t + 1
		end

		if t > 1 then
			t = t - 1
		end

		if t < (1/6) then
			return p + (q - p) * 6 * t
		end

		if t < 0.5 then
			return q
		end

		if t < (2/3) then
			return p + (q - p) * ((2/3) - t) * 6
		end

		return p
	end

	local q
	if l < 0.5 then
		q = l * (1 + s)
	else
		q = l + s - l * s
	end
    local p = 2 * l - q
	return
		to(p, q, h + (1/3)),
		to(p, q, h),
		to(p, q, h - (1/3)),
		a
end

--- Get the hue of a color.
---@param color str|color A valid color that'll be parsed
---@return num h The hue of the color
function uc.get_hue(color)
	local h, s, l, a = uc.rgb_to_hsl(gears.color.parse_color(color))
	return h
end

--- Get the saturation of a color.
---@param color str|color A valid color that'll be parsed
---@return num s The saturation of the color
function uc.get_saturation(color)
	local h, s, l, a = uc.rgb_to_hsl(gears.color.parse_color(color))
	return s
end

--- Get the lightness value of a color.
---@param color str|color A valid color that'll be parsed
---@return num l The lightness of the color
function uc.get_lightness(color)
	local h, s, l, a = uc.rgb_to_hsl(gears.color.parse_color(color))
	return l
end

--- Get the alpha (opacity) value of a color.
---@param color str|color A valid color that'll be parsed
---@return num a The alpha of the color
function uc.get_alpha(color)
	local r, g, b, a = gears.color.parse_color(color)
	return a
end

--- Limit a number to a specific range
---@param value num
---@param min? num
---@param max? num
---@return num
function uc.limit_range(value, min, max)
	min = min or 0
	max = max or 1

	if value > max then
		return max
	end

	if value < min then
		return min
	end

	return value
end

--- Alter parts of a color
---
--- For example, this can be used to make a color semi-transparent:
---
--- ```
--- util.color.alter("#FF0000", { a = 0.5 }) -- half-transparent red
--- ```
---
---@param color str|color A valid color that'll be parsed
---@param changes {r?: num, g?: num, b?:num, a?: num} The new target color values, 0-1
---@param mode? "set"|"add"|"sub"
---@return str processed_color A #RRRRGGGGBBBBAAAA string
function uc.alter(color, changes, mode)
	local r, g, b, a = gears.color.parse_color(color)
	if mode == "add" then
		r = math.floor(uc.limit_range(r + (changes.r or 0)) * 65535)
		g = math.floor(uc.limit_range(g + (changes.g or 0)) * 65535)
		b = math.floor(uc.limit_range(b + (changes.b or 0)) * 65535)
		a = math.floor(uc.limit_range(a + (changes.a or 0)) * 65535)
	elseif mode == "sub" then
		r = math.floor(uc.limit_range(r - (changes.r or 0)) * 65535)
		g = math.floor(uc.limit_range(g - (changes.g or 0)) * 65535)
		b = math.floor(uc.limit_range(b - (changes.b or 0)) * 65535)
		a = math.floor(uc.limit_range(a - (changes.a or 0)) * 65535)
	else--if mode == "set" then
		r = math.floor(uc.limit_range(changes.r or r) * 65535)
		g = math.floor(uc.limit_range(changes.g or g) * 65535)
		b = math.floor(uc.limit_range(changes.b or b) * 65535)
		a = math.floor(uc.limit_range(changes.a or a) * 65535)
	end
	return ("#%.4x%.4x%.4x%.4x"):format(r, g, b, a)
end

--- Alter parts of a color, hsl version
---
--- For example, this can be used to make a color semi-transparent:
---
--- ```
--- util.color.alter("#FF0000", { a = 0.5 }) -- half-transparent red
--- ```
---
---@param color str|color A valid color that'll be parsed
---@param changes {h?: num, s?: num, l?:num, a?: num} The new target color values, 0-1
---@param mode? "set"|"add"|"sub"
---@return str processed_color A #RRRRGGGGBBBBAAAA string
function uc.alter_hsl(color, changes, mode)
	local r, g, b, a = gears.color.parse_color(color)
	local h, s, l    = uc.rgb_to_hsl(r, g, b, a)
	if mode == "add" then
		h = uc.limit_range(h + (changes.h or 0))
		s = uc.limit_range(s + (changes.s or 0))
		l = uc.limit_range(l + (changes.l or 0))
		a = math.floor(uc.limit_range(a + (changes.a or 0)) * 65535)
	elseif mode == "sub" then
		h = uc.limit_range(h - (changes.h or 0))
		s = uc.limit_range(s - (changes.s or 0))
		l = uc.limit_range(l - (changes.l or 0))
		a = math.floor(uc.limit_range(a - (changes.a or 0)) * 65535)
	else--if mode == "set" then
		h = uc.limit_range(changes.h or h)
		s = uc.limit_range(changes.s or s)
		l = uc.limit_range(changes.l or l)
		a = math.floor(uc.limit_range(changes.a or a) * 65535)
	end
	local r2, g2, b2 = uc.hsl_to_rgb(h, s, l, a)
	r = math.floor(r2 * 65535)
	g = math.floor(g2 * 65535)
	b = math.floor(b2 * 65535)
	return ("#%.4x%.4x%.4x%.4x"):format(r, g, b, a)
end

return uc
