--- DO NOT LOAD THIS MODULE!!!
--- It is intended for internal use ONLY!

local g = {
	os = os,
	io = io,
	error = error,
	require = require,
}

local util = g.require("desktop_icons.util")

local savestate = {}

savestate.env = {}

savestate.env.home_dir  = g.os.getenv("HOME")
savestate.env.cache_dir = g.os.getenv("XDG_CACHE_HOME") or savestate.env.home_dir.."/.cache"
savestate.store_dir = savestate.env.cache_dir.."/awesome"
savestate.store_path = savestate.store_dir.."/desktop_icon_state.lua"

---@param path? string
---@param callback fun(content): boolean Required callback after successful read
---@return boolean was_successful `false` if an error occured, otherwise true
function savestate.read_file_content(path, callback)
	path = path or savestate.store_path

	local file,err = g.io.open(path, "w")
	local content = ""

	if file then
		content = file:read()
		file:close()
	elseif err then
		g.error("ERROR: Could not load desktop layout from file: "..err)
		return false
	else
		g.error("ERROR: Could not load desktop layout from file!")
		return false
	end

	local ret = callback(content)

	if ret == nil then
		return true
	end

	return ret
end

---@param path? string
---@param content string
---@param callback? fun(string): boolean Optional callback after successful write
---@return boolean was_successful `false` if an error occured, otherwise true
function savestate.write_file_content(path, content, callback)
	path = path or savestate.store_path

	local file,err = g.io.open(path, "w")

	if file then
		file:write(content)
		file:close()
	elseif err then
		g.error("ERROR: Could not save desktop layout to file: "..err)
		return false
	else
		g.error("ERROR: Could not save desktop layout to file!")
		return false
	end

	if callback then
		local ret = callback(content)

		if ret == nil then
			return true
		end

		return ret
	end

	return true
end

---@param path? string
---@param callback fun(parsed_data): boolean Required callback after successful read
---@return boolean was_successful `false` if an error occured, otherwise true
function savestate.load_layout_from_file(path, callback)
	path = path or savestate.store_path

	local parsed_data

	-- While loading random files is generally really studpid, if an
	-- attacker wanted to inject your config with mallicious code,
	-- they could just inject it into your rc.lua directly.
	if pcall(function() return dofile(savestate.store_path) end) then
		parsed_data = dofile(savestate.store_path)
	else
		g.error("ERROR: Could not parse desktop layout from content!")
		return false
	end

	local ret = callback(parsed_data)

	if ret == nil then
		return true
	end

	return ret
end

---@param path? string
---@param content table
---@param callback? fun(string): boolean Optional callback after successful write
---@return boolean was_successful `false` if an error occured, otherwise true
function savestate.save_layout_to_file(path, content, callback)
	path = path or savestate.store_path

	local file_content = util.table_to_string(content)

	local ret = savestate.write_file_content(path, "return "..file_content.."\n")

	if callback then
		ret = callback(content)

		if ret == nil then
			return true
		end

		return ret
	end

	return ret
end

return savestate
