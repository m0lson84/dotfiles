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
    'nvimtools/none-ls.nvim',
    opts = function(_, opts)
      vim.list_extend(opts.sources, {
        require('null-ls').builtins.diagnostics.markdownlint.with(config),
      })
    end,
  },
}
