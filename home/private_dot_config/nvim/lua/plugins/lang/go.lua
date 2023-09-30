--[[
Go language support
--]]

return {

  -- Import extra configuration
  { import = 'lazyvim.plugins.extras.lang.go' },

  -- Configure language server
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
