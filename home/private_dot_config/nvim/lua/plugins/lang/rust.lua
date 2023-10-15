--[[
Rust language support
--]]

-- Import utility functions
local util = require('util')

return {

  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        rust_analyzer = {},
      },
    },
  },

  -- Code annotations and documentation
  {
    'danymat/neogen',
    opts = {
      languages = {
        rust = { template = { annotation_convention = 'rustdoc' } },
      },
    },
  },
}
