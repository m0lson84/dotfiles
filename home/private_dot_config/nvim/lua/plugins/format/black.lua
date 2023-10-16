--[[
Black (https://github.com/psf/black)
--]]

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
        black = { prepend_args = { '--line-length', '120' } },
      },
    },
  },
}
