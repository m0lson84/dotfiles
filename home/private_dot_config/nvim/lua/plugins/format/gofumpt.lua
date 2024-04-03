--[[
gofumpt (https://github.com/mvdan/gofumpt)
--]]

return {
  {
    'stevearc/conform.nvim',
    depends = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'gofumpt' }) end,
      },
    },
    opts = {
      formatters = {
        gofumpt = {},
      },
    },
  },
}
