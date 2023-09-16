--[[
Prettier (https://prettier.io/)
--]]

return {
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'prettierd' }) end,
  },
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters_by_ft = require('util').table.extend_keys(
        opts.formatters_by_ft,
        { 'json', 'markdown', 'yaml' },
        { 'prettierd' }
      )
    end,
  },
}
