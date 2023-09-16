--[[
shfmt (https://github.com/patrickvane/shfmt)
--]]

-- Additional configuration.
local config = {
  extra_args = { '-i', '2', '-ci' },
}

return {
  {
    'stevearc/conform.nvim',
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'shfmt' }) end,
      },
    },
    opts = function(_, opts)
      local shfmt = require('conform.formatters.shfmt')
      opts.formatters_by_ft = require('util').table.extend_keys(
        opts.formatters_by_ft,
        { 'bash', 'dotenv', 'sh', 'zsh' },
        { 'shfmt' }
      )
      require('conform').formatters.shfmt = vim.tbl_deep_extend('force', shfmt, {
        args = require('conform.util').extend_args(shfmt.args, config.extra_args, { append = true }),
      })
    end,
  },
}
