--[[
Bash language support
--]]

return {

  -- Add markdown to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) ~= 'table' then return end
      vim.list_extend(opts.ensure_installed, { 'bash' })
    end,
  },

  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        bashls = {
          keys = {
            { '<leader>cD', '<cmd>Neogen<cr>', desc = 'Generate Docs', mode = { 'n' } },
          },
        },
      },
    },
  },
}
