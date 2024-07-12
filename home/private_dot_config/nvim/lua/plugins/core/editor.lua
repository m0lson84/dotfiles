--[[
Core editor configuration
--]]

return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          never_show = {
            '__pycache__',
            '.DS_Store',
            'thumbs.db',
          },
        },
      },
    },
  },
  {
    'folke/which-key.nvim',
    opts = {
      preset = 'modern',
      show_help = false,
      spec = {
        { '<leader>h', group = 'http', icon = { icon = '', color = 'red' } },
      },
      win = {
        title = false,
      },
      layout = {
        align = 'center',
      },
    },
  },
}
