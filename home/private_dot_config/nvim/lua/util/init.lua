--[[
Global utility functions.
]]
--

--- Whether current os is windows.
local is_windows = vim.loop.os_uname().version:match('Windows')

--- Whether the cursor is on the first column of the line.
local function cursor_has_words_before()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

--- Whether a directory exists at the given path.
---@param path string: The path to check.
local function directory_exists(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == 'directory' or false
end

--- Get the name of the directory for a given path.
---@param path string: The path to get the directory name for.
local function directory_name(path)
  if not path or #path == 0 then return end
  local result = path:gsub('/$', ''):gsub('/([^/]+)$', '')
  if #result ~= 0 then return result end
  if is_windows then return path:sub(1, 2):upper() end
  return '/'
end

--- Whether a file exists at the given path.
---@param path string: The path to check.
local function file_exists(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == 'file' or false
end

--- Get the path to the input directory (if exists).
---@param name string The name of the directory to find.
---@param cwd string|nil The current working directory. Defaults to the current working directory.
---@return string|nil
local function find_directory(name, cwd)
  local current_dir = cwd or vim.loop.cwd()
  repeat
    local dir_path = current_dir .. '/' .. name
    if directory_exists(dir_path) then return dir_path end
    current_dir = vim.loop.fs_realpath(current_dir .. '/..')
  until current_dir == '/'
  return nil
end

--- Get the path to the first found input file (if exists).
---@param names table The names of the files to find.
---@param cwd string The current working directory.
---@return string|nil
local function find_files(names, cwd)
  for _, file in ipairs(names) do
    local file_path = table.concat({ cwd or vim.loop.cwd(), file }, '/')
    if file_exists(file_path) then return file_path end
  end
  return nil
end

--- Get configured logger.
---@return PlenaryLogger logger Local logging instance.
local function get_logger()
  return require('plenary.log').new({
    plugin = 'Local',
    level = 'debug',
    use_console = 'async',
    outfile = vim.fn.stdpath('state') .. 'local.log',
    fmt_msg = function(_, mode, path, line, msg)
      return ('%-6s%s %s: %s\n'):format(mode:upper(), os.date(), vim.fn.fnamemodify(path, ':.') .. ':' .. line, msg)
    end,
  })
end

--- Whether a string is empty.
---@param text string: The string to check.
local function is_empty(text) return text == nil or text == '' end

--- Join a list of paths.
---@param ... string: The paths to join.
local function path_join(...) return table.concat(vim.tbl_flatten({ ... }), '/') end

--- Split a string by a given character.
---@param input string The input string.
---@param sep string The character to split the string by.
---@return table strings The split string.
local function split_string(input, sep)
  if sep == nil then sep = '%s' end
  local result = {}
  for str in string.gmatch(input, '([^' .. sep .. ']+)') do
    table.insert(result, str)
  end
  return result
end

--- Create a table with the given keys and value.
---@param keys table: The keys to create the table with.
---@param value any: The value to set for each key.
local function table_create(keys, value)
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
local function table_extend_keys(table, keys, values)
  table = table or {}
  for _, key in ipairs(keys) do
    table[key] = vim.list_extend(table[key] or {}, values)
  end
  return table
end

--- Merge two or more tables.
---@param ... table: The tables to merge.
local function table_merge(...)
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

--- Get the path to the Neovim (Vim) configuration directory (if exists).
---@param cwd string|nil The current working directory. Defaults to the current working directory
---@return string|nil
local function vim_config_dir(cwd) return find_directory('.vim', cwd or vim.loop.cwd()) end

--- Get the path to the VS Code configuration directory (if exists).
---@param cwd string|nil The current working directory. Defaults to the current working directory
---@return string|nil
local function vscode_config_dir(cwd) return find_directory('.vscode', cwd or vim.loop.cwd()) end

local M = {}

M.cursor = (function() return { has_words_before = cursor_has_words_before } end)()
M.dir = (function() return { exists = directory_exists } end)()
M.file = (function() return { exists = file_exists, find = find_files } end)()
M.logger = get_logger
M.path = (function() return { dirname = directory_name, join = path_join } end)()
M.string = (function() return { is_empty = is_empty, spllit = split_string } end)()
M.table = (function() return { create = table_create, extend_keys = table_extend_keys, merge = table_merge } end)()
M.vim = (function() return { config = vim_config_dir } end)()
M.vscode = (function() return { config = vscode_config_dir } end)()

return M
