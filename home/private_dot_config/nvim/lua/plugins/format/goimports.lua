--[[
goimports (https://pkg.go.dev/golang.org/x/tools/cmd/goimports)
--]]

return {
  {
    'stevearc/conform.nvim',
    depends = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'goimports' }) end,
      },
    },
    opts = {
      formatters = {
        goimports = {},
      },
    },
  },
}
