--[[
YAML language support
--]]

-- Import utility functions
local util = require('util')

return {

  -- Add languages to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'yaml' }) end,
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
            LazyVim.lsp.on_attach(function(client, _)
              if client.name == 'yamlls' then client.server_capabilities.documentFormattingProvider = true end
            end)
          end
        end,
      },
    },
  },

  -- Configure formatters
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters_by_ft = util.table.extend_keys(opts.formatters_by_ft, { 'yaml' }, { 'prettierd' })
    end,
  },
}
