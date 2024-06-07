--[[
gofumpt (https://github.com/mvdan/gofumpt)
--]]

return {
  {
    'stevearc/conform.nvim',
    depends = {
      { 'williamboman/mason.nvim', opts = { ensure_installed = { 'gofumpt' } } },
    },
    opts = {
      formatters = {
        gofumpt = {},
      },
    },
  },
}
