--[[
Python language support
--]]

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
        pyright = {},
      },
    },
  },

  -- Configure debug adapter
  {
    'mfussenegger/nvim-dap',
    optional = true,
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
    optional = true,
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
}
