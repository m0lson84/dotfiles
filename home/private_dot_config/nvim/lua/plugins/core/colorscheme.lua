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
        colors.bg = colors.bg_dark
        colors.border = colors.dark3
        colors.border_highlight = colors.fg_dark
      end,
      on_highlights = function(highlights, colors)
        highlights.ColorColumn = { bg = colors.fg }
        highlights.DiagnosticVirtualTextError = { fg = colors.error, bg = colors.none }
        highlights.DiagnosticVirtualTextWarn = { fg = colors.warning, bg = colors.none }
        highlights.DiagnosticVirtualTextInfo = { fg = colors.info, bg = colors.none }
        highlights.DiagnosticVirtualTextHint = { fg = colors.hint, bg = colors.none }
        highlights.LspInlayHint = { fg = colors.dark3, bg = colors.none }
      end,
    },
  },
  {
    'Mofiqul/vscode.nvim',
    priority = 1000,
    config = function() require('vscode').setup({ italic_comments = true }) end,
  },
  {
    'LazyVim/LazyVim',
    opts = { colorscheme = 'tokyonight' },
  },
}
