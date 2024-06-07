--[[
Core formatting configuration
--]]

return {
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters = {}
      opts.formatters_by_ft = {}
      opts.log_level = vim.log.levels.DEBUG
    end,
  },
}
