return {

  -- Add Python & related to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(opts.ensure_installed, { 'python', 'rst', 'toml' })
      end
    end,
  },

  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        pyright = {
          python = {
            pythonPath = '${workspaceFolder}/.venv/bin/python',
          },
        },
      },
    },
  },

  -- Configure debug adapter
  {
    'mfussenegger/nvim-dap',
    optional = true,
    dependencies = {
      'mfussenegger/nvim-dap-python',
      keys = {
        { '<leader>dPt', function() require('dap-python').test_method() end, desc = 'Debug Method' },
        { '<leader>dPc', function() require('dap-python').test_class() end, desc = 'Debug Class' },
      },
      config = function()
        local path = require('mason-registry').get_package('debugpy'):get_install_path()
        require('dap-python').setup(path .. './.venv/bin/python')
      end,
    },
  },

  -- Configure test runner
  {
    'nvim-neotest/neotest',
    optional = true,
    dependencies = { 'nvim-neotest/neotest-python' },
    opts = {
      adapters = {
        ['neotest-python'] = {
          runner = 'pytest',
          python = '.venv/bin/python',
          dap = { justMyCode = true },
        },
      },
    },
  },

  -- Virtual environment (venv) management
  {
    'linux-cultist/venv-selector.nvim',
    cmd = 'VenvSelect',
    keys = { { '<leader>cv', '<cmd>:VenvSelect<cr>', desc = 'Select VirtualEnv' } },
    opts = {},
  },
}
