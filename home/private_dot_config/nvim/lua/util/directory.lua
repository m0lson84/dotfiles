--[[
  Directory utility functions.
  @module Directory
  @alias directory
--]]

--- Whether current os is windows.
local is_windows = vim.loop.os_uname().version:match('Windows')

local M = {}

--- Whether a directory exists at the given path.
---@param path string: The path to check.
M.exists = function(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == 'directory' or false
end

--- Get the path to the input directory (if exists).
---@param name string The name of the directory to find.
---@param cwd string|nil The current working directory. Defaults to the current working directory.
---@return string|nil
M.find = function(name, cwd)
  local current_dir = cwd or vim.loop.cwd()
  repeat
    local dir_path = current_dir .. '/' .. name
    if M.directory_exists(dir_path) then return dir_path end
    current_dir = vim.loop.fs_realpath(current_dir .. '/..')
  until current_dir == '/'
  return nil
end

--- Get the name of the directory for a given path.
---@param path string: The path to get the directory name for.
M.name = function(path)
  if not path or #path == 0 then return end
  local result = path:gsub('/$', ''):gsub('/([^/]+)$', '')
  if #result ~= 0 then return result end
  if is_windows then return path:sub(1, 2):upper() end
  return '/'
end

return M
