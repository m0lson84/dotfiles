--[[
shfmt (https://github.com/patrickvane/shfmt)
--]]

return {
  {
    'stevearc/conform.nvim',
    dependencies = {
      { 'williamboman/mason.nvim', opts = { ensure_installed = { 'shfmt' } } },
    },
    opts = {
      formatters = {
        shfmt = { prepend_args = { '-i', '2', '-ci' } },
      },
    },
  },
}
