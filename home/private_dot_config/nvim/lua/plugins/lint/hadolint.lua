--[[
hadolint (https://github.com/hadolint/hadolint)
--]]

return {
  {
    'mfussenegger/nvim-lint',
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'hadolint' }) end,
      },
    },
    opts = {
      linters = {
        hadolint = {},
      },
    },
  },
}
