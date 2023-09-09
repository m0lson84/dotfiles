--[[
hardtime (https://github.com/m4xshen/hardtime.nvim)
--]]

return {
  {
    'm4xshen/hardtime.nvim',
    dependencies = { 'MunifTanjim/nui.nvim', 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>ch', '<cmd>Hardtime toggle<cr>', desc = 'Toggle Hardtime', mode = { 'n', 'v' } },
    },
    opts = {
      enabled = false,
      disabled_keys = {
        ['<Left>'] = {},
        ['<Right>'] = {},
        ['<Up>'] = {},
        ['<Down>'] = {},
      },
    },
  },
}
