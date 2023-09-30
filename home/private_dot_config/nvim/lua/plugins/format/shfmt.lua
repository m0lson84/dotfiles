--[[
shfmt (https://github.com/patrickvane/shfmt)
--]]

-- Formatter configuration
local config = {
  args = { '-filename', '$FILENAME' },
  extra_args = { '-i', '2', '-ci' },
}

return {

  -- Install dependencies
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'shfmt' }) end,
  },

  -- Configure formatters
  {
    'stevearc/conform.nvim',
    opts = {
      formatters = {
        shfmt = { args = vim.tbl_flatten({ config.args, config.extra_args }) },
      },
    },
  },
}
