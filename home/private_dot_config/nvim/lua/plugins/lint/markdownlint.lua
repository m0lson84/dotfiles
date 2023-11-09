--[[
markdownlint (https://github.com/DavidAnson/markdownlint)
--]]

return {
  {
    'mfussenegger/nvim-lint',
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'markdownlint' }) end,
      },
    },
    opts = {
      linters = {
        markdownlint = {
          args = { '--config', '~/.config/nvim/markdownlint.json' },
        },
      },
    },
  },
}
