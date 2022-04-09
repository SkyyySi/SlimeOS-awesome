#!/usr/bin/env lua

-- Yes, this is a local variable. Deal with it :P
-- This is only intend to store read-only variables.
local g = {}
g.language = "en_US"
g.terminal = "alacritty"
g.editor = "code" -- VScode
--g.editor = g.terminal.." -e "..(os.getenv("EDITOR") or "nano") -- Alternative
g.modkey = "Mod1" -- Mod1 = Alt, Mod4 = Super
g.theme = "rimuru"

return g
