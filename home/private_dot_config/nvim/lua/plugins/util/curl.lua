--[[
-- curl.nvim (https://github.com/oysandvik94/curl.nvim)
--]]

return {
  'oysandvik94/curl.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    { '<leader>hc', '<cmd>CurlOpen<cr>', desc = 'Open curl interface' },
    { '<leader>hC', '<cmd>CurlClose<cr>', desc = 'Clsoe curl interface' },
  },
  opts = {},
}
