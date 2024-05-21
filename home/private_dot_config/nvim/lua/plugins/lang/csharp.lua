--[[
C# language support
--]]

-- Import utility functions
local util = require('util')

return {

  -- Add languages to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'c_sharp' }) end,
  },

  -- Configure language server
  { 'Hoffs/omnisharp-extended-lsp.nvim', lazy = true },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        omnisharp = {
          handlers = {
            ['textDocument/definition'] = function(...) return require('omnisharp_extended').handler(...) end,
          },
          keys = {
            {
              'gd',
              function() require('omnisharp_extended').telescope_lsp_definitions() end,
              desc = 'Goto Definition',
            },
          },
          enable_roslyn_analyzers = true,
          organize_imports_on_format = true,
          enable_import_completion = true,
        },
      },
    },
  },

  -- Configure formatters
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters_by_ft = util.table.extend_keys(opts.formatters_by_ft, { 'cs' }, { 'csharpier' })
    end,
  },

  -- Configure debug adapter
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts)
          if type(opts.ensure_installed) == 'table' then vim.list_extend(opts.ensure_installed, { 'netcoredbg' }) end
        end,
      },
    },
    opts = function(_, opts)
      local dap = require('dap')
      if not dap.adapters['netcoredbg'] then
        require('dap').adapters['netcoredbg'] = {
          type = 'executable',
          command = vim.fn.exepath('netcoredbg'),
          args = { '--interpreter=vscode' },
        }
      end
      for _, lang in ipairs({ 'cs', 'fsharp', 'vb' }) do
        if not dap.configurations[lang] then
          dap.configurations[lang] = {
            {
              type = 'netcoredbg',
              name = 'Launch file',
              request = 'launch',
              program = function() return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/', 'file') end,
              cwd = '${workspaceFolder}',
            },
          }
        end
      end
      return opts
    end,
  },

  -- Configure test runner
  {
    'nvim-neotest/neotest',
    dependencies = { 'Issafalcon/neotest-dotnet' },
    opts = {
      adapters = {
        ['neotest-dotnet'] = {},
      },
    },
  },

  -- Code annotations and documentation
  {
    'danymat/neogen',
    opts = {
      languages = {
        cs = { template = { annotation_convention = 'xmldoc' } },
      },
    },
  },
}