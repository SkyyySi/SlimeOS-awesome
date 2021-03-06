local gears         = require("gears")
local awful         = require("awful")
local theme_assets  = require("beautiful.theme_assets")
local xresources    = require("beautiful.xresources")
local rnotification = require("ruled.notification")
local dpi           = xresources.apply_dpi
local gfs           = require("gears.filesystem")
local util          = require("modules.lib.util")
local theme_dir     = util.get_script_path()
local color         = require("modules.lib.color")
local rgb = color.rgb
local hsl = color.hsl

local t = {}

t.palette = {
	hsl(200, 70, 84),
	hsl(206, 46, 56),
	hsl(219, 35, 58),
	hsl(222, 43, 39),
	hsl(224, 40, 34),
	hsl(229, 51, 18),

	hsl(330, 7, 95),

	hsl(47, 53, 83),
	hsl(46, 16, 54),

	hsl(24, 75, 92),
	hsl(220, 1, 45),
	hsl(230, 6, 20),
	hsl(249, 20, 13),
	hsl(228, 22, 9),
}

t.accent_primary_bright   = hsl(200, 70, 84) -- #b9dff2
t.accent_primary_brighter = hsl(206, 46, 56) -- #5b95c2
t.accent_primary_medium   = hsl(219, 35, 58) -- #6e88b9
t.accent_primary_darker   = hsl(222, 43, 39) -- #38528e
t.accent_primary_dark     = hsl(229, 51, 18) -- #161f45

t.accent_secondary_bright   = hsl(24, 75, 92) -- #f9e7db
t.accent_secondary_brighter = hsl(47, 53, 83) -- #eae0bc
t.accent_secondary_medium   = hsl(220, 1, 45) -- #717273
t.accent_secondary_darker   = hsl(46, 16, 54) -- #9c9376
t.accent_secondary_dark     = hsl(230, 6, 20) -- #2f3036

t.accent_tertiary_bright   = hsl(345, 76, 80) -- #f3a5b8
t.accent_tertiary_brighter = hsl(348, 41, 62) -- #c67686
t.accent_tertiary_medium   = hsl(350, 33, 49) -- #a65461
t.accent_tertiary_darker   = hsl(348, 44, 26) -- #5F2531
t.accent_tertiary_dark     = hsl(348, 48, 20) -- #4b1b24

t.accent_urgent        = t.accent_urgent_bright

t.accent_bright        = hsl(330, 7, 95) -- #f3f1f2
t.accent_medium        = hsl(220, 1, 45) -- #717274
t.accent_dark          = hsl(228, 22, 9) -- #11131b

t.font = "Source Sans Pro, 12"
t.monospace_font = "MesloLGS NF, Bold 12"
t.font = t.monospace_font

t.bg_normal   = t.accent_primary_dark
t.bg_focus    = t.accent_primary_darker
t.bg_urgent   = t.accent_urgent
t.bg_minimize = t.accent_primary_medium
t.bg_systray  = t.bg_focus

t.fg_normal   = t.accent_secondary_brighter
t.fg_focus    = t.accent_bright
t.fg_urgent   = t.accent_bright
t.fg_minimize = t.accent_bright

t.useless_gap         = dpi(5)
t.border_width        = dpi(0)
t.border_color_normal = "#000000"
t.border_color_active = "#535d6c"
t.border_color_marked = "#91231c"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--t.taglist_bg_focus = "#ff0000"

t.titlebar_bg_normal = hsl(206, 46, 56)
t.titlebar_bg_focus  = hsl(200, 68, 84)
t.titlebar_fg_normal = hsl(222, 22, 9)
t.titlebar_fg_focus  = hsl(222, 22, 9)

-- Generate taglist squares:
local taglist_square_size = dpi(4)
t.taglist_squares_sel = theme_assets.taglist_squares_sel(taglist_square_size, t.fg_normal)
t.taglist_squares_unsel = theme_assets.taglist_squares_unsel(taglist_square_size, t.fg_normal)

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
--t.menu_submenu_icon = theme_dir.."submenu.png"
t.menu_height = dpi(30)
t.menu_width  = dpi(250)

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--t.bg_widget = "#cc0000"

-- Define the image to load
t.titlebar_close_button_normal = theme_dir.."titlebar/edited/close_focus.png"
t.titlebar_close_button_focus  = theme_dir.."titlebar/edited/close_focus.png"

t.titlebar_minimize_button_normal = "/usr/share/themes/Breeze/assets/titlebutton-minimize@2.png"
t.titlebar_minimize_button_focus  = "/usr/share/themes/Breeze/assets/titlebutton-minimize@2.png"

t.titlebar_ontop_button_normal_inactive = "/usr/share/icons/breeze/actions/24/window-keep-above.svg"
t.titlebar_ontop_button_focus_inactive  = "/usr/share/icons/breeze/actions/24/window-keep-above.svg"
t.titlebar_ontop_button_normal_active   = "/usr/share/icons/breeze/actions/24/window-keep-below.svg"
t.titlebar_ontop_button_focus_active    = "/usr/share/icons/breeze/actions/24/window-keep-below.svg"

t.titlebar_sticky_button_normal_inactive = "/usr/share/icons/breeze/actions/24/window-pin.svg"
t.titlebar_sticky_button_focus_inactive  = "/usr/share/icons/breeze/actions/24/window-pin.svg"
t.titlebar_sticky_button_normal_active   = "/usr/share/icons/breeze/actions/24/window-unpin.svg"
t.titlebar_sticky_button_focus_active    = "/usr/share/icons/breeze/actions/24/window-unpin.svg"

t.titlebar_floating_button_normal_inactive = theme_dir.."titlebar/edited/floating_focus_inactive.png"
t.titlebar_floating_button_focus_inactive  = theme_dir.."titlebar/edited/floating_focus_inactive.png"
t.titlebar_floating_button_normal_active   = theme_dir.."titlebar/edited/floating_focus_active.png"
t.titlebar_floating_button_focus_active    = theme_dir.."titlebar/edited/floating_focus_active.png"

t.titlebar_maximized_button_normal_inactive = "/usr/share/themes/Breeze/assets/titlebutton-maximize@2.png"
t.titlebar_maximized_button_focus_inactive  = "/usr/share/themes/Breeze/assets/titlebutton-maximize@2.png"
t.titlebar_maximized_button_normal_active   = "/usr/share/themes/Breeze/assets/titlebutton-maximize@2.png"
t.titlebar_maximized_button_focus_active    = "/usr/share/themes/Breeze/assets/titlebutton-maximize@2.png"
--[[
t.titlebar_close_button_normal = theme_dir.."titlebar/close_normal.png"
t.titlebar_close_button_focus  = theme_dir.."titlebar/close_focus.png"

t.titlebar_minimize_button_normal = theme_dir.."titlebar/minimize_normal.png"
t.titlebar_minimize_button_focus  = theme_dir.."titlebar/minimize_focus.png"

t.titlebar_ontop_button_normal_inactive = theme_dir.."titlebar/ontop_normal_inactive.png"
t.titlebar_ontop_button_focus_inactive  = theme_dir.."titlebar/ontop_focus_inactive.png"
t.titlebar_ontop_button_normal_active   = theme_dir.."titlebar/ontop_normal_active.png"
t.titlebar_ontop_button_focus_active    = theme_dir.."titlebar/ontop_focus_active.png"

t.titlebar_sticky_button_normal_inactive = theme_dir.."titlebar/sticky_normal_inactive.png"
t.titlebar_sticky_button_focus_inactive  = theme_dir.."titlebar/sticky_focus_inactive.png"
t.titlebar_sticky_button_normal_active   = theme_dir.."titlebar/sticky_normal_active.png"
t.titlebar_sticky_button_focus_active    = theme_dir.."titlebar/sticky_focus_active.png"

t.titlebar_floating_button_normal_inactive = theme_dir.."titlebar/floating_normal_inactive.png"
t.titlebar_floating_button_focus_inactive  = theme_dir.."titlebar/floating_focus_inactive.png"
t.titlebar_floating_button_normal_active   = theme_dir.."titlebar/floating_normal_active.png"
t.titlebar_floating_button_focus_active    = theme_dir.."titlebar/floating_focus_active.png"

t.titlebar_maximized_button_normal_inactive = theme_dir.."titlebar/maximized_normal_inactive.png"
t.titlebar_maximized_button_focus_inactive  = theme_dir.."titlebar/maximized_focus_inactive.png"
t.titlebar_maximized_button_normal_active   = theme_dir.."titlebar/maximized_normal_active.png"
t.titlebar_maximized_button_focus_active    = theme_dir.."titlebar/maximized_focus_active.png"
--]]
t.wallpaper = theme_dir.."background.png"

-- You can use your own layout icons like this:
t.layout_fairh      = theme_dir.."layouts/fairhw.png"
t.layout_fairv      = theme_dir.."layouts/fairvw.png"
t.layout_floating   = theme_dir.."layouts/floatingw.png"
t.layout_magnifier  = theme_dir.."layouts/magnifierw.png"
t.layout_max        = theme_dir.."layouts/maxw.png"
t.layout_fullscreen = theme_dir.."layouts/fullscreenw.png"
t.layout_tilebottom = theme_dir.."layouts/tilebottomw.png"
t.layout_tileleft   = theme_dir.."layouts/tileleftw.png"
t.layout_tile       = theme_dir.."layouts/tilew.png"
t.layout_tiletop    = theme_dir.."layouts/tiletopw.png"
t.layout_spiral     = theme_dir.."layouts/spiralw.png"
t.layout_dwindle    = theme_dir.."layouts/dwindlew.png"
t.layout_cornernw   = theme_dir.."layouts/cornernww.png"
t.layout_cornerne   = theme_dir.."layouts/cornernew.png"
t.layout_cornersw   = theme_dir.."layouts/cornersww.png"
t.layout_cornerse   = theme_dir.."layouts/cornersew.png"

-- Generate Awesome icon:
t.awesome_icon = theme_assets.awesome_icon(
	t.menu_height, t.bg_focus, t.fg_focus
)

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
t.icon_theme = "Papirus-Dark-nordic-blue-folders"

-- Set different colors for urgent notifications.
rnotification.connect_signal('request::rules', function()
	rnotification.append_rule {
		rule       = { urgency = 'critical' },
		properties = { bg = '#ff0000', fg = '#ffffff' }
	}
end)

-- bling
t.flash_focus_start_opacity = 0.85

-- icons

t.icon = {
	
}

return t
