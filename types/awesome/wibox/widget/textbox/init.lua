---@class wibox.widget.textbox : wibox.widget.base
---@field markup string Set the HTML text of the textbox.
---@field text string Set a textbox plain text.
---@field ellipsize string Set the text ellipsize mode.
---@field wrap string Set a textbox wrap mode.
---@field valign string The vertical text alignment.
---@field align string The horizontal text alignment.
---@field font string Set a textbox font.
---@field children table Get or set the children elements.
---@field all_children table Get all direct and indirect children widgets.
---@field forced_height number|nil Force a widget height.
---@field forced_width number|nil Force a widget width.
---@field opacity number The widget opacity (transparency).
---@field visible boolean The widget visibility.
---@field buttons table The widget buttons.
local cls = {}


-- Get the preferred size of a textbox.
---
--- This returns the size that the textbox would use if infinite space were available.
---@param s integer|screen The screen on which the textbox will be displayed.
---@return number width
---@return number height
function cls:get_preferred_size(s) end


-- Get the preferred height of a textbox at a given width.
---
--- This returns the height that the textbox would use when it is limited to the given width.
---@param width number The available width.
---@param s integer|screen The screen on which the textbox will be displayed.
---@return number height
function cls:get_height_for_width(width, s) end


-- Get the preferred size of a textbox.
---
--- This returns the size that the textbox would use if infinite space were available.
---@param dpi number The DPI value to render at.
---@return number width
---@return number height
function cls:get_preferred_size_at_dpi(dpi) end


-- Get the preferred height of a textbox at a given width.
---
--- This returns the height that the textbox would use when it is limited to the given width.
---@param width number The available width.
---@param dpi number The DPI value to render at.
---@return number height
function cls:get_height_for_width_at_dpi(width, dpi) end


-- Set the text of the textbox (with [Pango markup](https://docs.gtk.org/Pango/pango_markup.html)).
---@param text string The text to set. This can contain pango markup (e.g. `<b>bold</b>`). You can use `gears.string.escape` to escape parts of it.
---@return true|(false,string)
function cls:set_markup_silently(text) end


-- Add a new [awful.button](https://awesomewm.org/apidoc/input_handling/awful.button.html) to this widget.
---@param button awful.button The button to add.
function cls:add_button(button) end

--- Emit a signal and ensure all parent widgets in the hierarchies also forward the signal.
---
--- This is useful to track signals when there is a dynamic set of containers and layouts wrapping the widget.
---
--- Note that this function has some flaws:
---
--- - The signal is only forwarded once the widget tree has been built. This happens after all currently scheduled functions have been executed. Therefore, it will not start to work right away.
--- - In case the widget is present multiple times in a single widget tree, this function will also forward the signal multiple times (once per upward tree path).
--- - If the widget is removed from the widget tree, the signal is still forwarded for some time, similar to the first case.
---@param signal_name string
---@vararg any
function cls:emit_signal_recursive(signal_name, ...) end


-- Get the index of a widget.
---@param widget wibox.widget The widget to look for.
---@param recursive boolean|nil Recursively check accross the sub-widgets hierarchy.
---@vararg wibox.widget|nil Additional widgets to add at the end of the sub-widgets hierarchy "path".
---@return number The widget index.
---@return wibox.widget The parent widget.
---@return table The hierarchy path between "self" and "widget".
function cls:index(widget, recursive, ...) end


-- Connect to a signal.
---
--- **Usage example output:**
---
--- ```
--- In slot [obj]   nil nil nil
--- In slot [obj]   foo bar 42
--- ```
---
--- Usage:
---
--- ```
--- local o = gears.object{}
--- -- Function can be attached to signals
--- local function slot(obj, a, b, c)
---     print("In slot", obj, a, b, c)
--- end
--- o:connect_signal("my_signal", slot)
--- -- Emitting can be done without arguments. In that case, the object will be
--- -- implicitly added as an argument.
--- o:emit_signal "my_signal"
--- -- It is also possible to add as many random arguments are required.
--- o:emit_signal("my_signal", "foo", "bar", 42)
--- -- Finally, to allow the object to be garbage collected (the memory freed), it
--- -- is necessary to disconnect the signal or use weak_connect_signal
--- o:disconnect_signal("my_signal", slot)
--- -- This time, the slot wont be called as it is no longer connected.
--- o:emit_signal "my_signal"
--- ```
---@param name string The name of the signal.
---@param func fun(...): nil The callback to call when the signal is emitted.
function cls:connect_signal(name, func) end

-- Connect to a signal weakly.
---
--- This allows the callback function to be garbage collected and automatically disconnects the signal when that happens. **Warning:** Only use this function if you really, really, really know what you are doing.
---@param name string The name of the signal.
---@param func fun(...): nil The callback to call when the signal is emitted.
function cls:weak_connect_signal(name, func) end


--  Disonnect from a signal.
---@param name string The name of the signal.
---@param func fun(...): nil The callback to call when the signal is emitted.
function cls:disconnect_signal(name, func) end


-- Emit a signal.
---@param name string The name of the signal.
---@vararg any Extra arguments for the callback functions. Each connected function receives the object as first argument and then any extra arguments that are given to emit_signal()
function cls:emit_signal(name, func) end

