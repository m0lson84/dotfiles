--[[
Javascript / Typescript language support
--]]

-- Import utility functions
local util = require('util')

--- Register a code action with the LSP client
---@param action string The action to be performed.
---@return function
local code_action = function(action)
  return function()
    vim.lsp.buf.code_action({
      apply = true,
      context = {
        only = { action },
        diagnostics = {},
      },
    })
  end
end

return {

  -- Add languages to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'javascript', 'typescript', 'tsx' }) end,
  },

  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        tsserver = {
          keys = {
            { '<leader>co', code_action('source.organizeImports'), desc = 'Organize Imports' },
            { '<leader>cR', code_action('source.removeUnused'), desc = 'Remove Unused Imports' },
          },
          settings = {
            completions = {
              completeFunctionCalls = true,
            },
          },
        },
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
