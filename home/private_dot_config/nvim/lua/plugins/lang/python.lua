--[[
Python language support
--]]

-- Import utility functions
local util = require('util')

return {

  -- Add languages to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'ninja', 'python', 'rst', 'toml' }) end,
  },

  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        pyright = {},
      },
    },
  },

  -- Configure formatters
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters_by_ft = util.table.extend_keys(opts.formatters_by_ft, { 'python' }, { 'ruff_fix', 'black' })
    end,
  },

  -- Configure debug adapter
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'mfussenegger/nvim-dap-python',
      config = function()
        local path = require('mason-registry').get_package('debugpy'):get_install_path()
        require('dap-python').setup(path .. '/venv/bin/python')
        require('dap.ext.vscode').load_launchjs()
      end,
    },
  },

  -- Configure test runner
  {
    'nvim-neotest/neotest',
    dependencies = { 'nvim-neotest/neotest-python' },
    opts = {
      adapters = {
        ['neotest-python'] = {
          runner = 'pytest',
          python = './.venv/bin/python',
          args = { '--log-level', 'DEBUG' },
          dap = { justMyCode = true },
        },
      },
    },
  },

  -- Code annotations and documentation
  {
    'danymat/neogen',
    opts = {
      languages = {
        python = { template = { annotation_convention = 'google_docstrings' } },
      },
    },
  },

  -- Activate virtual environment
  {
    'linux-cultist/venv-selector.nvim',
    cmd = 'VenvSelect',
    keys = {
      { '<leader>cv', '<cmd>:VenvSelect<cr>', ft = 'python', desc = 'Select VirtualEnv' },
    },
    opts = {
      name = { '.venv', 'venv' },
      dap_enabled = true,
    },
  },
}
