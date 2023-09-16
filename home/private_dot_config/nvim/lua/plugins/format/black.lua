--[[
Black (https://github.com/psf/black)
--]]

return {
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'black' }) end,
  },
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters_by_ft = require('util').table.extend_keys(opts.formatters_by_ft, { 'python' }, { 'black' })
    end,
  },
}
