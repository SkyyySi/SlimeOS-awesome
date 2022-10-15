---@meta

---@alias GAppInfoCreateFlags "NONE"|"NEEDS_TERMINAL"|"SUPPORTS_URIS"|"SUPPORTS_STARTUP_NOTIFICATION"

---@class GAppInfo
---@field create_from_commandline fun(commandline: str, application_name: str, flags: GAppInfoCreateFlags, error: GError): GAppInfo._instance
---@field get_all fun(): GAppInfo._instance[]
---@field get_all_for_type fun(content_type: str): GAppInfo._instance[]
---@field get_default_for_type fun(content_type: str, must_support_uris: bool): GAppInfo._instance
---@field get_default_for_type_async fun(content_type: str, must_support_uris: bool)

---@class GAppInfo._instance

