--[[
C# language support
--]]

return {

  -- Add languages to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'c_sharp' } },
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
    opts = {
      formatters_by_ft = {
        cs = { 'csharpier' },
      },
    },
  },

  -- Configure debug adapter
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      { 'williamboman/mason.nvim', opts = { ensure_installed = { 'netcoredbg' } } },
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
