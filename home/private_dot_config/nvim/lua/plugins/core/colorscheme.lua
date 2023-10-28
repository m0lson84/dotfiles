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
      on_colors = function(colors)
        local util = require('tokyonight.util')
        colors.bg = colors.bg_dark
        colors.border = util.lighten(colors.dark3, 0.95, colors.fg_dark)
        colors.border_highlight = util.darken(colors.blue1, 0.9)
        colors.unused = util.lighten(colors.terminal_black, 0.6, colors.fg_dark)
      end,
      on_highlights = function(highlights, colors)
        highlights.ColorColumn = { bg = colors.fg }
        highlights.DiagnosticUnnecessary = { fg = colors.unused, bg = colors.none }
        highlights.DiagnosticVirtualTextError = { fg = colors.error, bg = colors.none }
        highlights.DiagnosticVirtualTextWarn = { fg = colors.warning, bg = colors.none }
        highlights.DiagnosticVirtualTextInfo = { fg = colors.info, bg = colors.none }
        highlights.DiagnosticVirtualTextHint = { fg = colors.hint, bg = colors.none }
        highlights.LspInlayHint = { fg = colors.dark3, bg = colors.none }
      end,
    },
  },
  {
    'LazyVim/LazyVim',
    opts = { colorscheme = 'tokyonight' },
  },
}
