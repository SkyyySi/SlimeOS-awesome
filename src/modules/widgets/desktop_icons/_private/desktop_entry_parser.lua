--- Implementation of the latest FreeDesktop desktop entry spec,
--- as of october 2022, see https://specifications.freedesktop.org/desktop-entry-spec/latest/

local require = require

local lgi = require("lgi")
local Gio = lgi.Gio

local desktop_entry_parser = {}

--[[
--- Taken straigt from https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s06.html
desktop_entry_parser.known_keys = {
	Type = "string",
	Version = "string",
	Name = "locale_string",
	GenericName = "locale_string",
	NoDisplay = "boolean",
	Comment = "locale_string",
	Icon = "iconstring", --- see https://freedesktop.org/wiki/Specifications/icon-theme-spec/
	OnlyShowIn = "strings",
	NotShowIn = "strings",
	DBusActivatable = "boolean", --- see https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s08.html
	TryExec = "string",
	Exec = "string", --- see https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s07.html
	Path = "string",
	Terminal = "boolean",
	Actions = "strings", --- see https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s11.html
	MimeType = "strings",
	Categories = "strings",
	Implements = "strings",
	Keywords = "locale_string",
	StartupNotify = "boolean",
	StartupWMClass = "string",
	URL = "string",
	PrefersNonDefaultGPU = "boolean",
	SingleMainWindow = "boolean",
}

do
	local mt = {}
	setmetatable(desktop_entry_parser.known_keys, mt)

	function mt.__index(k)
		return "string"
	end
end
--]]

---@type GDesktopAppInfo._instance[]
desktop_entry_parser.all_apps = Gio.AppInfo.get_all()

do
	for _, app in pairs(desktop_entry_parser.all_apps) do
		print(app:get_locale_string("Name"))
	end
end

return desktop_entry_parser
