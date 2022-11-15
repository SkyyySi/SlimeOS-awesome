---@meta

-- -@class wibox.widget._args : table
---@alias wibox.widget._args table

---@class wibox.widget
-- -@field background wibox.container.background
---@field base wibox.widget.base
---@field calendar wibox.widget.calendar
---@field checkbox wibox.widget.checkbox
---@field graph wibox.widget.graph
---@field imagebox wibox.widget.imagebox
---@field init wibox.widget.init
---@field piechart wibox.widget.piechart
---@field progressbar wibox.widget.progressbar
---@field separator wibox.widget.separator
---@field slider wibox.widget.slider
---@field systray wibox.widget.systray
---@field textbox wibox.widget.textbox
---@field textclock wibox.widget.textclock
local cls = {}

---@type wibox.container.background
---@deprecated Use `wibox.container.background` instead.
cls.background = nil


---@param wdg wibox.widget widget
---@param cr cairo_context
---@param width number
---@param height number
---@param context { dpi: 96 }
function cls:draw_to_cairo_context(wdg, cr, width, height, context) end


---@param wdg wibox.widget widget
---@param path string
---@param width number
---@param height number
---@param context { dpi: 96 }
function cls:draw_to_svg_file(wdg, path, width, height, context) end


---@param wdg wibox.widget widget
---@param width number
---@param height number
---@param format cairo.Format
---@param context { dpi: 96 }
function cls:draw_to_image_surface(wdg, width, height, format, context) end

-- -@class wibox.widget._instance : table
---@alias wibox.widget._instance table
