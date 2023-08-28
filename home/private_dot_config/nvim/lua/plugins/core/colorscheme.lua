--[[
Core colorscheme configuration
--]]

return {
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    opts = {
      -- styles: storm (default), night, moon, day
      style = 'night',
      terminal_colors = false,
      styles = { sidebars = 'dark', floats = 'dark' },
      sidebars = { 'qf', 'vista_kind', 'terminal', 'packer' },
      hide_inactive_statusline = true,
      lualine_bold = true,
      on_highlights = function(highlights, colors)
        highlights.DiagnosticVirtualTextError = { fg = colors.error, bg = colors.none }
        highlights.DiagnosticVirtualTextWarn = { fg = colors.warning, bg = colors.none }
        highlights.DiagnosticVirtualTextInfo = { fg = colors.info, bg = colors.none }
        highlights.DiagnosticVirtualTextHint = { fg = colors.hint, bg = colors.none }
        highlights.LspInlayHint = { fg = colors.dark3, bg = colors.none }
      end,
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
      require('vscode').setup({
        italic_comments = true,
        disable_nvimtree_bg = true,
        color_overrides = {
          vscBack = '#1E1E1E',
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
    opts = {
      -- styles: dark (default), darker, cool, deep, warm, warmer
      style = 'warmer',
      term_colors = false,
    },
  },
  {
    'LazyVim/LazyVim',
    opts = { colorscheme = 'vscode' },
  },
}
