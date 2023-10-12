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
        rust_analyzer = {
          keys = {
            { '<leader>cD', '<cmd>Neogen<cr>', desc = 'Generate Docs', mode = { 'n' } },
          },
        },
      },
    },
  },

  -- Code annotations and documentation
  {
    'danymat/neogen',
    opts = function(_, opts)
      if type(opts.languages) ~= 'table' then return end
      util.table.merge(opts.languages, { rust = { template = { annotation_convention = 'rustdoc' } } })
    end,
  },
}
