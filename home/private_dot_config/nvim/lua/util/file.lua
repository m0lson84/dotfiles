--[[
  File utility functions.
  @module File
  @alias file
--]]

-- Import utility functions
local util = { path = require('util.path') }

local M = {}

--- Checks whether a file exists at the given path.
---@param path string: The path to check.
M.exists = function(path)
  local full_path = vim.fn.resolve(path)
  return vim.fn.filereadable(full_path) ~= 0
end

--- Get the path to the first found input file (if exists).
---@param names table The names of the files to find.
---@param root_dir string|nil The path in which to start the search. Defaults to the current working directory.
---@return string|nil
M.find = function(names, root_dir)
  root_dir = vim.fn.resolve(root_dir) or vim.fn.getcwd()
  for _, file in ipairs(names) do
    local file_path = util.path.join(root_dir, file, '/')
    if M.exists(file_path) then return file_path end
  end
  return nil
end

--- Search for files matching a given pattern.
---@param pattern string The file pattern to match.
---@param root_dir string The root directory to start in.
---@return string[]
M.search = function(pattern, root_dir)
  local matches = {}
  local files = io.popen('find "' .. root_dir .. '" -type f')
  if files == nil then return {} end
  for file in files:lines() do
    if file:match(pattern) then table.insert(matches, file) end
  end
  files:close()
  return matches
end

return M
