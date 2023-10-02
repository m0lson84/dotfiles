--[[
markdownlint (https://github.com/DavidAnson/markdownlint)
--]]

local config = {
  args = {},
  extra_args = { '--config', '~/.config/nvim/markdownlint.json' },
}

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
        markdownlint = { args = vim.tbl_flatten({ config.args, config.extra_args }) },
      },
    },
  },
}
