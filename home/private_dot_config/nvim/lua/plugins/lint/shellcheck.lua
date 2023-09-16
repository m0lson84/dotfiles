--[[
ShellCheck (https://www.shellcheck.net/)
--]]

-- Additional configuration.
local config = {
  extra_args = { '-e', 'SH1091' },
}

return {
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'shellcheck' }) end,
  },
  {
    'mfussenegger/nvim-lint',
    opts = function(_, opts)
      local shellcheck = require('lint.linters.shellcheck')
      require('lint').linters.shellcheck = vim.tbl_deep_extend('force', shellcheck, {
        args = vim.tbl_flatten({ shellcheck.args, config.extra_args }),
      })
      opts.linters_by_ft = require('util').table.extend_keys(
        opts.linters_by_ft,
        { 'bash', 'dotenv', 'sh', 'zsh' },
        { 'shellcheck' }
      )
    end,
  },
}
