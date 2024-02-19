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
      { '<leader>ch', '<Plug>RestNvim', ft = 'http', desc = 'Execute HTTP request' },
    },
    config = function(_, opts) require('rest-nvim').setup(opts) end,
  },
  {
    'folke/edgy.nvim',
    opts = function(_, opts)
      opts.right = vim.list_extend(opts.right or {}, {
        { title = 'REST Client', ft = 'httpResult', size = { width = 0.4 } },
      })
    end,
  },
}
