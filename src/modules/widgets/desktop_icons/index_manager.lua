--- DO NOT LOAD THIS MODULE!!!
--- It is intended for internal use ONLY!

--- This mode collects the layout state of each desktop before committing
--- it into a file

local capi = {
	---@type screen
	screen = screen,
	awesome = awesome,
}

local g = {
	pairs = pairs,
	table = table,
	tostring = tostring,
	setmetatable = setmetatable,
	require = require,
}

local savestate = g.require("desktop_icons.savestate")

local mt = {}

do
	local i = 0
	function mt:__call()
		if i < #self then
			i = i + 1
			return self[i]
		end

		i = 0
	end
end

function mt:has_index(index)
	for i in self do
		if i == index then
			return true
		end
	end

	return false
end

function mt:clear()
	for k, v in g.pairs(self) do
		self[k] = nil
	end
end

mt.insert = g.table.insert

function mt:__tostring()
	local outs = ""
	local first = true

	for index in self do
		if first then
			first = false
			outs = "{ "..g.tostring(index)
		else
			outs = outs..", "..g.tostring(index)
		end
	end

	return outs.." }"
end

mt.__index = mt

---@param state table
---@param indecies_store? table
local function main(state, indecies_store)
	local known_desktops = {}

	indecies_store = indecies_store or setmetatable({}, mt)

	capi.awesome.connect_signal("desktop_icons::state_saved_on", function(index)
		indecies_store:insert(index)

		if indecies_store:has_index(index) and #indecies_store >= capi.screen.count() then
			savestate.save_layout_to_file(nil, state.icons_of_screen)
			indecies_store:clear()
		end
	end)
end

return main
