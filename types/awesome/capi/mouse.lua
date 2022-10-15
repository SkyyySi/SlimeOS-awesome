---@meat

---@class mouse.widget_geometry

--- # Module: mouse
--- Manipulate and inspect the mouse cursor.
---
--- The mouse buttons are represented as index. The common ones are:
--- - Button 1 -> Left mouse button
--- - Button 2 -> Middle mouse button / mouse wheel click
--- - Button 3 -> Right mouse button
--- - Button 4 -> Mouse wheel up
--- - Button 5 -> Mouse wheel down
---
--- It is possible to be notified of mouse events by connecting to various `client`, `widget`s and `wibox` signals:
---
--- - `mouse::enter`
--- - `mouse::leave`
--- - `mouse::press`
--- - `mouse::release`
--- - `mouse::move`
---
--- It is also possible to add generic mouse button callbacks for `client`s, `wibox`es and the `root` window. Those are set in the default `rc.lua` as such:
---
--- **root:**
---
--- ```
--- root.buttons(awful.util.table.join(
--- 	awful.button({}, 3, function() mymainmenu:toggle() end),
--- 	awful.button({}, 4, awful.tag.viewnext),
--- 	awful.button({}, 5, awful.tag.viewprev)
--- ))
--- ```
---
--- **client:**
---
--- ```
--- clientbuttons = awful.util.table.join(
--- 	awful.button({}, 1, function(c) client.focus = c; c:raise() end),
--- 	awful.button({ modkey }, 1, awful.mouse.client.move),
--- 	awful.button({ modkey }, 3, awful.mouse.client.resize)
--- )
--- ```
---
---@class mouse
---@field screen? screen The screen under the cursor
---@field current_client? client Get the client currently under the mouse cursor.
---@field current_wibox? wibox Get the wibox currently under the mouse cursor.
---@field current_widget? wibox.widget Get the topmost widget currently under the mouse cursor.
---@field current_widgets? wibox.widget[] Get the widgets currently under the mouse cursor.
---@field current_widget_geometry? mouse.widget_geometry Get the current widget geometry.
---@field current_widget_geometries? mouse.widget_geometry[] Get the current widget geometries.
---@field is_left_mouse_button_pressed bool True if the left mouse button is pressed.
---@field is_middle_mouse_button_pressed bool True if the middle mouse button is pressed.
---@field is_right_mouse_button_pressed bool True if the right mouse button is pressed.
