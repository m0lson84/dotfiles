--[[
Python language support
--]]

return {

  -- Add languages to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'ninja', 'python', 'rst' } },
  },

  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    opts = {
      settings = {
        basedpyright = { disableOrganizeImports = true },
        python = { analysis = { ignore = { '*' } } },
      },
      servers = {
        basedpyright = {},
      },
    },
  },

  -- Configure formatters
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        python = { 'ruff_fix', 'ruff_format' },
      },
    },
  },

  -- Configure debug adapter
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      {
        'mfussenegger/nvim-dap-python',
        config = function() require('dap-python').setup(LazyVim.get_pkg_path('debugpy', '/venv/bin/python')) end,
      },
    },
    opts = function(_, opts)
      require('dap.ext.vscode').type_to_filetypes.python = { 'python' }
      return opts
    end,
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

  -- Auto bracket support
  {
    'hrsh7th/nvim-cmp',
    opts = function(_, opts) vim.list_extend(opts.auto_brackets or {}, { 'python' }) end,
  },

  -- Activate virtual environment
  {
    'linux-cultist/venv-selector.nvim',
    branch = 'regexp',
    ft = 'python',
    cmd = 'VenvSelect',
    keys = {
      { '<leader>cv', '<cmd>:VenvSelect<cr>', ft = 'python', desc = 'Select VirtualEnv' },
    },
    opts = {},
  },
}
