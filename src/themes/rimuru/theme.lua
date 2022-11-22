local awful         = require("awful")
local gears         = require("gears")
local wibox         = require("wibox")
local menubar       = require("menubar")
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

local lfs = require("lfs")

local t = {}

--[[t.palette = {
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
--]]

t.color = {
	current = {},
	dark_mode = {},
	light_mode = {},
	is_light_mode = false
}

t.color.dark_mode._is_dark  = true
t.color.dark_mode.background = "#282a36"
t.color.dark_mode.foreground = "#f8f8f2"
t.color.dark_mode.black      = "#161925"
t.color.dark_mode.dark_gray  = "#1E1F29"
t.color.dark_mode.gray       = "#44475a"
t.color.dark_mode.blue       = "#6272a4"
t.color.dark_mode.cyan       = "#8be9fd"
t.color.dark_mode.green      = "#50fa7b"
t.color.dark_mode.orange     = "#ffb86c"
t.color.dark_mode.pink       = "#ff79c6"
t.color.dark_mode.purple     = "#bd93f9"
t.color.dark_mode.red        = "#ff5555"
t.color.dark_mode.yellow     = "#f1fa8c"
t.color.dark_mode.active     = t.color.dark_mode.gray
t.color.dark_mode.accent     = t.color.dark_mode.purple
t.color.dark_mode.__index = t.color.dark_mode

t.color.light_mode._is_dark   = false
t.color.light_mode.background = "#f8f8f2"
t.color.light_mode.foreground = "#282a36"
t.color.light_mode.black      = "#161925"
t.color.light_mode.dark_gray  = "#1E1F29"
t.color.light_mode.gray       = "#44475a"
t.color.light_mode.blue       = "#6272a4"
t.color.light_mode.cyan       = "#8be9fd"
t.color.light_mode.green      = "#50fa7b"
t.color.light_mode.orange     = "#ffb86c"
t.color.light_mode.pink       = "#ff79c6"
t.color.light_mode.purple     = "#bd93f9"
t.color.light_mode.red        = "#ff5555"
t.color.light_mode.yellow     = "#f1fa8c"
t.color.light_mode.active     = t.color.light_mode.background
t.color.light_mode.accent     = t.color.light_mode.purple
t.color.light_mode.__index = t.color.light_mode

t.color.current = t.color.dark_mode
setmetatable(t.color, t.color.current)

---@type string
t.font_size = util.scale(1) > 1 and tostring(util.round(util.scale(6))) or tostring(util.round(util.scale(12)))
t.font = "Roboto, Regular "..t.font_size
t.monospace_font = "MesloLGS NF, Bold "..t.font_size

local function refresh_colors(scheme)
	t.bg_normal   = scheme.background
	t.bg_focus    = scheme.active
	t.bg_urgent   = scheme.red
	t.bg_minimize = scheme.background
	t.bg_systray  = "#353743"

	t.fg_normal   = scheme.foreground--t.accent_secondary_brighter
	t.fg_focus    = scheme.foreground
	t.fg_urgent   = scheme.background
	t.fg_minimize = scheme.foreground

	t.useless_gap         = util.scale(5)
	t.border_width        = util.scale(2)
	t.border_color_normal = t.bg_focus
	t.border_color_active = scheme.accent
	t.border_color_marked = t.bg_urgent

	--- There are other variable sets
	--- overriding the default one when
	--- defined, the sets are:
	--- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
	--- tasklist_[bg|fg]_[focus|urgent]
	--- titlebar_[bg|fg]_[normal|focus]
	--- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
	--- mouse_finder_[color|timeout|animate_timeout|radius|factor]
	--- prompt_[fg|bg|fg_cursor|bg_cursor|font]
	--- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
	--- Example:
	--t.taglist_bg_focus = "#ff0000"

	t.titlebar_font      = "Roboto, Semibold "..t.font_size
	t.titlebar_bg_normal = scheme.background .. "F2"
	t.titlebar_bg_focus  = "#1E1F29F2"
	t.titlebar_fg_normal = scheme.foreground
	t.titlebar_fg_focus  = scheme.foreground

	--- Shape
	t.corner_radius = util.scale(20)
	function t.client_shape(cr, w, h)
		gears.shape.rounded_rect(cr, w, h, t.corner_radius)
	end

	--- Generate taglist squares:
	local taglist_square_size = util.scale(4)
	t.taglist_squares_sel = theme_assets.taglist_squares_sel(taglist_square_size, t.fg_normal)
	t.taglist_squares_unsel = theme_assets.taglist_squares_unsel(taglist_square_size, t.fg_normal)

	--- Variables set for theming notifications:
	--notification_font
	--notification_[bg|fg]
	--notification_[width|height|margin]
	--notification_[border_color|border_width|shape|opacity]

	--- Variables set for theming the menu:
	--menu_[bg|fg]_[normal|focus]
	--menu_[border_color|border_width]
	--t.menu_submenu_icon = theme_dir.."submenu.png"
	t.menu_submenu_icon = "/usr/share/icons/Papirus-Dark/24x24/actions/arrow-right.svg"
	t.menu_height = util.scale(30)
	t.menu_width  = util.scale(250)

	--- You can add as many variables as
	--- you wish and access them by using
	--- beautiful.variable in your rc.lua
	--t.bg_widget = "#cc0000"

	t.button_hover = "#FFFFFF20"
	t.button_normal = gears.color.transparent
	t.button_press = "#FFFFFF40"
	t.button_release = "#FFFFFF20"

	t.tasklist_bg_normal   = t.fg_normal
	t.tasklist_fg_normal   = t.bg_normal
	t.tasklist_bg_focus    = scheme.accent
	t.tasklist_fg_focus    = t.bg_normal
	t.tasklist_bg_urgent   = t.bg_urgent
	t.tasklist_fg_urgent   = t.fg_urgent
	t.tasklist_bg_minimize = scheme.gray
	t.tasklist_fg_minimize = t.fg_normal

	--- {{{ Titlebar icons
	t.titlebar_close_button_normal = gears.color.recolor_image(theme_dir.."titlebar/edited/close_focus.png", t.bg_normal)
	t.titlebar_close_button_focus  = gears.color.recolor_image(theme_dir.."titlebar/edited/close_focus.png", t.bg_normal)

	t.titlebar_floating_button_normal_inactive = gears.color.recolor_image(theme_dir.."titlebar/edited/floating_focus_inactive_dark.png", t.bg_normal)
	t.titlebar_floating_button_focus_inactive  = gears.color.recolor_image(theme_dir.."titlebar/edited/floating_focus_inactive_dark.png", t.bg_normal)
	t.titlebar_floating_button_normal_active   = gears.color.recolor_image(theme_dir.."titlebar/edited/floating_focus_active_dark.png", t.bg_normal)
	t.titlebar_floating_button_focus_active    = gears.color.recolor_image(theme_dir.."titlebar/edited/floating_focus_active_dark.png", t.bg_normal)

	if scheme._is_dark then
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

		t.titlebar_maximized_button_normal_inactive = "/usr/share/themes/Breeze/assets/titlebutton-maximize@2.png"
		t.titlebar_maximized_button_focus_inactive  = "/usr/share/themes/Breeze/assets/titlebutton-maximize@2.png"
		t.titlebar_maximized_button_normal_active   = "/usr/share/themes/Breeze/assets/titlebutton-maximize-maximized@2.png"
		t.titlebar_maximized_button_focus_active    = "/usr/share/themes/Breeze/assets/titlebutton-maximize-maximized@2.png"
	else
		t.titlebar_minimize_button_normal = "/usr/share/themes/Breeze-Dark/assets/titlebutton-minimize@2.png"
		t.titlebar_minimize_button_focus  = "/usr/share/themes/Breeze-Dark/assets/titlebutton-minimize@2.png"

		t.titlebar_ontop_button_normal_inactive = "/usr/share/icons/breeze-dark/actions/24/window-keep-above.svg"
		t.titlebar_ontop_button_focus_inactive  = "/usr/share/icons/breeze-dark/actions/24/window-keep-above.svg"
		t.titlebar_ontop_button_normal_active   = "/usr/share/icons/breeze-dark/actions/24/window-keep-below.svg"
		t.titlebar_ontop_button_focus_active    = "/usr/share/icons/breeze-dark/actions/24/window-keep-below.svg"

		t.titlebar_sticky_button_normal_inactive = "/usr/share/icons/breeze-dark/actions/24/window-pin.svg"
		t.titlebar_sticky_button_focus_inactive  = "/usr/share/icons/breeze-dark/actions/24/window-pin.svg"
		t.titlebar_sticky_button_normal_active   = "/usr/share/icons/breeze-dark/actions/24/window-unpin.svg"
		t.titlebar_sticky_button_focus_active    = "/usr/share/icons/breeze-dark/actions/24/window-unpin.svg"

		t.titlebar_maximized_button_normal_inactive = "/usr/share/themes/Breeze-Dark/assets/titlebutton-maximize@2.png"
		t.titlebar_maximized_button_focus_inactive  = "/usr/share/themes/Breeze-Dark/assets/titlebutton-maximize@2.png"
		t.titlebar_maximized_button_normal_active   = "/usr/share/themes/Breeze-Dark/assets/titlebutton-maximize-maximized@2.png"
		t.titlebar_maximized_button_focus_active    = "/usr/share/themes/Breeze-Dark/assets/titlebutton-maximize-maximized@2.png"
	end
	--- }}}

	--- You can use your own layout icons like this:
	t.layout_fairh      = gears.color.recolor_image(theme_dir.."layouts/fairhw.png", t.fg_normal)
	t.layout_fairv      = gears.color.recolor_image(theme_dir.."layouts/fairvw.png", t.fg_normal)
	t.layout_floating   = gears.color.recolor_image(theme_dir.."layouts/floatingw.png", t.fg_normal)
	t.layout_magnifier  = gears.color.recolor_image(theme_dir.."layouts/magnifierw.png", t.fg_normal)
	t.layout_max        = gears.color.recolor_image(theme_dir.."layouts/maxw.png", t.fg_normal)
	t.layout_fullscreen = gears.color.recolor_image(theme_dir.."layouts/fullscreenw.png", t.fg_normal)
	t.layout_tilebottom = gears.color.recolor_image(theme_dir.."layouts/tilebottomw.png", t.fg_normal)
	t.layout_tileleft   = gears.color.recolor_image(theme_dir.."layouts/tileleftw.png", t.fg_normal)
	t.layout_tile       = gears.color.recolor_image(theme_dir.."layouts/tilew.png", t.fg_normal)
	t.layout_tiletop    = gears.color.recolor_image(theme_dir.."layouts/tiletopw.png", t.fg_normal)
	t.layout_spiral     = gears.color.recolor_image(theme_dir.."layouts/spiralw.png", t.fg_normal)
	t.layout_dwindle    = gears.color.recolor_image(theme_dir.."layouts/dwindlew.png", t.fg_normal)
	t.layout_cornernw   = gears.color.recolor_image(theme_dir.."layouts/cornernww.png", t.fg_normal)
	t.layout_cornerne   = gears.color.recolor_image(theme_dir.."layouts/cornernew.png", t.fg_normal)
	t.layout_cornersw   = gears.color.recolor_image(theme_dir.."layouts/cornersww.png", t.fg_normal)
	t.layout_cornerse   = gears.color.recolor_image(theme_dir.."layouts/cornersew.png", t.fg_normal)
end

refresh_colors(t.color.current)

function t.color.switch_scheme()
	t.color.is_light_mode = not t.color.is_light_mode

	if t.color.is_light_mode then
		t.color.current = t.color.light_mode
	else
		t.color.current = t.color.dark_mode
	end

	refresh_colors(t.color.current)
	setmetatable(t.color, t.color.current)

	awesome.emit_signal("beautiful::mode_changed", t.color)
end

function t.get_dynamic_color(k)
	return function()
		return k
	end
end

function t.color.make_dynamic(widget, fields, overrides)
	fields = fields or {
		bg = "background",
		fg = "foreground",
	}

	overrides = overrides or {}
	overrides.dark = overrides.dark or {}
	overrides.light = overrides.light or {}

	--widget = wibox.widget(widget)

	awesome.connect_signal("beautiful::mode_changed", function(self)
		local override_to_check = "dark"
		if t.color.is_light_mode then
			override_to_check = "light"
		end

		for k, v in pairs(fields) do
			if overrides[override_to_check][v] then
				local new_v = overrides[override_to_check][v]
				if type(new_v) == "function" then
					widget[k] = t[new_v()]
				else
					widget[k] = new_v
				end
			else
				widget[k] = self.current[v]
			end
		end
	end)

	return widget
end

do
	t.gaps_enabled = true
	local _gap_store
	function t:toggle_gaps()
		if self.gaps_enabled then
			_gap_store = _gap_store or self.useless_gap
			self.useless_gap = 0
		else
			self.useless_gap = _gap_store
			_gap_store = nil
		end
		self.gaps_enabled = not self.gaps_enabled

		awesome.emit_signal("beautiful::gaps_status_changed")
	end

	awesome.connect_signal("slimeos::focus_mode_toggled", function(is_active)
		t:toggle_gaps()
	end)
end

--- Desktop icons
t.desktop_icon_font = "Source Sans Pro, Semibold "..t.font_size

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
--t.wallpaper = theme_dir.."background.png"
--t.wallpaper = theme_dir.."souei.png"

t.wallpaper = nil --- Just to make sure it's not accidentally set beforehand
local wallpaper_dir = theme_dir.."wallpapers/"
local wp_pref_order = { "souei_transparent_alt.png", "souei_transparent.png", "souei.png", "background.png" }
for _, wp in ipairs(wp_pref_order) do
	for file in lfs.dir(wallpaper_dir) do
		if file == wp then
			t.wallpaper = wallpaper_dir..file
			break
		end
	end
	if t.wallpaper then
		break
	end
end

t.wallpaper_widget = wibox.widget {
	{
		--{
			image      = t.wallpaper,
			resize     = true,
			halign     = "center",
			valign     = "center",
			--clip_shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, util.scale(60)) end,
			opacity    = 1,
			widget     = wibox.widget.imagebox,
		--},
		--margins = margin,
		--widget  = wibox.container.margin,
	},
	--bg = gears.color {
	--	type  = "linear",
	--	from  = { 0, 0 },
	--	to    = { 0, s.geometry.height },
	--	stops = { { 0, "#404480" }, { 1, "#406480" } },
	--},
	bg = "#9FA8DA",
	widget = wibox.container.background,
}

-- Generate Awesome icon:
t.awesome_icon = theme_assets.awesome_icon(
	t.menu_height, t.bg_focus, t.fg_focus
)

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
--t.icon_theme = "Papirus-Dark-nordic-blue-folders"
t.icon_theme = "Papirus-Dark"
--t.icon_theme = "Numix-Circle"
awesome.set_preferred_icon_size(64) -- use hi-res icons

-- Set different colors for urgent notifications.
rnotification.connect_signal("request::rules", function()
	rnotification.append_rule {
		rule       = { urgency = "critical" },
		properties = {
			bg = t.notification_bg_urgent or t.bg_urgent or "#BB0000",
			fg = t.notification_fg_urgent or t.fg_urgent or "#202020",
		}
	}
end)

-- bling
t.flash_focus_start_opacity = 0.85

-- icons
t.icon = {
	--
}

return t
