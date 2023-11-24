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
    'williamboman/mason.nvim',
    opts = {
      ui = { border = 'rounded' },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters_by_ft = {}
      opts.formatters = {}
    end,
  },
  {
    'mfussenegger/nvim-lint',
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'editorconfig-checker' }) end,
      },
    },
    opts = function(_, opts)
      opts.linters_by_ft = { editorconfig = { 'editorconfig-checker' } }
      opts.linters = {}
    end,
  },
  {
    'folke/neoconf.nvim',
    opts = {
      local_settings = '.vim/neoconf.json',
    },
  },
}
