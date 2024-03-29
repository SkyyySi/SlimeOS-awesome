---@meta

--- Same as `string`. Used to indicate that a string is locallizable
--- (in which case, the locallized version should alway be used).
---@class FreeDesktop.desktop_entry.localestring : string

--- Schema for https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s06.html
---@class FreeDesktop.desktop_entry
---@field Type str
---@field Version str|nil
---@field Name FreeDesktop.desktop_entry.localestring
---@field GenericName FreeDesktop.desktop_entry.localestring|nil
---@field NoDisplay bool|nil
---@field Comment FreeDesktop.desktop_entry.localestring|nil
---@field Icon str|nil
---@field OnlyShowIn str[]|nil
---@field NotShowIn str[]|nil
---@field DBusActivatable bool|nil
---@field TryExec str|nil
---@field Exec str|nil
---@field Path str|nil
---@field Terminal bool|nil
---@field Actions str[]|nil
---@field MimeType str[]|nil
---@field Categories str[]|nil
---@field Implements str[]|nil
---@field Keywords FreeDesktop.desktop_entry.localestring[]|nil
---@field StartupNotify bool|nil
---@field StartupWMClass str|nil
---@field URL str
---@field PrefersNonDefaultGPU bool?|nil
---@field SingleMainWindow bool|nil

--- Note: your keey doesn't have to match against this; this is just
--- intended as a reminder. Just make sure to check a key's availibility
--- using `app:has_key()` first!
---@alias FreeDesktop.desktop_entry.known_keys "Type"|"Version"|"Name"|"GenericName"|"NoDisplay"|"Comment"|"Icon"|"OnlyShowIn"|"NotShowIn"|"DBusActivatable"|"TryExec"|"Exec"|"Path"|"Terminal"|"Actions"|"MimeType"|"Categories"|"Implements"|"Keywords"|"StartupNotify"|"StartupWMClass"|"URL"|"PrefersNonDefaultGPU"|"SingleMainWindow"
