--[[
UTILITIES
--]]

local M = {}

--- Read the system hostname from /etc/hostname.
---@return string
function M.hostname()
  local file = io.open('/etc/hostname', 'r')
  if not file then return '' end
  local name = file:read('*l') or ''
  file:close()
  return name:match('^%s*(.-)%s*$') or ''
end

return M
