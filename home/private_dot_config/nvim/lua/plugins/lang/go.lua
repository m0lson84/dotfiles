--[[
Golang language support
--]]

return {

  -- Add languages to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'go', 'gomod', 'gosum', 'gotmpl', 'templ' } },
  },

  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                fieldalignment = true,
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = { '-.git', '-.vscode', '-.idea', '-.vscode-test', '-node_modules' },
              semanticTokens = true,
            },
          },
        },
      },
      setup = {
        gopls = function(_, _)
          LazyVim.lsp.on_attach(function(client, _)
            if client.server_capabilities.semanticTokensProvider then return end
            local semantic = client.config.capabilities.textDocument.semanticTokens
            if not semantic then return end
            client.server_capabilities.semanticTokensProvider = {
              full = true,
              range = true,
              legend = {
                tokenTypes = semantic.tokenTypes,
                tokenModifiers = semantic.tokenModifiers,
              },
            }
          end, 'gopls')
        end,
      },
    },
  },

  -- Configure formatters
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        go = { 'goimports', 'gofumpt' },
      },
    },
  },

  -- Configure debug adapter
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      { 'williamboman/mason.nvim', opts = { ensure_installed = { 'delve' } } },
      { 'leoluz/nvim-dap-go', opts = {} },
    },
    opts = function(_, opts)
      for _, config in ipairs(require('dap').configurations.go) do
        config.console = 'integratedTerminal'
      end
      return opts
    end,
  },

  -- Configure test runner
  {
    'nvim-neotest/neotest',
    dependencies = { 'fredrikaverpil/neotest-golang' },
    opts = {
      adapters = {
        ['neotest-golang'] = { dap_go_enabled = true },
      },
    },
  },

  -- Code annotations and documentation
  {
    'danymat/neogen',
    opts = {
      languages = {
        go = { template = { annotation_convention = 'godoc' } },
      },
    },
  },
}
