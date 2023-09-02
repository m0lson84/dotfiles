--[[
Rust language support
--]]

return {

  -- Use LazyVim plugin as a starting point
  { import = 'lazyvim.plugins.extras.lang.rust' },

  -- Additional LSP configuration
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
      local util = require('util')
      if type(opts.languages) ~= 'table' then return end
      util.table_merge(opts.languages, { rust = { template = { annotation_convention = 'rustdoc' } } })
    end,
  },
}
