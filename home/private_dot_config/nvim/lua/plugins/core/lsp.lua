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
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters_by_ft = {}
      opts.formatters = {}
    end,
  },
  {
    'mfussenegger/nvim-lint',
    opts = function(_, opts)
      opts.linters_by_ft = {}
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
