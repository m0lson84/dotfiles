--[[
csharpier (https://csharpier.com)
--]]

return {
  {
    'stevearc/conform.nvim',
    dependencies = {
      { 'williamboman/mason.nvim', opts = { ensure_installed = { 'csharpier' } } },
    },
    opts = {
      formatters = {
        csharpier = {},
      },
    },
  },
}
