--[[
JSON language support
--]]

-- Import utility functions
local util = require('util')

return {

  -- Configure formatters
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters_by_ft = util.table.extend_keys(opts.formatters_by_ft, { 'json', 'jsonc' }, { 'prettierd' })
    end,
  },
}
