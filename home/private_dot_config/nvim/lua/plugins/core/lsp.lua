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
    enabled = true,
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
    'mfussenegger/nvim-lint',
    opts = {
      linters_by_ft = {},
    },
    config = function(_, opts)
      require('lint').linters_by_ft = opts.linters_by_ft
      vim.api.nvim_create_autocmd('BufEnter', { callback = function() require('lint').try_lint() end })
      vim.api.nvim_create_autocmd('BufWritePost', { callback = function() require('lint').try_lint() end })
    end,
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        ['*'] = { 'trim_whitespace', 'trim_newlines' },
      },
      format_on_save = {
        lsp_fallback = true,
        timeout_ms = 1000,
      },
    },
  },
  {
    'folke/neoconf.nvim',
    opts = {
      local_settings = '.vim/neoconf.json',
    },
  },
}
