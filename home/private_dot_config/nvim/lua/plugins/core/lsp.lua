--[[
Core LSP configuration
--]]

return {
  {
    'neovim/nvim-lspconfig',
    opts = function(_, opts)
      opts.format_notify = false
      opts.inlay_hints = { enabled = true }
      require('lspconfig.ui.windows').default_options = { border = vim.g.window_border }
    end,
  },
  {
    'williamboman/mason.nvim',
    opts = {
      ui = { border = vim.g.window_border },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters = {}
      opts.formatters_by_ft = {}
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
