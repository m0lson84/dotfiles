--[[
StyLua (https://github.com/JohnnyMorganz/StyLua)
--]]

return {
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'stylua' }) end,
  },
  {
    'nvimtools/none-ls.nvim',
    opts = function(_, opts)
      vim.list_extend(opts.sources, {
        require('null-ls').builtins.formatting.stylua,
      })
    end,
  },
}
