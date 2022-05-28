local gears = require("gears")

-- Yes, this is a local variable. Deal with it :P
-- This is only intend to store read-only variables.
local g = {}

---@type string
g.config_dir = gears.filesystem.get_configuration_dir()

---@type number
g.scaling_factor = 1

---@type string
g.language = "en_US"

---@type string[]
g.enabled_keyboard_layouts = {"de", "us"}

---@type string
g.keyboard_layout = g.enabled_keyboard_layouts[1]

---@type string
g.terminal = "wezterm"
--g.terminal = "alacritty"
--g.terminal = "alacritty --config-file "..g.config_dir.."themes/rimuru/alacritty.yml"

---@type string
g.editor = "code" -- VScode
--g.editor = g.terminal.." -e "..(os.getenv("EDITOR") or "nano") -- Alternative

---@type string
g.modkey = "Mod1" -- Mod1 = Alt, Mod4 = Super

---@type string
g.theme = "rimuru"

---@type string
g.web_browser = "firefox"

---@type string
g.file_browser = "dolphin"

return g
