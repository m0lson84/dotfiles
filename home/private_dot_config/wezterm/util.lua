--[[
-- Utility functions for configuring WezTerm.
--]]

local terminal = require('wezterm')

--- Split a string by a given separator.
---@param input string The string to split.
---@param separator string The separator to split on.
---@return table<string> strings The split string.
local split_string = function(input, separator)
  local result = {}
  for part in string.gmatch(input, '([^' .. separator .. ']+)') do
    table.insert(result, part)
  end
  return result
end

---@class TargetInfo Information about the target platform.
---@field arch string The architecture of the target.
---@field os string The target operating system.
---@field platform string The platform the terminal was built for.

local M = {}

--- Get information about the target platform.
---@return TargetInfo target Information about the target platform.
function M.get_target()
  local target = split_string(terminal.target_triple, '-')
  return {
    arch = target[1],
    os = target[2],
    platform = target[3],
  }
end

return M
