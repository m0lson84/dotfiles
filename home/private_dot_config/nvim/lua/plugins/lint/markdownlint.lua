--[[
markdownlint (https://github.com/DavidAnson/markdownlint)
--]]

-- Additional configuration.
local config = {
  extra_args = { '--config', '~/.config/nvim/markdownlint.json' },
}

return {
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'markdownlint' }) end,
  },
  {
    'mfussenegger/nvim-lint',
    opts = function(_, opts)
      local markdownlint = require('lint.linters.markdownlint')
      require('lint').linters.markdownlint = vim.tbl_deep_extend('force', markdownlint, {
        args = vim.tbl_flatten({ markdownlint.args, config.extra_args }),
      })
      opts.linters_by_ft = require('util').table.extend_keys(opts.linters_by_ft, { 'markdown' }, { 'markdownlint' })
    end,
  },
}
