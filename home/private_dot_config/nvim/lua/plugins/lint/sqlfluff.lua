--[[
SQLFluff (https://sqlfluff.com/)
--]]

return {
  {
    'mfussenegger/nvim-lint',
    dependencies = {
      { 'williamboman/mason.nvim', opts = { ensure_installed = { 'sqlfluff' } } },
    },
    opts = {
      linters = {
        sqlfluff = {},
      },
    },
  },
}
