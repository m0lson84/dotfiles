--[[
Lua language support
--]]

-- Import utility functions
local util = require('util')

return {

  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        lua_ls = {
          keys = {
            { '<leader>cD', '<cmd>Neogen<cr>', desc = 'Generate Docs', mode = { 'n' } },
          },
        },
      },
    },
  },

  -- Configure formatters
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters_by_ft = util.formatter.set(opts.formatters_by_ft, { 'lua' }, { 'stylua' })
    end,
  },
}
