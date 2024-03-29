---@meta

-- -@class wibox._args : table
---@alias wibox._args table

---@class wibox
---@operator call(wibox._args): wibox._instance
---@field border_width integer Border width.
---@field border_color string Border color.
---@field ontop boolean On top of other windows.
---@field cursor string The mouse cursor.
---@field visible boolean Visibility.
---@field opacity number The opacity of the wibox, between 0 and 1.
---@field type string The window type (desktop, normal, dock, ...).
---@field x integer The x coordinates.
---@field y integer The y coordinates.
---@field width width The width of the wibox.
---@field height height The height of the wibox.
---@field screen screen The wibox screen.
---@field drawable wibox.drawable The wibox's drawable.
---@field widget wibox.widget The widget that the wibox displays.
---@field window string The X window id.
---@field shape_bounding any The wibox's bounding shape as a (native) cairo surface.
---@field shape_clip any The wibox's clip shape as a (native) cairo surface.
---@field shape_input any The wibox's input shape as a (native) cairo surface.
---@field shape gears.shape The wibar's shape.
---@field input_passthrough boolean Forward the inputs to the client below the wibox.
---@field buttons buttons_table Get or set mouse buttons bindings to a wibox.
---@field bg c The background of the wibox.
---@field bgimage gears.suface or string or function The background image of the drawable.
---@field fg color The foreground (text) of the wibox.
---@field container wibox.container
---@field layout wibox.layout
local cls = {}

-- -@class wibox._instance : table
---@alias wibox._instance table
