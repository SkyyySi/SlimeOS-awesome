local beautiful = require("beautiful")

local lfs = require("lfs")
local lgi = require("lgi")
local glib, gio, gtk, cairo, playerctl

local menubar_utils = require("menubar.utils")

pcall(function()
	gtk = lgi.Gtk
end)

glib      = lgi.GLib
gio       = lgi.Gio
gtk       = lgi.Gtk
cairo     = lgi.cairo
playerctl = lgi.Playerctl

local utils = {
	env_vars = {
		home = os.getenv("HOME"),
		xdg_data_dirs = os.getenv("XDG_DATA_DIRS") or "/usr/local/share:/usr/share",
		xdg_current_desktop = os.getenv("XDG_CURRENT_DESKTOP") or "awesome",
	}
}

utils.terminal = debug.getinfo(1).source:match("@?(.*/)").."/awesome-sensible-terminal"

function utils.key_get_string(kf, key)
	return kf:get_string("Desktop Entry", key)
end
function utils.key_get_strings(kf, key)
	return kf:get_string_list("Desktop Entry", key)
end
function utils.key_get_localestring(kf, key)
	return kf:get_locale_string("Desktop Entry", key)
end
function utils.key_get_localestrings(kf, key)
	return kf:get_locale_string_list("Desktop Entry", key)
end
function utils.key_get_boolean(kf, key)
	return kf:get_boolean("Desktop Entry", key)
end

function utils.app_correct_actions(app, kf)
	if not app.Actions then
		return
	end

	local corrected_actions = {}
	local cur_action

	for _, action in pairs(app.Actions) do
		cur_action = "Desktop Action "..action
		corrected_actions[action] = {}

		for _, key in pairs(kf:get_keys(cur_action)) do
			corrected_actions[action][key] = kf:get_locale_string(cur_action, key)
		end
	end

	app.Actions = corrected_actions
end

utils.keys_getters = {
	Type            = utils.key_get_string,
	Version         = utils.key_get_string,
	Name            = utils.key_get_localestring,
	GenericName     = utils.key_get_localestring,
	NoDisplay       = utils.key_get_boolean,
	Comment         = utils.key_get_localestring,
	Icon            = utils.key_get_localestring,
	Hidden          = utils.key_get_boolean,
	OnlyShowIn      = utils.key_get_strings,
	NotShowIn       = utils.key_get_strings,
	DBusActivatable = utils.key_get_boolean,
	TryExec         = utils.key_get_string,
	Exec            = utils.key_get_string,
	Path            = utils.key_get_string,
	Terminal        = utils.key_get_boolean,
	Actions         = utils.key_get_strings,
	MimeType        = utils.key_get_strings,
	Categories      = utils.key_get_strings,
	Implements      = utils.key_get_strings,
	Keywords        = utils.key_get_localestrings,
	StartupNotify   = utils.key_get_boolean,
	StartupWMClass  = utils.key_get_string,
	URL             = utils.key_get_string,
	["X-MultipleArgs"]        = utils.key_get_boolean,
}

--- See https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s06.html
---@class rasti_launcher.utils.app
---@field Type string
---@field Version string
---@field Name string
---@field GenericName string
---@field NoDisplay boolean
---@field Comment string
---@field Icon string
---@field Hidden boolean
---@field OnlyShowIn string[]
---@field NotShowIn string[]
---@field DBusActivatable boolean
---@field TryExec string
---@field Exec string
---@field Path string
---@field Terminal boolean
---@field Actions table<string, { Name: string, Exec: string, Icon: string }>
---@field MimeType string[]
---@field Categories string[]
---@field Implements string[]
---@field Keywords string[]
---@field StartupNotify boolean
---@field StartupWMClass string
---@field URL string
---@field PrefersNonDefaultGPU boolean
---@field SingleMainWindow boolean
---@field X-MultipleArgs boolean
---@field X-GNOME-Bugzilla-Bugzilla string
---@field X-GNOME-Bugzilla-Product string
---@field X-GNOME-Bugzilla-Component string
---@field X-GNOME-Bugzilla-Version string
---@field DesktopFilePath string
---@field IconPath string
---@field Cmdline string

--- Default to `utils.key_get_string` if the requested getter wasn't defined above
setmetatable(utils.keys_getters, {
	__index = function(self, k)
		return utils.key_get_string
	end,
})

---@type string[]
utils.possible_icon_scales = {
	"1024x1024",
	"512x512",
	"480x480",
	"384x384",
	"310x310",
	"256x256",
	"192x192",
	"150x150",
	"128x128",
	"96x96",
	"72x72",
	"64x64",
	"48x48",
	"44x44",
	"40x40",
	"36x36",
	"32x32",
	"28x28",
	"24x24",
	"22x22",
	"20x20",
	"16x16",
}

do
	local iter = 0
	--- Make `utils.possible_icon_scales` iterable without `pairs()` / `ipairs()`
	setmetatable(utils.possible_icon_scales, {
		__call = function(self)
			iter = iter + 1
			if not utils.possible_icon_scales[iter] then
				iter = 0
				return
			end
			return utils.possible_icon_scales[iter], iter
		end,
	})
end

--- Split a string by a **single** delimiter character.
---@param str string The string to split
---@param delimiter? string A single character used as a delimiter, default is `:`
---@return string[] out
function utils.split_string(str, delimiter)
	delimiter = delimiter or ":"

	---@type string[]
	local out = { "" }

	--- Iterate over each character in `str`
	for i = 1, #str do
		--- The `i`th character in `str` 
		local c = str:sub(i, i)

		--- Insert a new string if the character is the delimiter,
		--- otherwise append the char to the last string in the `out` array
		if c == delimiter then
			table.insert(out, "")
		else
			out[#out] = out[#out]..c
		end
	end

	return out
end

--- Insert an object `obj` into the table `tb` only if both…
---
--- - … `obj` is not `nil`
--- - … `tb` does not alyready contain `ob`
---
--- Transforms and returns the input table `tb`
---@generic T1
---@param tb table<any, T1>
---@param obj T1
---@return table<any, T1> tb
function utils.try_insert(tb, obj)
	--- Check if `obj` is `nil`
	if obj == nil then
		return tb
	end

	--- Check if `tb` contains `obj`
	for k, v in pairs(tb) do
		if v == obj then
			return tb
		end
	end

	--- Now we can do the actual insertion
	table.insert(tb, obj)

	return tb
end

--- Get a list of all possible locations for .desktop files, default icons, etc.
---@return string[] all_data_dirs
function utils.get_data_dirs()
	--- An array of all base directories that will be search for applications and icons
	---@type string[]
	local all_data_dirs = {}

	local user_data_dir = utils.env_vars.home.."/.local/share"
	if lfs.attributes(user_data_dir, "mode") == "directory" then
		utils.try_insert(all_data_dirs, user_data_dir)
	end

	--- An environment variable that holds other paths, like the ones used by
	--- Flatpak and Snap packages
	for _, dir in pairs(utils.split_string(utils.env_vars.xdg_data_dirs)) do
		utils.try_insert(all_data_dirs, dir)
	end

	return all_data_dirs
end

---@param path string The root path to scan
---@return table<string|integer, any> recursive_dir_tree
function utils.get_recursive_dir_tree(path)
	local recursive_dir_tree = {}

	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." then
			local f = path.."/"..file
			local attribs = lfs.attributes(f)
			if type(attribs) == "table" then
				if attribs.mode == "directory" then
					recursive_dir_tree[file] = utils.get_recursive_dir_tree(f)
				else
					table.insert(recursive_dir_tree, file)
				end
			end
		end
	end

	return recursive_dir_tree
end

function utils.get_icon_dirs()
	local all_icon_dirs = {}

	if pcall(function() gtk.IconTheme():get_search_path() end) then
		local dirs_tmp = gtk.IconTheme():get_search_path()
		if next(dirs_tmp) ~= nil then
			all_icon_dirs = dirs_tmp
			return all_icon_dirs
		end
	end

	local data_dirs = utils.get_data_dirs()
	-- TODO: Check if the directories actually exist first
	for _, v in pairs(data_dirs) do
		table.insert(all_icon_dirs, ("%s/icons"):format(v))
	end
	for _, v in pairs(data_dirs) do
		table.insert(all_icon_dirs, ("%s/pixmaps"):format(v))
	end

	return all_icon_dirs
end

---@param app_name string
function utils.find_icon(app_name)
	---@type string[] A list of all directories 
	local search_dirs = {}

	if beautiful.icon_theme then
		for scale in utils.possible_icon_scales do
			
		end
	end
end



---@param f string Path to the `.desktop`-file
---@return rasti_launcher.utils.app app The parsed data
function utils.parse_desktop_file(f)
	---@type rasti_launcher.utils.app
	local app = { DesktopFilePath = f, Shown = true }

	local kf = glib.KeyFile()

	kf:load_from_file(f, glib.KeyFileFlags.NONE)
	local keys = kf:get_keys("Desktop Entry")

	if not kf:has_group("Desktop Entry") then
		return app
	end

	for _, key in pairs(keys) do
		app[key] = utils.keys_getters[key](kf, key)
	end

	utils.app_correct_actions(app, kf)

	--- The code below is copied straigt from the menubar module

	-- Don't show app if NoDisplay attribute is true
	if app.NoDisplay then
		app.Shown = false
	else
		-- Only check these values is NoDisplay is true (or non-existent)

		-- Only show the app if there is no OnlyShowIn attribute
		-- or if it contains wm_name or wm_name is empty
		if utils.wm_name ~= "" then
			if app.OnlyShowIn then
				app.Shown = false -- Assume false until found
				for _, wm in ipairs(app.OnlyShowIn) do
					if wm == utils.wm_name then
						app.Shown = true
						break
					end
				end
			else
				app.Shown = true
			end
		end

		-- Only need to check NotShowIn if the app is being shown
		if app.Shown and app.NotShowIn then
			for _, wm in ipairs(app.NotShowIn) do
				if wm == utils.wm_name then
					app.Shown = false
					break
				end
			end
		end
	end

	if app.Icon then
		app.IconPath = menubar_utils.lookup_icon(app.Icon)
	end

	if app.Exec and not app.Cmdline then
		-- Substitute Exec special codes as specified in
		-- http://standards.freedesktop.org/desktop-entry-spec/1.1/ar01s06.html
		if app.Name == nil then
			app.Name = '['.. f:match("([^/]+)%.desktop$") ..']'
		end
		local Cmdline = app.Exec:gsub('%%c', app.Name)
		Cmdline = Cmdline:gsub('%%[fuFU]', '')
			:gsub('%%k', app.DesktopFilePath)
		if app.IconPath then
			Cmdline = Cmdline:gsub('%%i', '--icon ' .. app.IconPath)
		else
			Cmdline = Cmdline:gsub('%%i', '')
		end
		if app.Terminal == true then
			Cmdline = utils.terminal .. ' -e ' .. Cmdline
		end
		app.Cmdline = Cmdline
	end

	return app
end

---@param f string A filename (can be relative or absolute)
---@return boolean is_desktop_file Whether `f` is a .desktop file or not
function utils.is_desktop_file(f)
	return f:match("%.desktop$") ~= nil
end

--- Allow accessing the list of all apps through a table with methods
utils.all_apps = {}
local all_apps_mt = {}
all_apps_mt.__index = all_apps_mt
setmetatable(utils.all_apps, all_apps_mt)

function all_apps_mt:clear()
	local mt = getmetatable(self)

	if mt.is_generated then
		mt.is_generated = false
		for k, v in pairs(self) do
			self[k] = nil
		end
	end

	return self
end

function all_apps_mt:update(args)
	args = {
		---@type fun(self)
		callback = args.callback,
	}

	--- Clear `self` first before populating
	self:clear()

	local data_dirs = utils.get_data_dirs()

	-- TODO: *Properly* determine these using the correct APIs
	local app_dirs = {}
	for _, dir in pairs(data_dirs) do
		table.insert(app_dirs, dir.."/applications")
	end

	for _, dir in pairs(app_dirs) do
		local dirattribs = lfs.attributes(dir)
		if type(dirattribs) == "table" and dirattribs.mode == "directory" then
			for file in lfs.dir(dir) do
				if file ~= "." and file ~= ".." then
					local f = dir.."/"..file
					local attribs = lfs.attributes(f)
					if type(attribs) == "table" then
						if attribs.mode == "directory" then
							-- TODO Make it recursive (replace this entire `lfs` block)
						else
							if utils.is_desktop_file(f) then
								--table.insert(self, {})
								self[#self] = utils.parse_desktop_file(f)
							end
						end
					end
				end
			end
		end
	end

	args.callback(self)
end

do
	local iter = 0
	--- Make `utils.all_apps` iterable without `pairs()` / `ipairs()`
	function all_apps_mt:__call()
		iter = iter + 1
		if not self[iter] then
			iter = 0
			return
		end
		return self[iter], iter
	end
end

function all_apps_mt:filter(pattern)
	local mt = getmetatable(self)
	local matches = {}
	setmetatable(matches, mt)

	for k, v in pairs(self) --[[ or (v.Comment ~= nil and v.Comment:match(pattern)) ]] do
		if (v.Name ~= nil and v.Name:match(pattern)) then
			table.insert(matches, v)
		end
	end

	return matches
end

function all_apps_mt:run(fn)
	local mt = getmetatable(self)

	if not mt.is_generated then
		self:update {
			callback = fn,
		}
	else
		fn(self)
	end

	return self
end

function all_apps_mt:sort()
	table.sort(self, function(a, b)
		--- `a.Name` or `a.Name` may be `nil`; if so, we immediatly return
		--- to prevent crashes at runtime
		if not a.Name then return false end
		if not b.Name then return true  end
		return a.Name < b.Name
	end)

	return self
end

function all_apps_mt:remove_hidden()
	local mt = getmetatable(self)
	local filtered_apps = {}
	setmetatable(filtered_apps, mt)

	H = 0
	for app in self do
		if app.Shown then
			table.insert(filtered_apps, app)
		end
	end

	--self:clear()

	return filtered_apps
end

--- If no icon is defined, just return the input
all_apps_mt._return_key_mt = {
	__index = function(self, k)
		return k
	end
}

all_apps_mt.category_icon_map = setmetatable({
	All         = "applications-all",
	Favorites   = "applications-featured",
	Recent      = "history",

	AudioVideo  = "applications-multimedia",
	Development = "applications-development",
	Education   = "applications-education",
	Game        = "applications-games",
	Graphics    = "applications-graphics",
	Network     = "applications-internet",
	Office      = "applications-office",
	Science     = "applications-science",
	Settings    = "preferences-desktop",
	System      = "applications-system",
	Utility     = "applications-utilities",
	Other       = "applications-other",
}, all_apps_mt._return_key_mt)

function all_apps_mt:categorize()
	---@type string[]
	local xdg_standard_categories = {
		"AudioVideo",  "Development", "Education",
		"Game",        "Graphics",    "Network",
		"Office",      "Science",     "Settings",
		"System",      "Utility",     "Other",
	}

	local categorized_apps = {
		AudioVideo  = { name = "Multimedia",  icon = utils.all_apps.category_icon_map.AudioVideo,  apps = {} },
		Development = { name = "Development", icon = utils.all_apps.category_icon_map.Development, apps = {} },
		Education   = { name = "Education",   icon = utils.all_apps.category_icon_map.Education,   apps = {} },
		Game        = { name = "Games",       icon = utils.all_apps.category_icon_map.Game,        apps = {} },
		Graphics    = { name = "Graphics",    icon = utils.all_apps.category_icon_map.Graphics,    apps = {} },
		Network     = { name = "Internet",    icon = utils.all_apps.category_icon_map.Network,     apps = {} },
		Office      = { name = "Office",      icon = utils.all_apps.category_icon_map.Office,      apps = {} },
		Science     = { name = "Science",     icon = utils.all_apps.category_icon_map.Science,     apps = {} },
		Settings    = { name = "Settings",    icon = utils.all_apps.category_icon_map.Settings,    apps = {} },
		System      = { name = "System",      icon = utils.all_apps.category_icon_map.System,      apps = {} },
		Utility     = { name = "Accessories", icon = utils.all_apps.category_icon_map.Utility,     apps = {} },
		Other       = { name = "Other",       icon = utils.all_apps.category_icon_map.Other,       apps = {} },
	}

	--- Search through each app
	for app in self do
		local category_found = false

		--- A 2D loop through both the standard categories and the ones
		--- defined by an app. If an app has 1 or more standard categories,
		--- it will be inserted into each(!) of them. Otherwise, it goes into
		--- the "Other" category.
		for _, xdg_standard_category in pairs(xdg_standard_categories) do
			for _, app_category in pairs(app.Categories) do
				if app_category == xdg_standard_category then
					category_found = true
					table.insert(categorized_apps[app_category].apps, app)
				end
			end
		end

		if not category_found then
			table.insert(categorized_apps.Other.apps, app)
		end
	end

	return categorized_apps
end

return utils
