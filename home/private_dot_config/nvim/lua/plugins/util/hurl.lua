--[[
-- hurl.nvim (https://github.com/jellydn/hurl.nvim)
--]]

return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'hurl' }) end,
  },
  {
    'jellydn/hurl.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    ft = 'hurl',
    keys = {
      { '<leader>ha', '<cmd>HurlRunner<cr>', ft = 'hurl', desc = 'Execute all requests' },
      { '<leader>he', '<cmd>HurlRunnerAt<cr>', ft = 'hurl', desc = 'Execute selected request' },
      { '<leader>hm', '<cmd>HurlManageVariable<cr>', ft = 'hurl', desc = 'Manage environment' },
    },
    opts = {
      debug = true,
      mode = 'popup',
    },
  },
}
