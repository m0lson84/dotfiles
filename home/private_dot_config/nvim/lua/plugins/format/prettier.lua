--[[
Prettier (https://prettier.io/)
--]]

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
    opts = function(_, opts) table.insert(opts.ensure_installed, 'prettierd') end,
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    opts = function(_, opts)
      local nls = require('null-ls')
      table.insert(opts.sources, nls.builtins.formatting.prettierd.with(config))
    end,
  },
}
