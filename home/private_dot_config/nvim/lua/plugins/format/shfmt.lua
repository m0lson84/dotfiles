--[[
shfmt (https://github.com/patrickvane/shfmt)
--]]

local config = {
  extra_args = { '-i', '2', '-ci' },
}

return {
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) table.insert(opts.ensure_installed, 'shfmt') end,
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    opts = function(_, opts)
      local nls = require('null-ls')
      table.insert(opts.sources, nls.builtins.formatting.shfmt.with(config))
    end,
  },
}
