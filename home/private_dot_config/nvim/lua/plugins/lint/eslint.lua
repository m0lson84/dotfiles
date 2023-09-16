--[[
ESLint (https://eslint.org/)
--]]

return {
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'eslint-lsp', 'eslint_d' }) end,
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        eslint = {
          settings = { workingDirectory = { mode = 'auto' } },
        },
      },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters_by_ft = require('util').table.extend_keys(
        opts.formatters_by_ft,
        { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
        { 'eslint_d' }
      )
    end,
  },
}
