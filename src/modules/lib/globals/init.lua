local gears = require("gears")

-- Yes, this is a local variable. Deal with it :P
-- This is only intend to store read-only variables.
local g = {} ---@type table<string, string|number|boolean|string[]>

g.config_dir = gears.filesystem.get_configuration_dir() ---@type string
g.scaling_factor = 0.8 ---@type number
g.language = "en_US" ---@type string
g.enabled_keyboard_layouts = {"de", "us"} ---@type string[]
g.keyboard_layout = g.enabled_keyboard_layouts[1] ---@type string
g.terminal = "konsole" ---@type string
--g.terminal = "alacritty"
--g.terminal = "alacritty --config-file "..g.config_dir.."themes/rimuru/alacritty.yml"
g.editor = "code" ---@type string VS code
--g.editor = g.terminal.." -e "..(os.getenv("EDITOR") or "nano") -- Alternative
g.modkey = "Mod4" ---@type string Mod1 = Alt, Mod4 = Super
g.theme = "rimuru" ---@type string
g.web_browser = "firefox" ---@type string
g.file_browser = "dolphin" ---@type string
g.image_viewer = "eog" ---@type string

return g
