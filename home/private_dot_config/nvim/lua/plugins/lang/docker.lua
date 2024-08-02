--[[
Docker language support
--]]

return {

  -- Add languages to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'dockerfile' } },
  },

  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        dockerls = {},
        docker_compose_language_service = {},
      },
    },
  },

  -- Configure linters
  {
    'mfussenegger/nvim-lint',
    opts = {
      linters_by_ft = {
        dockerfile = { 'hadolint' },
      },
    },
  },

  -- Filetype icons
  {
    'echasnovski/mini.icons',
    opts = {
      file = {
        ['.dockerignore'] = { glyph = '󰡨', hl = 'MiniIconsBlue' },
      },
      filetype = {
        ['yaml.docker-compose'] = { hl = 'MiniIconsAzure' },
      },
    },
  },
}
