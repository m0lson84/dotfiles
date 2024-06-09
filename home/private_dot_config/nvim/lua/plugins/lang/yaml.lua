--[[
YAML language support
--]]

return {

  -- Add languages to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'yaml' } },
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
        yamlls = {
          capabilities = {
            textDocument = {
              foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true,
              },
            },
          },
          on_new_config = function(new_config)
            new_config.settings.yaml.schemas = vim.tbl_deep_extend(
              'force',
              new_config.settings.yaml.schemas or {},
              require('schemastore').yaml.schemas()
            )
          end,
          settings = {
            redhat = {
              telemetry = { enabled = false },
            },
            yaml = {
              keyOrdering = false,
              format = { enable = true },
              validate = true,
              schemaStore = { enable = false, url = '' },
            },
          },
        },
      },
      setup = {
        yamlls = function()
          if vim.fn.has('nvim-0.10') == 0 then
            LazyVim.lsp.on_attach(
              function(client, _) client.server_capabilities.documentFormattingProvider = true end,
              'yamlls'
            )
          end
        end,
      },
    },
  },

  -- Configure formatters
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        yaml = { 'prettierd' },
      },
    },
  },
}
