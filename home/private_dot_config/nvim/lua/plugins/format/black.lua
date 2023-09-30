--[[
Black (https://github.com/psf/black)
--]]

-- Formatter configuration
local config = {
  args = { '--stdin-filename', '$FILENAME', '--quiet', '-' },
  extra_args = { '--line-length', '120' },
}

return {

  -- Install dependencies
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'black' }) end,
  },

  -- Configure formatter
  {
    'stevearc/conform.nvim',
    opts = {
      formatters = {
        black = { args = vim.tbl_flatten({ config.args, config.extra_args }) },
      },
    },
  },
}
