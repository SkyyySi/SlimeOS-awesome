---@meta

---@class GError
---@field new fun(domain: GQuark, code: int, format: str, ...: str): GError._instance
---@field new_literal fun(domain: GQuark, code: int, message: str): GError._instance
---@field new_valist fun(domain: GQuark, code: int, format: str, args: str[]): GError._instance

---@class GError._instance
---@field domain GQuark
---@field code int
---@field message str
---@field copy fun(self: GError._instance): GError._instance
---@field free fun(self: GError._instance)
---@field matches fun(self: GError._instance, domain: GQuark, code: int): bool
