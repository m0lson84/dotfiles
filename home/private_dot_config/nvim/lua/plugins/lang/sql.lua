--[[
SQL language support
--]]

return {

  -- Add languages to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'sql' } },
  },

  -- Configure formatters
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        sql = { 'sqlfluff', 'sqlfmt' },
      },
    },
  },

  -- Configure linters
  {
    'mfussenegger/nvim-lint',
    opts = {
      linters_by_ft = {
        sql = { 'sqlfluff' },
      },
    },
  },
}
