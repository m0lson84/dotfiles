--[[
markdownlint (https://github.com/DavidAnson/markdownlint)
--]]

-- Linter configuration
local config = {
  args = {},
  extra_args = { '--config', '~/.config/nvim/markdownlint.json' },
}

return {

  -- Install dependencies
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'markdownlint' }) end,
  },

  -- Configure linter
  {
    'mfussenegger/nvim-lint',
    opts = {
      linters = {
        markdownlint = { args = vim.tbl_flatten({ config.args, config.extra_args }) },
      },
    },
  },
}
