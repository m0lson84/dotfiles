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
        ft = { 'bash', 'cs', 'go', 'javascript', 'lua', 'python', 'rust', 'sh', 'typescript', 'zsh' },
        desc = 'Generate Docs',
      },
    },
    opts = {
      languages = {},
    },
  },
}
