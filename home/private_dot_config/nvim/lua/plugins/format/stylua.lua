--[[
StyLua (https://github.com/JohnnyMorganz/StyLua)
--]]

return {
  {
    'stevearc/conform.nvim',
    dependencies = {
      { 'williamboman/mason.nvim', opts = { ensure_installed = { 'shfmt' } } },
    },
    opts = {},
  },
}
