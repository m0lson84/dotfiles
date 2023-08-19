--[[
Core colorscheme configuration
--]]

return {
  {
    'EdenEast/nightfox.nvim',
    priority = 1000,
    -- styles:
    -- nightfox (default)
    -- dayfox
    -- dawnfox
    -- duskfox
    -- nordfox
    -- terafox
    -- carbonfox
  },
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    opts = {
      -- styles: storm (default), night, moon, day
      style = 'night',
    },
  },
  {
    'marko-cerovac/material.nvim',
    priority = 1000,
    config = function()
      require('material').setup({
        lualine_style = 'stealth',
        high_visibility = { darker = true },
        custom_colors = function(colors)
          colors.editor.bg = '#0C0C0C'
          colors.editor.bg_alt = '#1E1E1E'
          colors.backgrounds.sidebars = colors.editor.bg
          colors.backgrounds.floating_windows = colors.editor.bg
          colors.backgrounds.non_current_windows = colors.editor.bg
        end,
      })
      -- styles: oceanic (default), deep_ocean, palenight, lighter, darker
      vim.g.material_style = 'darker'
    end,
  },
  {
    'Mofiqul/vscode.nvim',
    priority = 1000,
    config = function()
      require('vscode').setup({
        color_overrides = {
          vscBack = '#1E1E1E',
          vscTabCurrent = '#1E1E1E',
          vscLightDark = '#1E1E1E',
          vscPopupBack = '#1E1E1E',
          vscFoldBackground = '#1E1E1E',
        },
      })
    end,
  },
  {
    'navarasu/onedark.nvim',
    priority = 1000,
    config = function()
      require('onedark').setup({
        style = 'warmer',
      })
    end,
  },
  {
    'projekt0n/github-nvim-theme',
    priority = 1000,
    -- styles:
    -- default: github_dark
    -- colorblind: github_dark_colorblind
    -- dimmed: github_dark_dimmed
    -- high contrast: github_dark_high_contrast
    -- triptanopia: github_dark_triptanopia
  },
  {
    'rafamadriz/neon',
    priority = 1000,
    config = function()
      -- Styles: default, doom, dark, light
      vim.g.neon_style = 'dark'
    end,
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
    'LazyVim/LazyVim',
    opts = { colorscheme = 'vscode' },
  },
}
