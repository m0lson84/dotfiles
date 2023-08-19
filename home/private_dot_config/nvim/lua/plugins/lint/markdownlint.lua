--[[
markdownlint (https://github.com/DavidAnson/markdownlint)
--]]

local config = {
  extra_args = { '--config', '~/.config/nvim/markdownlint.json' },
}

return {
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) table.insert(opts.ensure_installed, 'markdownlint') end,
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    opts = function(_, opts)
      local nls = require('null-ls')
      table.insert(opts.sources, nls.builtins.diagnostics.markdownlint.with(config))
    end,
  },
}
