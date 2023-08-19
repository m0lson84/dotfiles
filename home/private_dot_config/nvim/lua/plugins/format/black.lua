--[[
Black (https://github.com/psf/black)
--]]

local config = {
  extra_args = { '--line-length', '120' },
}

return {
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) table.insert(opts.ensure_installed, 'black') end,
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    opts = function(_, opts)
      local nls = require('null-ls')
      table.insert(opts.sources, nls.builtins.formatting.black.with(config))
    end,
  },
}
