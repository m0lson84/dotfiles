--[[
  Lua table utility functions.
  @module Table
  @alias table
--]]

local M = {}

--- Create a table with the given keys and value.
---@param keys table: The keys to create the table with.
---@param value any: The value to set for each key.
M.create = function(keys, value)
  local table = {}
  for _, key in ipairs(keys) do
    table[key] = value
  end
  return table
end

--- Extend a table of lists by key.
---@param table table The table to extend.
---@param keys table List of keys to extend.
---@param values table The values to extend the table with.
M.extend_keys = function(table, keys, values)
  table = table or {}
  for _, key in ipairs(keys) do
    table[key] = vim.list_extend(table[key] or {}, values)
  end
  return table
end

--- Merge two or more tables.
---@param ... table: The tables to merge.
M.merge = function(...)
  local result = {}
  for _, t in ipairs({ ... }) do
    for k, v in pairs(t) do
      result[k] = v
    end
    local mt = getmetatable(t)
    if mt then setmetatable(result, mt) end
  end
  return result
end

return M
