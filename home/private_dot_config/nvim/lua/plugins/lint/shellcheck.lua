--[[
ShellCheck (https://www.shellcheck.net/)
--]]

local config = {
  extra_args = { '-e', 'SC1091' },
}

return {
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) table.insert(opts.ensure_installed, 'shellcheck') end,
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    opts = function(_, opts)
      local nls = require('null-ls')
      table.insert(opts.sources, nls.builtins.code_actions.shellcheck.with(config))
      table.insert(opts.sources, nls.builtins.diagnostics.shellcheck.with(config))
    end,
  },
}
