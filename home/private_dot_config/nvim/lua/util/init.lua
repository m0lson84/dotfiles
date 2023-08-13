-- Global utility functions
-- TODO: Add documentation for these functions

local is_windows = vim.loop.os_uname().version:match('Windows')

local function directory_name(path)
  if not path or #path == 0 then return end
  local result = path:gsub('/$', ''):gsub('/([^/]+)$', '')
  if #result ~= 0 then return result end
  if is_windows then return path:sub(1, 2):upper() end
  return '/'
end

local function file_exists(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type or false
end

local function is_empty(text) return text == nil or text == '' end

local function path_join(...) return table.concat(vim.tbl_flatten({ ... }), '/') end

local M = {}

function M.has_words_before()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

function M.table_merge(...)
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
