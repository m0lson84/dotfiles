--[[
Core LSP configuration
--]]

return {
  {
    'neovim/nvim-lspconfig',
    opts = function(_, opts)
      require('lspconfig.ui.windows').default_options = { border = vim.g.window_border }
      return opts
    end,
  },
  {
    'williamboman/mason.nvim',
    opts = {
      ui = { border = vim.g.window_border },
    },
  },
}
