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

--- Concatenate multiple lists into a new list.
---@param ... table
---@return table
function M.list_concat(...)
  local result = {}
  for _, lst in ipairs({ ... }) do
    for _, v in ipairs(lst) do
      result[#result + 1] = v
    end
  end
  return result
end

--- Deep merge multiple tables into a new table. Nested tables are merged
--- recursively rather than overwritten. Later arguments take precedence.
---@param ... table
---@return table
function M.tbl_extend(...)
  local result = {}
  for _, tbl in ipairs({ ... }) do
    for k, v in pairs(tbl) do
      if type(v) == 'table' and type(result[k]) == 'table' then
        result[k] = M.merge(result[k], v)
      else
        result[k] = v
      end
    end
  end
  return result
end

return M
