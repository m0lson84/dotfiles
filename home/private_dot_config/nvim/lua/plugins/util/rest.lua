--[[
-- rest.nvim (https://github.com/rest-nvim/rest.nvim)
--]]

return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'http' }) end,
  },
  {
    'rest-nvim/rest.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    ft = 'http',
    opts = {
      stay_in_current_window_after_split = true,
    },
    keys = {
      { '<leader>ch', '<Plug>RestNvim', desc = 'Execute HTTP request' },
    },
  },
}
