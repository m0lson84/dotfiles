--[[
goimports (https://pkg.go.dev/golang.org/x/tools/cmd/goimports)
--]]

return {
  {
    'stevearc/conform.nvim',
    dependencies = {
      { 'williamboman/mason.nvim', opts = { ensure_installed = { 'goimports' } } },
    },
    opts = {
      formatters = {
        goimports = {},
      },
    },
  },
}
