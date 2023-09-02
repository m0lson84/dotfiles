--[[
Go language support
--]]

return {

  -- Use LazyVim plugin as a starting point
  { import = 'lazyvim.plugins.extras.lang.go' },

  -- Additional LSP configuration
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        gopls = {
          keys = {
            { '<leader>cD', '<cmd>Neogen<cr>', desc = 'Generate Docs', mode = { 'n' } },
          },
        },
      },
    },
  },
}
