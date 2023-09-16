--[[
Javascript / Typescript language support
--]]

return {

  -- Add Typescript & related to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, { 'javascript', 'jsdoc', 'typescript', 'tsx' })
    end,
  },

  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'jose-elias-alvarez/typescript.nvim' },
    opts = {
      servers = {
        tsserver = {
          keys = {
            { '<leader>cD', '<cmd>Neogen<cr>',                    desc = 'Generate Docs',   mode = { 'n' } },
            { '<leader>co', '<cmd>TypescriptOrganizeImports<CR>', desc = 'Organize Imports' },
            { '<leader>cR', '<cmd>TypescriptRenameFile<CR>',      desc = 'Rename File' },
          },
          settings = function()
            local language = {
              format = {
                indentSize = vim.o.shiftwidth,
                convertTabsToSpaces = vim.o.expandtab,
                tabSize = vim.o.tabstop,
              },
            }
            return {
              completions = { completeFunctionCalls = true },
              javascript = language,
              typescript = language,
            }
          end,
        },
      },
      setup = {
        tsserver = function(_, opts)
          require('typescript').setup({ server = opts })
          return true
        end,
      },
    },
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, require('typescript.extensions.null-ls.code-actions'))
    end,
  },

  -- Configure debug adapter
  {
    'mfussenegger/nvim-dap',
    optional = true,
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          table.insert(opts.ensure_installed, 'js-debug-adapter')
        end,
      },
    },
    opts = function()
      local dap = require('dap')
      if not dap.adapters.node then
        dap.adapters.node = {
          type = 'server',
          host = 'localhost',
          port = '${port}',
          executable = {
            command = 'node',
            args = {
              require('mason-registry').get_package('js-debug-adapter'):get_install_path()
              .. '/js-debug/src/dapDebugServer.js',
              '${port}',
            },
          },
        }
      end
      require('dap.ext.vscode').load_launchjs(nil, {
        node = { 'javascript', 'typescript' },
      })
    end,
  },

  -- Configure test runner
  {
    'nvim-neotest/neotest',
    optional = true,
    dependencies = { 'nvim-neotest/neotest-jest' },
    opts = {
      adapters = {
        ['neotest-jest'] = {
          cwd = function() return vim.fn.getcwd() end,
        },
      },
    },
  },
}
