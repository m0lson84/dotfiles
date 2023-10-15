--[[
Go language support
--]]

-- Import utility functions
local util = require('util')

return {

  -- Add languages to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts) vim.treesitter.language.register('gotmpl', 'tmpl') end,
  },

  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        gopls = {},
      },
    },
  },

  -- Code annotations and documentation
  {
    'danymat/neogen',
    opts = {
      languages = {
        go = { template = { annotation_convention = 'godoc' } },
      },
    },
  },
}
