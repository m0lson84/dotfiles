--[[
shfmt (https://github.com/patrickvane/shfmt)
--]]

-- Additional configuration.
local config = {
  extra_args = { '-i', '2', '-ci' },
}

return {
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'shfmt' }) end,
  },
  {
    'nvimtools/none-ls.nvim',
    opts = function(_, opts)
      vim.list_extend(opts.sources, {
        require('null-ls').builtins.formatting.shfmt.with(config),
      })
    end,
  },
}
