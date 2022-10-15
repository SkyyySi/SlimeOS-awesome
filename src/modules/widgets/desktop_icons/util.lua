--- DO NOT LOAD THIS MODULE!!!
--- It is intended for internal use ONLY!

local g = {
	io = io,
	os = os,
	error = error,
	tostring = tostring,
	require = require,
	math = math,
	next = next,
	type = type,
	pairs = pairs,
	ipairs = ipairs,
}

local awful = g.require("awful")
local gears = g.require("gears")
local xresources = g.require("beautiful.xresources")

local lgi = g.require("lgi")
local glib = lgi.GLib

local util = {}

--- Returns the first argument that is not `nil`
---@generic T1
---@generic T2
---@param value T1
---@vararg T2
---@return T1|T2
function util.default(value, ...)
	if value ~= nil then
		return value
	end

	for _, v in g.pairs {...} do
		if v ~= nil then
			return v
		end
	end

	return nil
end

util.scaling_factor = 1

---@param n number
---@return number
function util.scale(n)
	local dpi = xresources.apply_dpi(1)
	dpi = dpi * util.default(util.scaling_factor, 1) ---@type number

	return n * dpi
end

--- Check if a file exists in this path; returns `false` when
--- passed a directory instead of a file path
---@param path string
---@return boolean exists
function util.file_exists(path)
	local f= g.io.open(path, "r")

	if f ~= nil then
		g.io.close(f)
		return true
	end

	return false
end

--- Run a `callback` once after `timeout` second(s) have passed
---@param timeout number
---@param callback fun()
function util.after(timeout, callback)
	gears.timer.start_new(timeout, function()
		callback()
		return false
	end)
end

--- Replace escape sequences with their litteral representation.
---@param s string
---@return string, integer
function util.string_escape(s)
	return s:gsub("\a", [[\a]])
		:gsub("\b", [[\b]])
		:gsub("\f", [[\f]])
		:gsub("\n", [[\n]])
		:gsub("\r", [[\r]])
		:gsub("\t", [[\t]])
		:gsub("\v", [[\v]])
		:gsub("\\", [[\\]])
		:gsub("\"", [[\"]])
		:gsub("\'", [[\']])
end

---@param str string
---@param n number
---@return string
function util.string_multiply(str, n)
	if n <= 0 then
		return ""
	end

	local outs = ""
	local floor = g.math.floor(n)
	local point = n - floor

	for i = 1, n do
		outs = outs..str
	end

	if point > 0 then
		local len = #str * floor
		outs = outs..str:sub(1, g.math.floor(len))
	end

	return outs
end

---@param t table
---@param indent? string
---@param depth? integer
---@return string
function util.table_to_string(t, indent, depth)
	if g.type(t) ~= "table" then
		return ""
	end

	indent = indent or "\t" --- Tab masterrace!!!
	depth = depth or 0
	local bracket_indent = util.string_multiply(indent, depth)
	local full_indent = bracket_indent..indent

	if g.next(t) == nil then
		if depth > 0 then
			return "{},"
		else
			return "{}"
		end
	end

	local outs = "{\n"

	for k, v in g.pairs(t) do
		local tv = g.type(v)
		local tk = g.type(k)

		if tk == "string" then
			k = '"'..util.string_escape(k)..'"'
		elseif tk == "function" or tk == "thread" or tk == "userdata" then
			k = "[["..g.tostring(k).."]]"
		end

		if tv == "table" then
			outs = ("%s%s[%s] = %s"):format(outs, full_indent, k, util.table_to_string(v, indent, depth + 1).."\n")
		else
			if tv == "string" then
				v = '"'..util.string_escape(v)..'"'
			elseif tv == "function" or tv == "thread" or tv == "userdata" then
				v = "[["..g.tostring(v).."]]"
			end

			outs = ("%s%s[%s] = %s,\n"):format(outs, full_indent, k, v)
		end
	end

	if depth > 0 then
		return outs..bracket_indent.."},"
	else
		return outs..bracket_indent.."}"
	end
end

--- Call a method, but only if the parrent object exists
---@generic T1, T2
---@param parrent T1
---@param method_name string
---@return T2?
function util.try_method(parrent, method_name, ...)
	if parrent ~= nil and parrent[method_name] ~= nil then
		return parrent[method_name](parrent, ...)
	end
end

--- Remove leading and trailing spaces, tabs and newline characters
---@param s str
---@return str s_trimmed
function util.trim_string(s)
	return s:gsub("^%s*(.-)%s*$", "%1")
end

do
	---@type string?
	local cached_desktop_dir
	--- Synchronously retrive the user's desktop directory (usually `~/Desktop`)
	function util.get_desktop_dir()
		if cached_desktop_dir then
			return cached_desktop_dir
		end

		local env = {}
		env.home_dir = g.os.getenv("HOME")
		env.xdg_desktop_dir = g.os.getenv("XDG_DESKTOP_DIR")

		local desktop_dir = g.os.getenv("XDG_DESKTOP_DIR") or env.home_dir.."/Desktop"

		local tmp = g.io.popen("xdg-user-dir DESKTOP", "r")

		if tmp then
			local tmp_read = tmp:read("*a")

			if desktop_dir and tmp_read ~= "" then
				desktop_dir = util.trim_string(tmp_read)
			end
		end

		cached_desktop_dir = desktop_dir

		return cached_desktop_dir
	end
end

---@class desktop_icons.util.get_file_manager._args
---@field callback fun(file_manager: str) Required; the callback that's fired once a file manager was found
---@field terminal str Default: `"xterm"`; if the app wants to run in terminal, then do so
---@field fallback str Default: `"dolphin"`; the fallback file manager if none could be found

--- Asynchronously retrive the user's default file manager
---@param args desktop_icons.util.get_file_manager._args
function util.get_file_manager(args)
	args = util.default(args, {})
	args.callback = args.callback
	args.terminal = util.default(args.terminal, "xterm")
	args.fallback = util.default(args.fallback, "dolphin")

	awful.spawn.easy_async({ "xdg-mime", "query", "default", "inode/directory" }, function(stdout, stderr, reason, exit_code)
		local name = util.trim_string(stdout)
		local path = "/usr/share/applications/"..name
		local app = {}

		local kf = glib.KeyFile()

		local load_success, err = kf:load_from_file(path, glib.KeyFileFlags.NONE)

		if not load_success then
			g.error(("ERROR: Could not load desktop file '%s': %s"):format(path, err))
		end

		app.Exec = kf:get_string("Desktop Entry", "Exec")

		if app.Exec and not app.Cmdline then
			-- Substitute Exec special codes as specified in
			-- http://standards.freedesktop.org/desktop-entry-spec/1.1/ar01s06.html
			if app.Name == nil then
				app.Name = '['.. path:match("([^/]+)%.desktop$") ..']'
			end

			local Cmdline = app.Exec:gsub('%%c', app.Name)
			Cmdline = Cmdline:gsub('%%[fuFU]', '')
				:gsub('%%k', path)
				:gsub('%%i', '')

			if app.Terminal == true then
				Cmdline = args.terminal .. ' -e ' .. Cmdline
			end

			Cmdline = Cmdline:gsub("^%s*(.-)%s*$", "%1")
			app.Cmdline = Cmdline
		end

		if not app.Cmdline or app.Cmdline == "" then
			app.Cmdline = args.fallback
		end

		args.callback(app.Cmdline)
	end)
end

---@param path str Filepath
---@param callback fun(mime_type: str)
---@param sub_slash_with_dash bool
function util.get_mime_type(path, callback, sub_slash_with_dash)
	awful.spawn.easy_async({ "file", "-b", "--mime-type", path }, function(stdout)
		stdout = stdout:gsub("\n", "")
		if sub_slash_with_dash then
			stdout = stdout:gsub("/", "-")
		end
		callback(stdout)
	end)
end

-- TODO: Replace this with the native api for retriving previews.
--- Determine whether a file is an image usable as a cairo surface
--- using `wibox.widget.imagebox` or not.
---@param path str Filepath
---@return bool file_can_be_surface
function util.file_can_be_cairo_surface(path)
	path = path:lower()
	local f_ext = path:match("%.(.*)$")

	if not f_ext then
		return false
	end

	for _, ext in g.ipairs { "png", "jpg", "bmp", "svg", "ppm" } do
		if f_ext == ext then
			return true
		end
	end

	return false
end

return util
