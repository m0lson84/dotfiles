--[[
shfmt (https://github.com/patrickvane/shfmt)
--]]

local config = {
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
        shfmt = { extra_args = config.extra_args },
      },
    },
  },
}
