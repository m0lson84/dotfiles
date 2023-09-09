--[[
Core LSP configuration
--]]

return {
  {
    'folke/neoconf.nvim',
    config = {
      local_settings = '.vim/neoconf.json',
    },
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'mason.nvim' },
    opts = function()
      return {
        root_dir = require('null-ls.utils').root_pattern('.vim', '.vscode', 'Makefile', '.git'),
        sources = {},
      }
    end,
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      format_notify = false,
      inlay_hints = { enabled = true },
    },
  },
}
