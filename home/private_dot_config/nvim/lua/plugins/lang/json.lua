--[[
JSON language support
--]]

-- Import utility functions
local util = require('util')

return {

  -- Import starting configuration
  { import = 'lazyvim.plugins.extras.lang.json' },

  -- Configure formatters
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters_by_ft = util.formatter.set(opts.formatters_by_ft, { 'json', 'jsonc' }, { 'prettierd' })
    end,
  },
}
