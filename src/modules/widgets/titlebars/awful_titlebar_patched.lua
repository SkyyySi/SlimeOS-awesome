---------------------------------------------------------------------------
--- Create widget area on the edge of a client.
--
-- Create a titlebar
-- =================
--
-- This example reproduces what the default `rc.lua` does. It shows how to
-- handle the titlebars on a lower level.
--
-- 
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_awful_titlebar_default.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- 
--     -- Create a titlebar for the client.
--     -- By default, `ruled.client` will create one, but all it does is to call this
--     -- function.
--     local top_titlebar = awful.titlebar(c, {
--         size      = 20,
--         bg_normal = &#34#ff0000&#34,
--     })
--      
--     -- buttons for the titlebar
--     local buttons = gears.table.join(
--         awful.button({ }, 1, function()
--             client.focus = c
--             c:raise()
--             awful.mouse.client.move(c)
--         end),
--         awful.button({ }, 3, function()
--             client.focus = c
--             c:raise()
--             awful.mouse.client.resize(c)
--         end)
--     )
--      
--     top_titlebar.widget = {
--         { -- Left
--             awful.titlebar.widget.iconwidget(c),
--             buttons = buttons,
--             layout  = wibox.layout.fixed.horizontal
--         },
--         { -- Middle
--             { -- Title
--                 halign = &#34center&#34,
--                 widget = awful.titlebar.widget.titlewidget(c)
--             },
--             buttons = buttons,
--             layout  = wibox.layout.flex.horizontal
--         },
--         { -- Right
--             awful.titlebar.widget.floatingbutton (c),
--             awful.titlebar.widget.maximizedbutton(c),
--             awful.titlebar.widget.stickybutton   (c),
--             awful.titlebar.widget.ontopbutton    (c),
--             awful.titlebar.widget.closebutton    (c),
--             layout = wibox.layout.fixed.horizontal()
--         },
--         layout = wibox.layout.align.horizontal
--     }
--
-- @author Uli Schlachter
-- @copyright 2012 Uli Schlachter
-- @popupmod awful.titlebar
---------------------------------------------------------------------------

local error = error
local pairs = pairs
local table = table
local type = type
local gmath = require("gears.math")
local gcolor = require("gears.color")
local gshape = require("gears.shape")
local abutton = require("awful.button")
local aclient = require("awful.client")
local atooltip = require("awful.tooltip")
local clienticon = require("awful.widget.clienticon")
local beautiful = require("beautiful")
local drawable = require("wibox.drawable")
local wibox = require("wibox")
local imagebox = require("wibox.widget.imagebox")
local textbox = require("wibox.widget.textbox")
local base = require("wibox.widget.base")
local capi = {
	client = client
}

local util = require("modules.lib.util")
local buttonify = require("modules.lib.buttonify")

local titlebar = {
	widget = {},
	enable_tooltip = true,
	fallback_name = '<unknown>'
}

local default_tooltip_messages = {
	close = "Close",
	minimize = "Minimize",
	maximized_active = "Unmaximize",
	maximized_inactive = "Maximize",
	floating_active = "Tiling",
	floating_inactive = "Floating",
	ontop_active = "NotOnTop",
	ontop_inactive = "OnTop",
	sticky_active = "NotSticky",
	sticky_inactive = "Sticky"
}

--- Show tooltips when hover on titlebar buttons.
--
-- @tfield[opt=true] boolean awful.titlebar.enable_tooltip
-- @param boolean

--- Title to display if client name is not set.
--
-- @field[opt='\<unknown\>'] awful.titlebar.fallback_name
-- @tparam[opt='\<unknown\>'] string fallback_name

--- The titlebar foreground (text) color.
--
-- @beautiful beautiful.titlebar_fg_normal
-- @param color
-- @see gears.color

--- The titlebar background color.
--
-- @beautiful beautiful.titlebar_bg_normal
-- @param color
-- @see gears.color

--- The titlebar background image image.
--
-- @beautiful beautiful.titlebar_bgimage_normal
-- @tparam gears.surface|string path
-- @see gears.surface

--- The titlebar foreground (text) color.
--
-- @beautiful beautiful.titlebar_fg
-- @param color
-- @see gears.color

--- The titlebar background color.
--
-- @beautiful beautiful.titlebar_bg
-- @param color
-- @see gears.color

--- The titlebar background image image.
--
-- @beautiful beautiful.titlebar_bgimage
-- @tparam gears.surface|string path
-- @see gears.surface

--- The focused titlebar foreground (text) color.
--
-- @beautiful beautiful.titlebar_fg_focus
-- @param color
-- @see gears.color

--- The focused titlebar background color.
--
-- @beautiful beautiful.titlebar_bg_focus
-- @param color
-- @see gears.color

--- The focused titlebar background image image.
--
-- @beautiful beautiful.titlebar_bgimage_focus
-- @tparam gears.surface|string path
-- @see gears.surface

--- The urgent titlebar foreground (text) color.
--
-- @beautiful beautiful.titlebar_fg_urgent
-- @param color
-- @see gears.color

--- The urgent titlebar background color.
--
-- @beautiful beautiful.titlebar_bg_urgent
-- @param color
-- @see gears.color

--- The urgent titlebar background image.
--
-- @beautiful beautiful.titlebar_bgimage_urgent
-- @tparam gears.surface|string path
-- @see gears.surface

--- The normal non-floating button image.
--
-- @beautiful beautiful.titlebar_floating_button_normal
-- @tparam gears.surface|string path
-- @see gears.surface

--- The normal non-maximized button image.
--
-- @beautiful beautiful.titlebar_maximized_button_normal
-- @tparam gears.surface|string path
-- @see gears.surface

--- The normal minimize button image.
--
-- @beautiful beautiful.titlebar_minimize_button_normal
-- @tparam gears.surface|string path
-- @see gears.surface

--- The hovered minimize button image.
--
-- @beautiful beautiful.titlebar_minimize_button_normal_hover
-- @tparam gears.surface|string path
-- @see gears.surface

--- The pressed minimize button image.
--
-- @beautiful beautiful.titlebar_minimize_button_normal_press
-- @tparam gears.surface|string path
-- @see gears.surface

--- The normal close button image.
--
-- @beautiful beautiful.titlebar_close_button_normal
-- @tparam gears.surface|string path
-- @see gears.surface

--- The hovered close button image.
--
-- @beautiful beautiful.titlebar_close_button_normal_hover
-- @tparam gears.surface|string path
-- @see gears.surface

--- The pressed close button image.
--
-- @beautiful beautiful.titlebar_close_button_normal_press
-- @tparam gears.surface|string path
-- @see gears.surface

--- The normal non-ontop button image.
--
-- @beautiful beautiful.titlebar_ontop_button_normal
-- @tparam gears.surface|string path
-- @see gears.surface

--- The normal non-sticky button image.
--
-- @beautiful beautiful.titlebar_sticky_button_normal
-- @tparam gears.surface|string path
-- @see gears.surface

--- The focused client non-floating button image.
--
-- @beautiful beautiful.titlebar_floating_button_focus
-- @tparam gears.surface|string path
-- @see gears.surface

--- The focused client non-maximized button image.
--
-- @beautiful beautiful.titlebar_maximized_button_focus
-- @tparam gears.surface|string path
-- @see gears.surface

--- The focused client minimize button image.
--
-- @beautiful beautiful.titlebar_minimize_button_focus
-- @tparam gears.surface|string path
-- @see gears.surface

--- The hovered+focused client minimize button image.
--
-- @beautiful beautiful.titlebar_minimize_button_focus_hover
-- @tparam gears.surface|string path
-- @see gears.surface

--- The pressed+focused minimize button image.
--
-- @beautiful beautiful.titlebar_minimize_button_focus_press
-- @tparam gears.surface|string path
-- @see gears.surface

--- The focused client close button image.
--
-- @beautiful beautiful.titlebar_close_button_focus
-- @tparam gears.surface|string path
-- @see gears.surface

--- The hovered+focused close button image.
--
-- @beautiful beautiful.titlebar_close_button_focus_hover
-- @tparam gears.surface|string path
-- @see gears.surface

--- The pressed+focused close button image.
--
-- @beautiful beautiful.titlebar_close_button_focus_press
-- @tparam gears.surface|string path
-- @see gears.surface

--- The focused client non-ontop button image.
--
-- @beautiful beautiful.titlebar_ontop_button_focus
-- @tparam gears.surface|string path
-- @see gears.surface

--- The focused client sticky button image.
--
-- @beautiful beautiful.titlebar_sticky_button_focus
-- @tparam gears.surface|string path
-- @see gears.surface

--- The normal floating button image.
--
-- @beautiful beautiful.titlebar_floating_button_normal_active
-- @tparam gears.surface|string path
-- @see gears.surface

--- The hovered floating client button image.
--
-- @beautiful beautiful.titlebar_floating_button_normal_active_hover
-- @tparam gears.surface|string path
-- @see gears.surface

--- The pressed floating client button image.
--
-- @beautiful beautiful.titlebar_floating_button_normal_active_press
-- @tparam gears.surface|string path
-- @see gears.surface

--- The maximized client button image.
--
-- @beautiful beautiful.titlebar_maximized_button_normal_active
-- @tparam gears.surface|string path
-- @see gears.surface

--- The hozered+maximized client button image.
--
-- @beautiful beautiful.titlebar_maximized_button_normal_active_hover
-- @tparam gears.surface|string path
-- @see gears.surface

--- The pressed+maximized button image.
--
-- @beautiful beautiful.titlebar_maximized_button_normal_active_press
-- @tparam gears.surface|string path
-- @see gears.surface

--- The ontop button image.
--
-- @beautiful beautiful.titlebar_ontop_button_normal_active
-- @tparam gears.surface|string path
-- @see gears.surface

--- The hovered+ontop client button image.
--
-- @beautiful beautiful.titlebar_ontop_button_normal_active_hover
-- @tparam gears.surface|string path
-- @see gears.surface

--- The pressed+ontop client button image.
--
-- @beautiful beautiful.titlebar_ontop_button_normal_active_press
-- @tparam gears.surface|string path
-- @see gears.surface

--- The sticky button image.
--
-- @beautiful beautiful.titlebar_sticky_button_normal_active
-- @tparam gears.surface|string path
-- @see gears.surface

--- The hovered+sticky button image.
--
-- @beautiful beautiful.titlebar_sticky_button_normal_active_hover
-- @tparam gears.surface|string path
-- @see gears.surface

--- The pressed+sticky client button image.
--
-- @beautiful beautiful.titlebar_sticky_button_normal_active_press
-- @tparam gears.surface|string path
-- @see gears.surface

--- The floating+focused client button image.
--
-- @beautiful beautiful.titlebar_floating_button_focus_active
-- @tparam gears.surface|string path
-- @see gears.surface

--- The hovered+floating+focused button image.
--
-- @beautiful beautiful.titlebar_floating_button_focus_active_hover
-- @tparam gears.surface|string path
-- @see gears.surface

--- The pressed+floating+focused button image.
--
-- @beautiful beautiful.titlebar_floating_button_focus_active_press
-- @tparam gears.surface|string path
-- @see gears.surface

--- The maximized+focused button image.
--
-- @beautiful beautiful.titlebar_maximized_button_focus_active
-- @tparam gears.surface|string path
-- @see gears.surface

--- The hovered+maximized+focused button image.
--
-- @beautiful beautiful.titlebar_maximized_button_focus_active_hover
-- @tparam gears.surface|string path
-- @see gears.surface

--- The pressed+maximized+focused button image.
--
-- @beautiful beautiful.titlebar_maximized_button_focus_active_press
-- @tparam gears.surface|string path
-- @see gears.surface

--- The ontop+focused button image.
--
-- @beautiful beautiful.titlebar_ontop_button_focus_active
-- @tparam gears.surface|string path
-- @see gears.surface

--- The hovered+ontop+focused button image.
--
-- @beautiful beautiful.titlebar_ontop_button_focus_active_hover
-- @tparam gears.surface|string path
-- @see gears.surface

--- The pressed+ontop+focused button image.
--
-- @beautiful beautiful.titlebar_ontop_button_focus_active_press
-- @tparam gears.surface|string path
-- @see gears.surface

--- The sticky+focused button image.
--
-- @beautiful beautiful.titlebar_sticky_button_focus_active
-- @tparam gears.surface|string path
-- @see gears.surface

--- The hovered+sticky+focused button image.
--
-- @beautiful beautiful.titlebar_sticky_button_focus_active_hover
-- @tparam gears.surface|string path
-- @see gears.surface

--- The pressed+sticky+focused button image.
--
-- @beautiful beautiful.titlebar_sticky_button_focus_active_press
-- @tparam gears.surface|string path
-- @see gears.surface

--- The inactive+floating button image.
--
-- @beautiful beautiful.titlebar_floating_button_normal_inactive
-- @tparam gears.surface|string path
-- @see gears.surface

--- The hovered+inactive+floating button image.
--
-- @beautiful beautiful.titlebar_floating_button_normal_inactive_hover
-- @tparam gears.surface|string path
-- @see gears.surface

--- The pressed+inactive+floating button image.
--
-- @beautiful beautiful.titlebar_floating_button_normal_inactive_press
-- @tparam gears.surface|string path
-- @see gears.surface

--- The inactive+maximized button image.
--
-- @beautiful beautiful.titlebar_maximized_button_normal_inactive
-- @tparam gears.surface|string path
-- @see gears.surface

--- The hovered+inactive+maximized button image.
--
-- @beautiful beautiful.titlebar_maximized_button_normal_inactive_hover
-- @tparam gears.surface|string path
-- @see gears.surface

--- The pressed+maximized+inactive button image.
--
-- @beautiful beautiful.titlebar_maximized_button_normal_inactive_press
-- @tparam gears.surface|string path
-- @see gears.surface

--- The inactive+ontop button image.
--
-- @beautiful beautiful.titlebar_ontop_button_normal_inactive
-- @tparam gears.surface|string path
-- @see gears.surface

--- The hovered+inactive+ontop button image.
--
-- @beautiful beautiful.titlebar_ontop_button_normal_inactive_hover
-- @tparam gears.surface|string path
-- @see gears.surface

--- The pressed+inactive+ontop button image.
--
-- @beautiful beautiful.titlebar_ontop_button_normal_inactive_press
-- @tparam gears.surface|string path
-- @see gears.surface

--- The inactive+sticky button image.
--
-- @beautiful beautiful.titlebar_sticky_button_normal_inactive
-- @tparam gears.surface|string path
-- @see gears.surface

--- The hovered+inactive+sticky button image.
--
-- @beautiful beautiful.titlebar_sticky_button_normal_inactive_hover
-- @tparam gears.surface|string path
-- @see gears.surface

--- The pressed+inactive+sticky button image.
--
-- @beautiful beautiful.titlebar_sticky_button_normal_inactive_press
-- @tparam gears.surface|string path
-- @see gears.surface

--- The inactive+focused+floating button image.
--
-- @beautiful beautiful.titlebar_floating_button_focus_inactive
-- @tparam gears.surface|string path
-- @see gears.surface

--- The hovered+inactive+focused+floating button image.
--
-- @beautiful beautiful.titlebar_floating_button_focus_inactive_hover
-- @tparam gears.surface|string path
-- @see gears.surface

--- The pressed+inactive+focused+floating button image.
--
-- @beautiful beautiful.titlebar_floating_button_focus_inactive_press
-- @tparam gears.surface|string path
-- @see gears.surface

--- The inactive+focused+maximized button image.
--
-- @beautiful beautiful.titlebar_maximized_button_focus_inactive
-- @tparam gears.surface|string path
-- @see gears.surface

--- The hovered+inactive+focused+maximized button image.
--
-- @beautiful beautiful.titlebar_maximized_button_focus_inactive_hover
-- @tparam gears.surface|string path
-- @see gears.surface

--- The pressed+inactive+focused+maximized button image.
--
-- @beautiful beautiful.titlebar_maximized_button_focus_inactive_press
-- @tparam gears.surface|string path
-- @see gears.surface

--- The inactive+focused+ontop button image.
--
-- @beautiful beautiful.titlebar_ontop_button_focus_inactive
-- @tparam gears.surface|string path
-- @see gears.surface

--- The hovered+inactive+focused+ontop button image.
--
-- @beautiful beautiful.titlebar_ontop_button_focus_inactive_hover
-- @tparam gears.surface|string path
-- @see gears.surface

--- The pressed+inactive+focused+ontop button image.
--
-- @beautiful beautiful.titlebar_ontop_button_focus_inactive_press
-- @tparam gears.surface|string path
-- @see gears.surface

--- The inactive+focused+sticky button image.
--
-- @beautiful beautiful.titlebar_sticky_button_focus_inactive
-- @tparam gears.surface|string path
-- @see gears.surface

--- The hovered+inactive+focused+sticky button image.
--
-- @beautiful beautiful.titlebar_sticky_button_focus_inactive_hover
-- @tparam gears.surface|string path
-- @see gears.surface

--- The pressed+inactive+focused+sticky button image.
--
-- @beautiful beautiful.titlebar_sticky_button_focus_inactive_press
-- @tparam gears.surface|string path
-- @see gears.surface

--- The message in the close button tooltip.
-- @beautiful beautiful.titlebar_tooltip_messages_close
-- @tparam string titlebar_tooltip_messages_close
-- @see awful.titlebar

--- The message in the minimize button tooltip.
-- @beautiful beautiful.titlebar_tooltip_messages_minimize
-- @tparam string titlebar_tooltip_messages_minimize
-- @see awful.titlebar

--- The message in the maximize button tooltip when the client is maximized.
-- @beautiful beautiful.titlebar_tooltip_messages_maximized_active
-- @tparam string titlebar_tooltip_messages_maximized_active
-- @see awful.titlebar

--- The message in the maximize button tooltip when the client is unmaximized.
-- @beautiful beautiful.titlebar_tooltip_messages_maximized_inactive
-- @tparam string titlebar_tooltip_messages_maximized_inactive
-- @see awful.titlebar

--- The message in the floating button tooltip when then client is floating.
-- @beautiful beautiful.titlebar_tooltip_messages_floating_active
-- @tparam string titlebar_tooltip_messages_floating_active
-- @see awful.titlebar

--- The message in the floating button tooltip when then client isn't floating.
-- @beautiful beautiful.titlebar_tooltip_messages_floating_inactive
-- @tparam string titlebar_tooltip_messages_floating_inactive
-- @see awful.titlebar

--- The message in the onTop button tooltip when the client is onTop.
-- @beautiful beautiful.titlebar_tooltip_messages_ontop_active
-- @tparam string titlebar_tooltip_messages_ontop_active
-- @see awful.titlebar

--- The message in the onTop button tooltip when client isn't onTop.
-- @beautiful beautiful.titlebar_tooltip_messages_ontop_inactive
-- @tparam string titlebar_tooltip_messages_ontop_inactive
-- @see awful.titlebar

--- The message in the sticky button tooltip when the client is sticky.
-- @beautiful beautiful.titlebar_tooltip_messages_sticky_active
-- @tparam string titlebar_tooltip_messages_sticky_active
-- @see awful.titlebar

--- The message in the sticky button tooltip when the client isn't sticky.
-- @beautiful beautiful.titlebar_tooltip_messages_sticky_inactive
-- @tparam string titlebar_tooltip_messages_sticky_inactive
-- @see awful.titlebar

--- The delay in second before the titlebar buttons tooltip is shown.
-- It is used as the `delay_show` parameter passed to the `awful.tooltip` constructor function.
-- @beautiful beautiful.titlebar_tooltip_delay_show
-- @tparam integer titlebar_tooltip_delay_show
-- @see awful.tooltip

--- The inner left and right margins for tooltip messages.
-- It is used as the `margins_leftright` parameter passed to the `awful.tooltip` constructor function.
-- @beautiful beautiful.titlebar_tooltip_margins_leftright
-- @tparam integer titlebar_tooltip_margins_leftright
-- @see awful.tooltip

--- The inner top and bottom margins for the tooltip messages.
-- It is used as the `margins_topbottom` parameter passed to the `awful.tooltip` constructor function.
-- @beautiful beautiful.titlebar_tooltip_margins_topbottom
-- @tparam integer titlebar_tooltip_margins_topbottom
-- @see awful.tooltip

--- The time in second before invoking the `timer_function` callback.
-- It is used as the `timeout` parameter passed to the `awful.tooltip` constructor function.
-- @beautiful beautiful.titlebar_tooltip_timeout
-- @tparam number titlebar_tooltip_timeout
-- @see awful.tooltip.timeout

--- The text horizontal alignment in tooltips.
-- It is used as the `align` parameter passed to the `awful.tooltip` constructor function.
--
-- Valid values are:
--
--  * `"right"`
--  * `"top_right"`
--  * `"left"`
--  * `"bottom_left"`
--  * `"top_left"`
--  * `"bottom"`
--  * `"top"`
-- @beautiful beautiful.titlebar_tooltip_align
-- @tparam string titlebar_tooltip_align
-- @see awful.tooltip

--- Set a declarative widget hierarchy description.
--
-- See [The declarative layout system](../documentation/03-declarative-layout.md.html)
-- @tparam table args An array containing the widgets disposition
-- @method setup
-- @noreturn


local all_titlebars = setmetatable({}, { __mode = 'k' })

-- Get a color for a titlebar, this tests many values from the array and the theme
local function get_color(name, c, args)
	local suffix = "_normal"

	if c.urgent then
		suffix = "_urgent"
	elseif c.active then
		suffix = "_focus"
	end
	local function get(array)
		return array["titlebar_"..name..suffix] or array["titlebar_"..name] or array[name..suffix] or array[name]
	end
	return get(args) or get(beautiful)
end

local function get_titlebar_function(c, position)
	if position == "left" then
		return c.titlebar_left
	elseif position == "right" then
		return c.titlebar_right
	elseif position == "top" then
		return c.titlebar_top
	elseif position == "bottom" then
		return c.titlebar_bottom
	else
		error("Invalid titlebar position '" .. position .. "'")
	end
end

--- Call `request::titlebars` to allow themes or rc.lua to create them even
-- when `titlebars_enabled` is not set in the rules.
-- @tparam client c The client.
-- @tparam[opt=false] boolean hide_all Hide all titlebars except `keep`
-- @tparam string keep Keep the titlebar at this position.
-- @tparam string context The reason why this was called.
-- @treturn boolean If the titlebars were loaded
local function load_titlebars(c, hide_all, keep, context)
	if c._request_titlebars_called then return false end

	c:emit_signal("request::titlebars", context, {})

	if hide_all then
		-- Don't bother checking if it has been created, `.hide` don't works
		-- anyway.
		for _, tb in ipairs {"top", "bottom", "left", "right"} do
			if tb ~= keep then
				titlebar.hide(c, tb)
			end
		end
	end

	c._request_titlebars_called = true

	return true
end

local function get_children_by_id(self, name)
	--TODO v5: Move the ID management to the hierarchy.
	if self._drawable._widget
	  and self._drawable._widget._private
	  and self._drawable._widget._private.by_id then
		  return self._drawable.widget._private.by_id[name]
	end

	return {}
end


--- Create a new titlebar for the given client.
--
-- Every client can hold up to four titlebars, one for each side (i.e. each
-- value of `args.position`).
--
-- If this constructor is called again with the same
-- values for the client (`c`) and the titlebar position (`args.position`),
-- the previous titlebar will be removed and replaced by the new one.
--
-- 
--
--<object class=&#34img-object&#34 data=&#34../images/AUTOGEN_awful_titlebar_constructor.svg&#34 alt=&#34Usage example&#34 type=&#34image/svg+xml&#34></object>
--
-- 
--     -- Create default titlebar.
--     awful.titlebar(c)
--  
--     -- Create titlebar on the client's bottom edge.
--     awful.titlebar(c, { position = &#34bottom&#34 })
--  
--     -- Create titlebar with inverted colors.
--     awful.titlebar(c, { bg_normal = beautiful.fg_normal, fg_normal = beautiful.bg_normal })
--
-- @tparam client c The client the titlebar will be attached to.
-- @tparam[opt={}] table args A table with extra arguments for the titlebar.
-- @tparam[opt=font.height*1.5] number args.size The size of the titlebar. Will
--   be interpreted as `height` for horizontal titlebars or as `width` for
--   vertical titlebars.
-- @tparam[opt="top"] string args.position Possible values are `"top"`,
-- `"left"`, `"right"` and `"bottom"`.
-- @tparam[opt] string args.bg_normal
-- @tparam[opt] string args.bg_focus
-- @tparam[opt] string args.bg_urgent
-- @tparam[opt] string args.bgimage_normal
-- @tparam[opt] string args.bgimage_focus
-- @tparam[opt] string args.fg_normal
-- @tparam[opt] string args.fg_focus
-- @tparam[opt] string args.fg_urgent
-- @tparam[opt] string args.font
-- @constructorfct awful.titlebar
-- @treturn wibox.drawable The newly created titlebar object.
-- @usebeautiful beautiful.titlebar_fg_normal
-- @usebeautiful beautiful.titlebar_bg_normal
-- @usebeautiful beautiful.titlebar_bgimage_normal
-- @usebeautiful beautiful.titlebar_fg
-- @usebeautiful beautiful.titlebar_bg
-- @usebeautiful beautiful.titlebar_bgimage
-- @usebeautiful beautiful.titlebar_fg_focus
-- @usebeautiful beautiful.titlebar_bg_focus
-- @usebeautiful beautiful.titlebar_bgimage_focus
-- @usebeautiful beautiful.titlebar_fg_urgent
-- @usebeautiful beautiful.titlebar_bg_urgent
-- @usebeautiful beautiful.titlebar_bgimage_urgent
local function new(c, args)
	args = args or {}
	local position = args.position or "top"
	local size = args.size or gmath.round(beautiful.get_font_height(args.font) * 1.5)
	local d = get_titlebar_function(c, position)(c, size)

	-- Make sure that there is never more than one titlebar for any given client
	local bars = all_titlebars[c]
	if not bars then
		bars = {}
		all_titlebars[c] = bars
	end

	local ret
	if not bars[position] then
		local context = {
			client = c,
			position = position
		}
		ret = drawable(d, context, "awful.titlebar")
		ret:_inform_visible(true)
		local function update_colors()
			local args_ = bars[position].args
			ret:set_bg(get_color("bg", c, args_))
			ret:set_fg(get_color("fg", c, args_))
			ret:set_bgimage(get_color("bgimage", c, args_))
		end

		bars[position] = {
			args = args,
			drawable = ret,
			font = args.font or beautiful.titlebar_font,
			update_colors = update_colors
		}

		-- Update the colors when focus changes
		c:connect_signal("property::active", update_colors)
		c:connect_signal("property::urgent", update_colors)

		-- Inform the drawable when it becomes invisible
		c:connect_signal("request::unmanage", function()
			ret:_inform_visible(false)
		end)
	else
		bars[position].args = args
		ret = bars[position].drawable
	end

	-- Make sure the titlebar has the right colors applied
	bars[position].update_colors()

	-- Handle declarative/recursive widget container
	ret.setup = base.widget.setup
	ret.get_children_by_id = get_children_by_id

	c._private = c._private or {}
	c._private.titlebars = bars

	return ret
end

--- Show the client's titlebar.
-- @tparam client c The client whose titlebar is modified
-- @tparam[opt="top"] string position The position of the titlebar. Must be one of `"left"`,
--   `"right"`, `"top"`, `"bottom"`.
-- @noreturn
-- @staticfct awful.titlebar.show
-- @request client titlebars show granted Called when `awful.titlebar.show` is
--  called.
function titlebar.show(c, position)
	position = position or "top"
	if load_titlebars(c, true, position, "show") then return end
	local bars = all_titlebars[c]
	local data = bars and bars[position]
	local args = data and data.args
	new(c, args)
end

--- Hide the client's titlebar.
-- @tparam client c The client whose titlebar is modified
-- @tparam[opt="top"] string position The position of the titlebar. Must be one of `"left"`,
--   `"right"`, `"top"`, `"bottom"`.
-- @noreturn
-- @staticfct awful.titlebar.hide
function titlebar.hide(c, position)
	position = position or "top"
	get_titlebar_function(c, position)(c, 0)
end

--- Toggle the client's titlebar, hiding it if it is visible, otherwise showing it.
-- @tparam client c The client whose titlebar is modified
-- @tparam[opt="top"] string position The position of the titlebar. Must be one of `"left"`,
--   `"right"`, `"top"`, `"bottom"`.
-- @noreturn
-- @staticfct awful.titlebar.toggle
-- @request client titlebars toggle granted Called when `awful.titlebar.toggle` is
--  called.
function titlebar.toggle(c, position)
	position = position or "top"
	if load_titlebars(c, true, position, "toggle") then return end
	local _, size = get_titlebar_function(c, position)(c)
	if size == 0 then
		titlebar.show(c, position)
	else
		titlebar.hide(c, position)
	end
end

local instances = {}

-- Do the equivalent of
--     c:connect_signal(signal, widget.update)
-- without keeping a strong reference to the widget.
local function update_on_signal(c, signal, widget)
	local sig_instances = instances[signal]
	if sig_instances == nil then
		sig_instances = setmetatable({}, { __mode = "k" })
		instances[signal] = sig_instances
		capi.client.connect_signal(signal, function(cl)
			local widgets = sig_instances[cl]
			if widgets then
				for _, w in pairs(widgets) do
					w.update()
				end
			end
		end)
	end
	local widgets = sig_instances[c]
	if widgets == nil then
		widgets = setmetatable({}, { __mode = "v" })
		sig_instances[c] = widgets
	end
	table.insert(widgets, widget)
end

--- Honor the font.
local function draw_title(self, ctx, cr, width, height)
	if ctx.position and ctx.client then
		local bars = all_titlebars[ctx.client]
		local data = bars and bars[ctx.position]

		if data and data.font then
			self:set_font(data.font)
		end
	end

	textbox.draw(self, ctx, cr, width, height)
end

--- Create a new title widget.
--
-- A title widget displays the name of a client.
-- Please note that this returns a textbox and all of textbox' API is available.
-- This way, you can e.g. modify the font that is used.
--
-- @tparam client c The client for which a titlewidget should be created.
-- @return The title widget.
-- @constructorfct awful.titlebar.widget.titlewidget
function titlebar.widget.titlewidget(c)
	local ret = textbox()

	rawset(ret, "draw", draw_title)

	local function update()
		ret:set_text(c.name or titlebar.fallback_name)
	end
	ret.update = update
	update_on_signal(c, "property::name", ret)
	update()

	return ret
end

--- Create a new icon widget.
--
-- An icon widget displays the icon of a client.
-- Please note that this returns an imagebox and all of the imagebox' API is
-- available. This way, you can e.g. disallow resizes.
--
-- @tparam client c The client for which an icon widget should be created.
-- @return The icon widget.
-- @constructorfct awful.titlebar.widget.iconwidget
function titlebar.widget.iconwidget(c)
	return clienticon(c)
end

--- Create a new button widget.
--
-- A button widget displays an image and reacts to
-- mouse clicks. Please note that the caller has to make sure that this widget
-- gets redrawn when needed by calling the returned widget's `:update()` method.
-- The selector function should return a value describing a state. If the value
-- is a boolean, either `"active"` or `"inactive"` are used. The actual image is
-- then found in the theme as `titlebar_[name]_button_[normal/focus]_[state]`.
-- If that value does not exist, the focused state is ignored for the next try.
--
-- @tparam client c The client for which a button is created.
-- @tparam string name Name of the button, used for accessing the theme and
--   in the tooltip.
-- @tparam function selector A function that selects the image that should be displayed.
-- @tparam function action Function that is called when the button is clicked.
-- @treturn wibox.widget The widget
-- @constructorfct awful.titlebar.widget.button
-- @usebeautiful beautiful.titlebar_tooltip_messages_close
-- @usebeautiful beautiful.titlebar_tooltip_messages_minimize
-- @usebeautiful beautiful.titlebar_tooltip_messages_maximized_active
-- @usebeautiful beautiful.titlebar_tooltip_messages_maximized_inactive
-- @usebeautiful beautiful.titlebar_tooltip_messages_floating_active
-- @usebeautiful beautiful.titlebar_tooltip_messages_floating_inactive
-- @usebeautiful beautiful.titlebar_tooltip_messages_ontop_active
-- @usebeautiful beautiful.titlebar_tooltip_messages_ontop_inactive
-- @usebeautiful beautiful.titlebar_tooltip_messages_sticky_active
-- @usebeautiful beautiful.titlebar_tooltip_messages_sticky_inactive
-- @usebeautiful beautiful.titlebar_tooltip_delay_show
-- @usebeautiful beautiful.titlebar_tooltip_margins_leftright
-- @usebeautiful beautiful.titlebar_tooltip_margins_topbottom
-- @usebeautiful beautiful.titlebar_tooltip_timeout
-- @usebeautiful beautiful.titlebar_tooltip_align
function titlebar.widget.button(c, name, selector, action, args)
	args.normal   = args.normal   or "#FF000060"
	args.hover    = args.hover    or "#FF0000B0"
	args.press    = args.press    or "#FF0000FF"
	args.release  = args.release  or args.hover or"#FF0000B0"
	args.callback = args.callback or function() end
	args.shape    = args.shape    or function(cr, w, h) gshape.circle(cr, w, h) end

	local button_icon = imagebox()
	if titlebar.enable_tooltip then
		button_icon._private.tooltip = atooltip({
			objects = {button_icon},
			delay_show = beautiful["titlebar_tooltip_delay_show"] or 1,
			margins_leftright = beautiful["titlebar_tooltip_margins_leftright"],
			margins_topbottom = beautiful["titlebar_tooltip_margins_topbottom"],
			timeout = beautiful["titlebar_tooltip_timeout"],
			align = beautiful["titlebar_tooltip_align"]
		})
	end

	local function update()
		local img = selector(c)
		if type(img) ~= "nil" then
			-- Convert booleans automatically
			if type(img) == "boolean" then
				if img then
					img = "active"
				else
					img = "inactive"
				end
			end
			local prefix = "normal"
			if c.active then
				prefix = "focus"
			end
			if img ~= "" then
				prefix = prefix .. "_"
			end
			local state = button_icon.state
			if state ~= "" then
				state = "_" .. state
			end
			-- try select user defined tooltip texts according to state
			local tooltip_text = beautiful["titlebar_tooltip_messages_" .. name .. "_" .. img]
				or beautiful["titlebar_tooltip_messages_" .. name]
				or default_tooltip_messages[name .. "_" .. img]
				or default_tooltip_messages[name]
				or name
			-- First try with a prefix based on the client's focus state,
			-- then try again without that prefix if nothing was found,
			-- and finally, try a fallback for compatibility with Awesome 3.5 themes
			local theme = beautiful["titlebar_" .. name .. "_button_" .. prefix .. img .. state]
					   or beautiful["titlebar_" .. name .. "_button_" .. prefix .. img]
					   or beautiful["titlebar_" .. name .. "_button_" .. img]
					   or beautiful["titlebar_" .. name .. "_button_" .. prefix .. "_inactive"]
			if theme then
				img = theme
			end
			-- Set tooltip text for button
			if titlebar.enable_tooltip then
				button_icon._private.tooltip:set_text(tooltip_text)
			end
		end
		-- Set button image by focus and activity state
		button_icon:set_image(img)
	end
	button_icon.state = ""

	local full_widget = wibox.widget {
		{
			{
				{
					button_icon,
					margins = util.scale(2),
					widget  = wibox.container.margin,
				},
				id     = "background_role",
				bg     = args.normal or "#FF0000B0",
				shape  = args.shape,
				shape_border_width = 1,
				shape_border_color = gcolor.transparent,
				widget = wibox.container.background,
			},
			margins = util.scale(4),
			widget  = wibox.container.margin,
		},
		id     = "button_role",
		widget = wibox.container.background,
	}

	if action then
		full_widget.buttons = {
			abutton({ }, 1, nil, function()
				button_icon.state = ""
				update()
				action(c, selector(c))
			end)
		}
	else
		full_widget.buttons = {
			abutton({ }, 1, nil, function()
				button_icon.state = ""
				update()
			end)
		}
	end

	util.for_children(full_widget, "background_role", function(child2)
		--args.normal,
		--args.hover,
		--args.press,
		--args.release,
		child2.bg = args.normal
	end)

	button_icon.opacity = 0

	util.for_children(full_widget, "button_role", function(child)
		buttonify {
			widget                  = child,
			mouse_effects           = true,
			button_color_normal     = gcolor.transparent,
			button_color_hover      = gcolor.transparent,
			button_color_press      = gcolor.transparent,
			button_color_release    = gcolor.transparent,
			button_callback_normal   = function()
				util.for_children(full_widget, "background_role", function(child2)
					--args.normal,
					--args.hover,
					--args.press,
					--args.release,
					child2.bg = args.normal
				end)

				button_icon.state = ""
				button_icon.opacity = 0
				update()
			end,
			button_callback_hover   = function()
				util.for_children(full_widget, "background_role", function(child2)
					child2.bg = args.hover
				end)

				button_icon.state = "hover"
				button_icon.opacity = 1
				update()
			end,
			button_callback_press   = function(w, b)
				util.for_children(full_widget, "background_role", function(child2)
					child2.bg = args.press
				end)
			end,
			button_callback_release = function(w, b)
				util.for_children(full_widget, "background_role", function(child2)
					child2.bg = args.release or args.hover
				end)

				if b == 1 then
					button_icon.state = "press"
					update()
				end
			end,
		}
	end)

	--[[
	button_icon:connect_signal("mouse::enter", function()
		button_icon.state = "hover"
		button_icon.opacity = 1
		update()
	end)
	button_icon:connect_signal("mouse::leave", function()
		button_icon.state = ""
		button_icon.opacity = 0
		update()
	end)
	button_icon:connect_signal("button::release", function(_, _, _, b)
		if b == 1 then
			button_icon.state = "press"
			update()
		end
	end)
	--]]
	button_icon.update = update
	full_widget.update = update
	update()

	-- We do magic based on whether a client is focused above, so we need to
	-- connect to the corresponding signal here.
	update_on_signal(c, "focus", button_icon)
	update_on_signal(c, "unfocus", button_icon)

	return full_widget
end

--- Create a new float button for a client.
--
-- @constructorfct awful.titlebar.widget.floatingbutton
-- @tparam client c The client for which the button is wanted.
-- @usebeautiful beautiful.titlebar_floating_button_normal
-- @usebeautiful beautiful.titlebar_floating_button_focus
-- @usebeautiful beautiful.titlebar_floating_button_normal_active
-- @usebeautiful beautiful.titlebar_floating_button_normal_active_hover
-- @usebeautiful beautiful.titlebar_floating_button_normal_active_press
-- @usebeautiful beautiful.titlebar_floating_button_focus_active
-- @usebeautiful beautiful.titlebar_floating_button_focus_active_hover
-- @usebeautiful beautiful.titlebar_floating_button_focus_active_press
-- @usebeautiful beautiful.titlebar_floating_button_normal_inactive
-- @usebeautiful beautiful.titlebar_floating_button_normal_inactive_hover
-- @usebeautiful beautiful.titlebar_floating_button_normal_inactive_press
-- @usebeautiful beautiful.titlebar_floating_button_focus_inactive
-- @usebeautiful beautiful.titlebar_floating_button_focus_inactive_hover
-- @usebeautiful beautiful.titlebar_floating_button_focus_inactive_press
function titlebar.widget.floatingbutton(c)
	local widget = titlebar.widget.button(c, "floating", aclient.object.get_floating, aclient.floating.toggle, {
		normal = beautiful.color.blue,
		hover  = util.color.alter_hsl(beautiful.color.blue, { l = 0.1 }, "add"),
		press  = util.color.alter_hsl(beautiful.color.blue, { l = 0.2 }, "add"),
	})
	update_on_signal(c, "property::floating", widget)
	return widget
end

--- Create a new maximize button for a client.
--
-- @constructorfct awful.titlebar.widget.maximizedbutton
-- @tparam client c The client for which the button is wanted.
-- @usebeautiful beautiful.titlebar_maximized_button_focus_active
-- @usebeautiful beautiful.titlebar_maximized_button_focus_active_hover
-- @usebeautiful beautiful.titlebar_maximized_button_focus_active_press
-- @usebeautiful beautiful.titlebar_maximized_button_normal_inactive
-- @usebeautiful beautiful.titlebar_maximized_button_normal_inactive_hover
-- @usebeautiful beautiful.titlebar_maximized_button_normal_inactive_press
-- @usebeautiful beautiful.titlebar_maximized_button_focus_inactive
-- @usebeautiful beautiful.titlebar_maximized_button_focus_inactive_hover
-- @usebeautiful beautiful.titlebar_maximized_button_focus_inactive_press
-- @usebeautiful beautiful.titlebar_maximized_button_normal
-- @usebeautiful beautiful.titlebar_maximized_button_focus
-- @usebeautiful beautiful.titlebar_maximized_button_normal_active
-- @usebeautiful beautiful.titlebar_maximized_button_normal_active_hover
-- @usebeautiful beautiful.titlebar_maximized_button_normal_active_press
function titlebar.widget.maximizedbutton(c)
	local widget = titlebar.widget.button(c, "maximized", function(cl)
		return cl.maximized
	end, function(cl, state)
		cl.maximized = not state
	end, {
		--normal = "#00000000",
		--hover  = "#2060C0",
		--press  = "#3090FF",
		normal = beautiful.color.green,
		hover  = util.color.alter_hsl(beautiful.color.green, { l = 0.1 }, "add"),
		press  = util.color.alter_hsl(beautiful.color.green, { l = 0.2 }, "add"),
	})
	update_on_signal(c, "property::maximized", widget)
	return widget
end

--- Create a new minimize button for a client.
--
-- @constructorfct awful.titlebar.widget.minimizebutton
-- @tparam client c The client for which the button is wanted.
-- @usebeautiful beautiful.titlebar_minimize_button_normal
-- @usebeautiful beautiful.titlebar_minimize_button_normal_hover
-- @usebeautiful beautiful.titlebar_minimize_button_normal_press
-- @usebeautiful beautiful.titlebar_minimize_button_focus
-- @usebeautiful beautiful.titlebar_minimize_button_focus_hover
-- @usebeautiful beautiful.titlebar_minimize_button_focus_press
function titlebar.widget.minimizebutton(c)
	local widget = titlebar.widget.button(c, "minimize",
		function() return "" end,
		function(cl) cl.minimized = not cl.minimized end, {
		--normal = "#00000000",
		--hover  = "#2060C0",
		--press  = "#3090FF",
		normal = beautiful.color.yellow,
		hover  = util.color.alter_hsl(beautiful.color.yellow, { l = 0.1 }, "add"),
		press  = util.color.alter_hsl(beautiful.color.yellow, { l = 0.2 }, "add"),
	})
	update_on_signal(c, "property::minimized", widget)
	return widget
end

--- Create a new closing button for a client.
--
-- @constructorfct awful.titlebar.widget.closebutton
-- @tparam client c The client for which the button is wanted.
-- @usebeautiful beautiful.titlebar_close_button_normal
-- @usebeautiful beautiful.titlebar_close_button_normal_hover
-- @usebeautiful beautiful.titlebar_close_button_normal_press
-- @usebeautiful beautiful.titlebar_close_button_focus
-- @usebeautiful beautiful.titlebar_close_button_focus_hover
-- @usebeautiful beautiful.titlebar_close_button_focus_press
function titlebar.widget.closebutton(c)
	return titlebar.widget.button(c, "close", function() return "" end, function(cl) cl:kill() end, {
		--normal = "#C01000",
		--normal = "#00000000",
		--hover  = "#D83010",
		--press  = "#F02010",
		normal = beautiful.color.red,
		hover  = util.color.alter_hsl(beautiful.color.red, { l = 0.1 }, "add"),
		press  = util.color.alter_hsl(beautiful.color.red, { l = 0.2 }, "add"),
	})
end

--- Create a new ontop button for a client.
--
-- @constructorfct awful.titlebar.widget.ontopbutton
-- @tparam client c The client for which the button is wanted.
-- @usebeautiful beautiful.titlebar_ontop_button_normal
-- @usebeautiful beautiful.titlebar_ontop_button_focus
-- @usebeautiful beautiful.titlebar_ontop_button_normal_active
-- @usebeautiful beautiful.titlebar_ontop_button_normal_active_hover
-- @usebeautiful beautiful.titlebar_ontop_button_normal_active_press
-- @usebeautiful beautiful.titlebar_ontop_button_focus_active
-- @usebeautiful beautiful.titlebar_ontop_button_focus_active_hover
-- @usebeautiful beautiful.titlebar_ontop_button_focus_active_press
-- @usebeautiful beautiful.titlebar_ontop_button_normal_inactive
-- @usebeautiful beautiful.titlebar_ontop_button_normal_inactive_hover
-- @usebeautiful beautiful.titlebar_ontop_button_normal_inactive_press
-- @usebeautiful beautiful.titlebar_ontop_button_focus_inactive
-- @usebeautiful beautiful.titlebar_ontop_button_focus_inactive_hover
-- @usebeautiful beautiful.titlebar_ontop_button_focus_inactive_press
function titlebar.widget.ontopbutton(c)
	local widget = titlebar.widget.button(c, "ontop",
		function(cl) return cl.ontop end,
		function(cl, state) cl.ontop = not state end, {
			normal = beautiful.color.purple,
			hover  = util.color.alter_hsl(beautiful.color.purple, { l = 0.1 }, "add"),
			press  = util.color.alter_hsl(beautiful.color.purple, { l = 0.2 }, "add"),
		}
	)
	update_on_signal(c, "property::ontop", widget)
	return widget
end

--- Create a new sticky button for a client.
-- @constructorfct awful.titlebar.widget.stickybutton
-- @tparam client c The client for which the button is wanted.
-- @usebeautiful beautiful.titlebar_sticky_button_normal
-- @usebeautiful beautiful.titlebar_sticky_button_focus
-- @usebeautiful beautiful.titlebar_sticky_button_normal_active
-- @usebeautiful beautiful.titlebar_sticky_button_normal_active_hover
-- @usebeautiful beautiful.titlebar_sticky_button_normal_active_press
-- @usebeautiful beautiful.titlebar_sticky_button_focus_active
-- @usebeautiful beautiful.titlebar_sticky_button_focus_active_hover
-- @usebeautiful beautiful.titlebar_sticky_button_focus_active_press
-- @usebeautiful beautiful.titlebar_sticky_button_normal_inactive
-- @usebeautiful beautiful.titlebar_sticky_button_normal_inactive_hover
-- @usebeautiful beautiful.titlebar_sticky_button_normal_inactive_press
-- @usebeautiful beautiful.titlebar_sticky_button_focus_inactive
-- @usebeautiful beautiful.titlebar_sticky_button_focus_inactive_hover
-- @usebeautiful beautiful.titlebar_sticky_button_focus_inactive_press
function titlebar.widget.stickybutton(c)
	local widget = titlebar.widget.button(c, "sticky",
		function(cl) return cl.sticky end,
		function(cl, state) cl.sticky = not state end, {
			normal = beautiful.color.cyan,
			hover  = util.color.alter_hsl(beautiful.color.cyan, { l = 0.1 }, "add"),
			press  = util.color.alter_hsl(beautiful.color.cyan, { l = 0.2 }, "add"),
		}
	)
	update_on_signal(c, "property::sticky", widget)
	return widget
end

client.connect_signal("request::unmanage", function(c)
	all_titlebars[c] = nil
end)

return setmetatable(titlebar, { __call = function(_, ...) return new(...) end})

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
