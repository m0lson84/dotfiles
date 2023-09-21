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
    'nvimtools/none-ls.nvim',
    opts = function(_, opts)
      vim.list_extend(opts.sources, {
        require('null-ls').builtins.code_actions.shellcheck.with(config),
        require('null-ls').builtins.diagnostics.shellcheck.with(config),
      })
    end,
  },
}
