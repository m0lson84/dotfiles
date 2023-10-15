--[[
Neogen (https://github.com/danymat/neogen)
--]]

return {
  {
    'danymat/neogen',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    keys = {
      {
        '<leader>cD',
        '<cmd>Neogen<cr>',
        ft = { 'bash', 'go', 'javascript', 'lua', 'python', 'rust', 'sh', 'typescript', 'zsh' },
        desc = 'Generate Docs',
      },
    },
    opts = {
      languages = {},
      snippet_engine = 'luasnip',
    },
  },
}
