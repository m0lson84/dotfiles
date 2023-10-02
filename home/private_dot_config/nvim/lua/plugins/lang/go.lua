--[[
Go language support
--]]

return {

  -- Import extra configuration
  { import = 'lazyvim.plugins.extras.lang.go' },

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
        gopls = {
          keys = {
            { '<leader>cD', '<cmd>Neogen<cr>', desc = 'Generate Docs', mode = { 'n' } },
          },
        },
      },
    },
  },
}
