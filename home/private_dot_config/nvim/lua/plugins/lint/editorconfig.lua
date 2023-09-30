--[[
editorconfig-checker (https://github.com/editorconfig-checker/editorconfig-checker)
--]]

return {

  -- Install dependencies
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'editorconfig-checker' }) end,
  },

  -- Configure linter
  {
    'mfussenegger/nvim-lint',
    opts = {
      linters_by_ft = {
        editorconfig = { 'editorconfig-checker' },
      },
      linters = {
        ['editorconfig-checker'] = {},
      },
    },
  },
}
