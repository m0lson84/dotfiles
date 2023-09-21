--[[
Black (https://github.com/psf/black)
--]]

-- Additional configuration
local config = {
  extra_args = { '--line-length', '120' },
}

return {
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'black' }) end,
  },
  {
    'nvimtools/none-ls.nvim',
    opts = function(_, opts)
      vim.list_extend(opts.sources, {
        require('null-ls').builtins.formatting.black.with(config),
      })
    end,
  },
}
