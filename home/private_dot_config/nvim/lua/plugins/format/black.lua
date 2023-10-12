--[[
Black (https://github.com/psf/black)
--]]

local config = {
  extra_args = { '--line-length', '120' },
}

return {
  {
    'stevearc/conform.nvim',
    depends = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'black' }) end,
      },
    },
    opts = {
      formatters = {
        black = { extra_args = config.extra_args },
      },
    },
  },
}
