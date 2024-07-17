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
    'echasnovski/mini.icons',
    opts = {
      extension = {
        ['code-workspace'] = { glyph = '󰨞', hl = 'MiniIconsBlue' },
        kdl = { glyph = '', hl = 'MiniIconsYellow' },
        ['kdl.tmpl'] = { glyph = '', hl = 'MiniIconsGrey' },
        ['ps1.tmpl'] = { glyph = '󰨊', hl = 'MiniIconsGrey' },
      },
      file = {
        ['.chezmoiroot'] = { glyph = '', hl = 'MiniIconsGrey' },
        ['.chezmoiversion'] = { glyph = '', hl = 'MiniIconsGrey' },
      },
      filetype = {
        curl = { glyph = '', hl = 'MiniIconsRed' },
        http = { glyph = '', hl = 'MiniIconsRed' },
      },
    },
  },
  {
    'folke/noice.nvim',
    opts = function(_, opts) opts.presets.lsp_doc_border = true end,
  },
  {
    'nvimdev/dashboard-nvim',
    dependencies = { 'MaximilianLloyd/ascii.nvim' },
    opts = function(_, opts)
      local logo = table.concat(require('ascii').get_random('text', 'neovim'), '\n')
      opts.config.header = vim.split(string.rep('\n', 8) .. logo .. '\n\n', '\n')
    end,
  },
}
