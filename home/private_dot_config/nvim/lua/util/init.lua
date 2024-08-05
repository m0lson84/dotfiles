--[[
  Global utility functions.
  @module Utilities
  @alias utils
]]
--

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
M.cursor = require('util.cursor')
M.dir = require('util.directory')
M.file = require('util.file')
M.format = require('util.format')
M.logger = get_logger
M.notebook = require('util.notebook')
M.path = require('util.path')
M.string = require('util.string')
M.table = require('util.table')

return M
