return {
  {
    'goolord/alpha-nvim',
    dependencies = {
      'MaximilianLloyd/ascii.nvim',
      dependencies = { 'MunifTanjim/nui.nvim' },
    },
    opts = {
      section = {
        header = {
          type = 'text',
          val = function()
            if vim.g.alpha_header ~= nil then return vim.g.alpha_header end
            vim.g.alpha_header = require('ascii').get_random('text', 'neovim')
            return vim.g.alpha_header
          end,
          opts = { hl = 'Type', shrink_margin = false },
        },
      },
    },
  },
}
