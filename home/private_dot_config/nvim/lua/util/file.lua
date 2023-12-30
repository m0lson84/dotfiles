--[[
  File utility functions.
  @module File
  @alias file
--]]

local M = {}

--- Whether a file exists at the given path.
---@param path string: The path to check.
M.exists = function(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == 'file' or false
end

--- Get the path to the first found input file (if exists).
---@param names table The names of the files to find.
---@param cwd string The current working directory.
---@return string|nil
M.find = function(names, cwd)
  for _, file in ipairs(names) do
    local file_path = table.concat({ cwd or vim.loop.cwd(), file }, '/')
    if M.file_exists(file_path) then return file_path end
  end
  return nil
end

return M
