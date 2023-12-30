--[[
  String utility functions.
  @module String
  @alias string
--]]

local M = {}

--- Whether a string is empty.
---@param text string: The string to check.
M.empty = function(text) return text == nil or text == '' end

--- Split a string by a given character.
---@param input string The input string.
---@param sep string The character to split the string by.
---@return table strings The split string.
M.split = function(input, sep)
  if sep == nil then sep = '%s' end
  local result = {}
  for str in string.gmatch(input, '([^' .. sep .. ']+)') do
    table.insert(result, str)
  end
  return result
end

return M
