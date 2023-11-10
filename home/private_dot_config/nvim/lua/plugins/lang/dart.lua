--[[
Dart language support
--]]

-- Import utility functions
local util = require('util')

return {

  -- Add languages to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'dart' }) end,
  },

  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        dartls = {
          cmd = { 'dart', 'language-server', '--protocol=lsp' },
        },
      },
    },
  },

  -- Configure flutter tools
  {
    'akinsho/flutter-tools.nvim',
    opts = {
      debugger = {
        enabled = true,
        run_via_dap = true,
        register_configurations = function(_)
          require('dap').configurations.dart = {}
          require('dap.ext.vscode').load_launchjs()
        end,
      },
    },
  },
}
