--[[
Javascript / Typescript language support
--]]

-- Import utility functions
local util = require('util')

return {

  -- Add languages to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'javascript', 'typescript', 'tsx' }) end,
  },

  -- Configure language server
  {
    -- TODO: Remove once LazyVim 12.6.0 is landed
    'yioneko/nvim-vtsls',
    lazy = true,
    opts = {},
    config = function(_, opts) require('vtsls').config(opts) end,
  },
  {
    'neovim/nvim-lspconfig',
    opts = function(_, opts)
      local lang = {
        updateImportsOnFileMove = {
          enabled = 'always',
        },
        suggest = {
          completeFunctionCalls = true,
          includeCompletionsForImportStatements = true,
        },
      }
      opts.servers.vtsls = {
        settings = {
          complete_function_calls = true,
          vtsls = {
            autoUseWorkspaceTsdk = true,
            enableMoveToFileCodeAction = true,
            experimental = {
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
          javascript = lang,
          typescript = lang,
        },
        keys = {
          {
            'gD',
            function() require('vtsls').commands.goto_source_definition(0) end,
            desc = 'Goto Source Definition',
          },
          {
            'gR',
            function() require('vtsls').commands.file_references(0) end,
            desc = 'File References',
          },
          {
            '<leader>cD',
            function() require('vtsls').commands.fix_all(0) end,
            desc = 'Fix all diagnostics',
          },
          {
            '<leader>cM',
            function() require('vtsls').commands.add_missing_imports(0) end,
            desc = 'Add missing imports',
          },
          {
            '<leader>co',
            function() require('vtsls').commands.organize_imports(0) end,
            desc = 'Organize Imports',
          },
        },
      }
      return opts
    end,
  },

  -- Configure formatters
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters_by_ft = util.table.extend_keys(
        opts.formatters_by_ft,
        { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
        {}
      )
    end,
  },

  -- Configure debug adapter
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'js-debug-adapter' }) end,
      },
    },
    opts = function(_, opts)
      local dap = require('dap')

      -- Configure node.js adapter
      if not dap.adapters['pwa-node'] then
        require('dap').adapters['pwa-node'] = {
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

      -- Define default configurations
      local filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }
      for _, lang in ipairs(filetypes) do
        dap.configurations[lang] = {
          {
            name = 'Launch File',
            type = 'pwa-node',
            request = 'launch',
            program = '${file}',
            cwd = '${workspaceFolder}',
            console = 'integratedTerminal',
          },
          {
            name = 'Attach to Process',
            type = 'pwa-node',
            request = 'attach',
            processId = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
            console = 'integratedTerminal',
          },
        }
      end

      return opts
    end,
  },

  -- Configure test runner
  {
    'nvim-neotest/neotest',
    dependencies = { 'nvim-neotest/neotest-jest' },
    opts = {
      adapters = {
        ['neotest-jest'] = {
          jestCommand = 'npm test --',
          jestConfigFile = function()
            local file = vim.fn.expand('%:p')
            if string.find(file, '/packages/') then return string.match(file, '(.-/[^/]+/)src') .. 'jest.config.ts' end
            return vim.fn.getcwd() .. '/jest.config.ts'
          end,
          cwd = function()
            local file = vim.fn.expand('%:p')
            if string.find(file, '/packages/') then return string.match(file, '(.-/[^/]+/)src') end
            return vim.fn.getcwd()
          end,
        },
      },
    },
  },

  -- Code annotations and documentation
  {
    'danymat/neogen',
    opts = function(_, opts)
      opts.languages = util.table.extend_keys(
        opts.languages or {},
        { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
        { template = { annotation_convention = 'jsdoc' } }
      )
    end,
  },
}
