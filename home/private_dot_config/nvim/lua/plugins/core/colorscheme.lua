return {
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    opts = { style = 'night' },
  },
  {
    'catppuccin/nvim',
    priority = 1000,
  },
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
  },
  {
    'marko-cerovac/material.nvim',
    priority = 1000,
    config = function()
      require('material').setup({})
      vim.g.material_style = 'darker'
    end,
  },
  {
    'Mofiqul/vscode.nvim',
    priority = 1000,
  },
  {
    'olimorris/onedarkpro.nvim',
    priority = 1000,
  },
  {
    'projekt0n/github-nvim-theme',
    priority = 1000,
  },
  {
    'rafamadriz/neon',
    priority = 1000,
    config = function() vim.g.neon_style = 'dark' end,
  },
  {
    'sainnhe/edge',
    priority = 1000,
  },
  {
    'sainnhe/sonokai',
    priority = 1000,
  },
  {
    'tomasiser/vim-code-dark',
    priority = 1000,
    config = function()
      vim.g.codedark_modern = 1
      vim.g.codedark_italics = 1
    end,
  },
  {
    'LazyVim/LazyVim',
    opts = { colorscheme = 'vscode' },
  },
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lualine').setup({
        options = { theme = 'vscode' },
      })
    end,
  },
}
