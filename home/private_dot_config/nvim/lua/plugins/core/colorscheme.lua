--[[
Core colorscheme configuration
--]]

return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    opts = {
      -- flavors: latte, frappe, macchiato, mocha
      flavor = 'frappe',
      transparent_background = true,
      term_colors = true,
    },
  },
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    opts = {
      -- styles: storm (default), night, moon, day
      style = 'night',
      styles = {
        sidebars = 'dark',
        floats = 'dark',
      },
    },
  },
  {
    'marko-cerovac/material.nvim',
    priority = 1000,
    opts = function()
      -- styles: oceanic (default), deep_ocean, palenight, lighter, darker
      vim.g.material_style = 'darker'
      return {
        high_visibility = { darker = true },
        lualine_style = 'stealth',
        disable = { colored_cursor = true },
      }
    end,
  },
  {
    'Mofiqul/vscode.nvim',
    priority = 1000,
    config = function()
      local background = '#1A1A1A'
      require('vscode').setup({
        color_overrides = {
          vscBack = background,
          vscLightDark = background,
          vscPopupBack = background,
          vscFoldBackground = background,
        },
      })
    end,
  },
  {
    'olimorris/onedarkpro.nvim',
    priority = 1000,
    opts = {},
  },
  {
    'sainnhe/sonokai',
    priority = 1000,
    opts = {},
  },
  {
    'LazyVim/LazyVim',
    opts = { colorscheme = 'vscode' },
  },
}
