--[[
Neogen (https://github.com/danymat/neogen)
--]]

return {
  {
    'danymat/neogen',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    keys = { { '<leader>cg', '<cmd>Neogen<cr>', desc = 'Generate Docs' } },
    opts = {
      languages = {},
      snippet_engine = 'luasnip',
    },
  },
}
