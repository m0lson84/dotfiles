--[[
Prettier (https://prettier.io/)
--]]

-- Additional configuration.
local config = {
  disabled_filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
}

return {
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'prettierd' }) end,
  },
  {
    'nvimtools/none-ls.nvim',
    opts = function(_, opts)
      vim.list_extend(opts.sources, {
        require('null-ls').builtins.formatting.prettierd.with(config),
      })
    end,
  },
}
