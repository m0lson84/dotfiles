--[[
ESLint (https://eslint.org/)
--]]

return {
  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        eslint = {
          settings = { workingDirectories = { mode = 'auto' } },
        },
      },
      setup = {
        eslint = function()
          local config = { name = 'eslint: lsp', primary = false, priority = 200, filter = 'eslint' }
          local formatter = require('lazyvim.util').lsp.formatter(config)
          require('lazyvim.util').format.register(formatter)
        end,
      },
    },
  },

  -- Configure formatter
  {
    'stevearc/conform.nvim',
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'eslint_d' }) end,
      },
    },
    opts = {},
  },
}
