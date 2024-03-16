--[[
Core UI configuration
--]]

return {
  {
    'akinsho/bufferline.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = function(_, opts)
      local bufferline = require('bufferline')
      opts.options = require('util').table.merge(opts.options, {
        groups = { items = { bufferline.groups.builtin.pinned:with({ icon = '' }) } },
        hover = { enabled = true, delay = 100, reveal = { 'close' } },
        always_show_bufferline = false,
        sort_by = 'relative_directory',
        buffer_close_icon = '󰖭',
      })
      return opts
    end,
  },
  {
    'nvimdev/dashboard-nvim',
    dependencies = { 'MaximilianLloyd/ascii.nvim' },
    opts = function(_, opts)
      local logo = table.concat(require('ascii').get_random('text', 'neovim'), '\n')
      opts.config.header = vim.split(string.rep('\n', 8) .. logo .. '\n\n', '\n')
    end,
  },
  {
    'folke/noice.nvim',
    opts = function(_, opts) opts.presets.lsp_doc_border = true end,
  },
  {
    'nvim-tree/nvim-web-devicons',
    lazy = true,
    opts = {
      override_by_filename = {
        -- TODO: Remove once symbols-only nerd font update is released
        -- https://github.com/ryanoasis/nerd-fonts/commit/a4ccb3b6feb0bd42b858164b8e21723e27311b01
        ['.prettierrc'] = {},
      },
    },
  },
}
