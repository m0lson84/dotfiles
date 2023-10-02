--[[
shfmt (https://github.com/patrickvane/shfmt)
--]]

local config = {
  args = { '-filename', '$FILENAME' },
  extra_args = { '-i', '2', '-ci' },
}

return {
  {
    'stevearc/conform.nvim',
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'shfmt' }) end,
      },
    },
    opts = {
      formatters = {
        shfmt = { args = vim.tbl_flatten({ config.args, config.extra_args }) },
      },
    },
  },
}
