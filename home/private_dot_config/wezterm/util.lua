--[[
-- Utility functions for configuring WezTerm.
--]]

local wezterm = require('wezterm') --[[@as Wezterm]]

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

--- Execute a command in the local shell.
---@param command string The command to execute.
---@return string | nil output The output of the command.
function M.execute(command)
  local handle = io.popen(command)
  if handle == nil then return nil end
  local result = handle:read('*a')
  handle:close()
  return result:gsub('%s+', '')
end

--- Get information about the target platform.
---@return TargetInfo target Information about the target platform.
function M.get_target()
  local target = split_string(wezterm.target_triple, '-')
  return {
    arch = target[1],
    os = target[2],
    platform = target[3],
  }
end

--- Get the collection of programs that can be launched.
---@return SpawnCommand[] programs The collection of programs that can be launched.
function M.launch_programs()
  local programs = {}
  local source = M.get_target().platform == 'darwin' and '/opt/homebrew/bin/' or '/usr/bin/'
  for _, shell in ipairs({ 'fish', 'bash', 'zsh' }) do
    table.insert(programs, { label = shell, args = { source .. shell } })
  end
  return programs
end

return M
