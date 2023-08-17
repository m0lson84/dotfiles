--[[
Global utility functions.
]]
--

--- Whether current os is windows.
local is_windows = vim.loop.os_uname().version:match('Windows')

--- Get the name of the directory for a given path.
-- @param path The path to get the directory name for.
-- @return The directory name.
local function directory_name(path)
  if not path or #path == 0 then return end
  local result = path:gsub('/$', ''):gsub('/([^/]+)$', '')
  if #result ~= 0 then return result end
  if is_windows then return path:sub(1, 2):upper() end
  return '/'
end

--- Whether a file exists at the given path.
-- @param path The path to check.
local function file_exists(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type or false
end

--- Whether a string is empty.
-- @param text The string to check.
local function is_empty(text) return text == nil or text == '' end

--- Join a list of paths.
-- @param ... The paths to join.
local function path_join(...) return table.concat(vim.tbl_flatten({ ... }), '/') end

local M = {}

--- Whether the cursor is on the first column of the line.
M.has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

--- Merge two or more tables.
-- @param ... The tables to merge.
M.table_merge = function(...)
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

M.file = (function() return { exists = file_exists } end)()

M.path = (function() return { dirname = directory_name, join = path_join } end)()

M.string = (function() return { is_empty = is_empty } end)()

return M
