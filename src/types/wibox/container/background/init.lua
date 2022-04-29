#/usr/bin/env lua
---@class wibox.container.background
---@field widget wibox.widget The widget displayed in the background widget.
---@field bg color The background color/pattern/gradient to use.
---@field fg color The foreground (text) color/pattern/gradient to use.
---@field shape gears.shape or function The background shape.
---@field border_width number Add a border of a specific width.
---@field border_color color Set the color for the border.
---@field border_strategy string How the border width affects the contained widget.
---@field bgimage string or surface or function The background image to use.
---@field children table Get or set the children elements. Inherited from wibox.widget.base
---@field all_children table Get all direct and indirect children widgets. Inherited from wibox.widget.base
---@field forced_height number or nil Force a widget height. Inherited from wibox.widget.base
---@field forced_width number or nil Force a widget width. Inherited from wibox.widget.base
---@field opacity number The widget opacity (transparency). Inherited from wibox.widget.base
---@field visible boolean The widget visibility. Inherited from wibox.widget.base
---@field buttons table The widget buttons.
local cls = {}

local meta = {}

-- Returns a new background container.
---
--- A background container applies a background and foreground color to another widget.
---@param widget wibox.widget The widget to display. (optional)
---@param bg color The background to use for that widget. (optional)
---@param shape gears.shape or function A gears.shape compatible shape function (optional)
function meta:__call(widget, bg, shape) end

setmetatable(cls, meta)
