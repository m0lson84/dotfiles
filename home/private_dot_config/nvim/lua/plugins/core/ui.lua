return {
  { 'MaximilianLloyd/ascii.nvim', dependencies = { 'MunifTanjim/nui.nvim' } },
  {
    'goolord/alpha-nvim',
    dependencies = { 'MaximilianLloyd/ascii.nvim' },
    opts = {
      section = {
        header = {
          type = 'text',
          val = function() return require('ascii').get_random('text', 'neovim') end,
          opts = { hl = 'Type', shrink_margin = false },
        },
      },
    },
  },
}
