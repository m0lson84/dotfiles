--[[
editorconfig-checker (https://github.com/editorconfig-checker/editorconfig-checker)
--]]

return {
  {
    'mfussenegger/nvim-lint',
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'editorconfig-checker' }) end,
      },
    },
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
