--[[
  Directory utility functions.
  @module Directory
  @alias directory
--]]

--- Whether current os is windows.
local is_windows = jit.os:find('Windows')

local M = {}

--- Checks whether a directory exists at the given path.
---@param path string: The path to check.
M.exists = function(path)
  local full_path = vim.fn.resolve(path)
  return vim.fn.isdirectory(full_path) ~= 0
end

--- Get the path to the input directory (if exists).
---@param name string The name of the directory to find.
---@param start_dir string|nil The path in which to start the search. Defaults to the current working directory.
---@return string|nil
M.find = function(name, start_dir)
  local current = vim.fn.resolve(start_dir) or vim.fn.getcwd()
  repeat
    local path = current .. '/' .. name
    if M.exists(path) then return path end
    current = vim.fn.resolve(current .. '/..')
  until current == '/'
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
