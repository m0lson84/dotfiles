--[[
Lua language support
--]]

return {
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
}
