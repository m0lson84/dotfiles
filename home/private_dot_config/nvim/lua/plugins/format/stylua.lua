--[[
StyLua (https://github.com/JohnnyMorganz/StyLua)
--]]

return {

  -- Install dependencies
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'stylua' }) end,
  },

  -- Configure formatters
  {
    'stevearc/conform.nvim',
    opts = {},
  },
}
