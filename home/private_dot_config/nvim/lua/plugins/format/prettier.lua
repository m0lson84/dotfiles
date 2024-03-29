--[[
Prettier (https://prettier.io/)
--]]

-- Import utility functions
local util = require('util')

return {
  {
    'stevearc/conform.nvim',
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'prettierd' }) end,
      },
    },
    opts = function(_, opts)
      opts.formatters_by_ft = util.table.extend_keys(
        opts.formatters_by_ft,
        { 'css', 'graphql', 'handlebars', 'html', 'less', 'scss', 'vue' },
        { 'prettierd' }
      )
    end,
  },
}
