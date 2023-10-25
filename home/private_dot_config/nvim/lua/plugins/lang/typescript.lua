--[[
Javascript / Typescript language support
--]]

-- Import utility functions
local util = require('util')

return {

  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        tsserver = {},
      },
    },
  },

  -- Configure formatters
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters_by_ft = util.table.extend_keys(
        opts.formatters_by_ft,
        { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
        { 'eslint_d', 'prettierd' }
      )
    end,
  },

  -- Configure debug adapter
  {
    'mfussenegger/nvim-dap',
    opts = function()
      local dap = require('dap')
      for _, adapter in ipairs({ 'node', 'pwa-node' }) do
        if not dap.adapters[adapter] then
          require('dap').adapters[adapter] = {
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
      end
      local file_types = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }
      require('dap.ext.vscode').load_launchjs(nil, { ['pwa-node'] = file_types })
      for _, lang in ipairs(file_types) do
        if not dap.configurations['pwa-node'] then
          dap.configurations[lang] = {
            {
              name = 'Launch File',
              type = 'pwa-node',
              request = 'launch',
              program = '${file}',
              cwd = '${workspaceFolder}',
            },
            {
              name = 'Attach to Process',
              type = 'pwa-node',
              request = 'attach',
              processId = require('dap.utils').pick_process,
              cwd = '${workspaceFolder}',
            },
          }
        end
      end
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
