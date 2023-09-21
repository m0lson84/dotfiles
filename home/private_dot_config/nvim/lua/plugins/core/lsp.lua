--[[
Core LSP configuration
--]]

return {

  {
    'neovim/nvim-lspconfig',
    opts = {
      format_notify = false,
      inlay_hints = { enabled = true },
    },
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    enabled = false,
  },
  {
    'nvimtools/none-ls.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'mason.nvim' },
    opts = function()
      local null_ls = require('null-ls')
      return {
        root_dir = require('null-ls.utils').root_pattern('.vim', '.vscode', 'Makefile', '.git'),
        sources = {
          null_ls.builtins.code_actions.refactoring,
        },
      }
    end,
  },
  {
    'folke/neoconf.nvim',
    opts = {
      local_settings = '.vim/neoconf.json',
    },
  },
}
