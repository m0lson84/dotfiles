--[[
gofumpt (https://github.com/mvdan/gofumpt)
--]]

return {
  {
    'stevearc/conform.nvim',
    dependencies = {
      { 'williamboman/mason.nvim', opts = { ensure_installed = { 'gofumpt' } } },
    },
    opts = {
      formatters = {
        gofumpt = {},
      },
    },
  },
}
