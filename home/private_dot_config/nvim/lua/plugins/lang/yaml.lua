--[[
YAML language support
--]]

-- Import utility functions
local util = require('util')

return {

  -- Import extra configuration
  { import = 'lazyvim.plugins.extras.lang.yaml' },

  -- Configure formatters
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters_by_ft = util.formatter.set(opts.formatters_by_ft, { 'yaml' }, { 'prettierd' })
    end,
  },
}
