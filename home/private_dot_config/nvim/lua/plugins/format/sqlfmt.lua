--[[
sqlfmt (https://sqlfmt.com/)
--]]

return {
  {
    'stevearc/conform.nvim',
    dependencies = {
      { 'williamboman/mason.nvim', opts = { ensure_installed = { 'sqlfmt' } } },
    },
    opts = {
      formatters = {
        sqlfmt = {},
      },
    },
  },
}
