return {
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    opts = { style = 'night' },
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
    opts = { colorscheme = 'codedark' },
  },
  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lualine').setup({
        options = { theme = 'codedark' },
      })
    end,
  },
}
