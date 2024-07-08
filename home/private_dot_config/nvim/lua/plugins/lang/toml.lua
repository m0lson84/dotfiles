--[[
TOML language support
--]]

return {

  -- Add languages to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'toml' } },
  },

  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        taplo = {},
      },
    },
  },

  -- Configure formatters
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        toml = { 'taplo' },
      },
    },
  },

  -- Filetype icons
  {
    'echasnovski/mini.icons',
    opts = {
      extension = {
        ['toml.tmpl'] = { glyph = '', hl = 'MiniIconsGrey' },
      },
    },
  },
}
