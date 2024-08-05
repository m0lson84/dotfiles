--[[
JSON language support
--]]

return {

  -- Add languages to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'json', 'json5', 'jsonc' } },
  },

  -- Schema store support
  {
    'b0o/SchemaStore.nvim',
    version = false,
    lazy = true,
  },

  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        jsonls = {
          on_new_config = function(new_config)
            new_config.settings.json.schemas = new_config.settings.json.schemas or {}
            vim.list_extend(new_config.settings.json.schemas, require('schemastore').json.schemas())
          end,
          settings = {
            json = {
              format = { enable = true },
              validate = { enable = true },
            },
          },
        },
      },
    },
  },

  -- Configure formatters
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        json = { 'biome-check', 'prettierd', stop_after_first = true },
        jsonc = { 'biome-check', 'prettierd', stop_after_first = true },
      },
    },
  },

  -- Filetype icons
  {
    'echasnovski/mini.icons',
    opts = {
      extension = {
        ['json.tmpl'] = { glyph = '', hl = 'MiniIconsGrey' },
      },
    },
  },
}
