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
    opts = {
      mode = 'popup',
    },
    keys = {
      { '<leader>cH', '<cmd>HurlRunner<cr>', ft = 'hurl', desc = 'Run Hurl file' },
      { '<leader>ch', '<cmd>HurlRunnerAt<cr>', ft = 'hurl', desc = 'Send selected request' },
    },
  },
}
