--[[
Dart language support
--]]

return {

  -- Add languages to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'dart' } },
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
