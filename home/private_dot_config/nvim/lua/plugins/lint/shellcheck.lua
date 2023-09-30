--[[
ShellCheck (https://www.shellcheck.net/)
--]]

-- Additional configuration.
local config = {
  args = { '--format', 'json', '-' },
  extra_args = { '-e', 'SH1091' },
}

return {

  -- Install dependencies
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'shellcheck' }) end,
  },

  -- Configure code actions
  {
    'nvimtools/none-ls.nvim',
    opts = function(_, opts)
      vim.list_extend(opts.sources, {
        require('null-ls').builtins.code_actions.shellcheck.with(config),
      })
    end,
  },

  -- Configure linter
  {
    'mfussenegger/nvim-lint',
    opts = {
      linters = {
        shellcheck = { args = vim.tbl_flatten({ config.args, config.extra_args }) },
      },
    },
  },
}
