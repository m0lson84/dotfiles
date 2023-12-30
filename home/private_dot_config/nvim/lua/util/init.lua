--[[
Global utility functions.
]]
--

--- Whether the cursor is on the first column of the line.
local function cursor_has_words_before()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
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

local M = {}

M.config = require('util.config')
M.cursor = (function() return { has_words_before = cursor_has_words_before } end)()
M.dir = require('util.directory')
M.file = require('util.file')
M.logger = get_logger
M.jupyter = require('util.jupyter')
M.path = require('util.path')
M.string = require('util.string')
M.table = require('util.table')

return M
