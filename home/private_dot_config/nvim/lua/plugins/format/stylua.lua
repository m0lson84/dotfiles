--[[
StyLua (https://github.com/JohnnyMorganz/StyLua)
--]]

return {
  {
    'stevearc/conform.nvim',
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'stylua' }) end,
      },
    },
    opts = {},
  },
}
