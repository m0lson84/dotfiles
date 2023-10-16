--[[
shfmt (https://github.com/patrickvane/shfmt)
--]]

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
        shfmt = { prepend_args = { '-i', '2', '-ci' } },
      },
    },
  },
}
