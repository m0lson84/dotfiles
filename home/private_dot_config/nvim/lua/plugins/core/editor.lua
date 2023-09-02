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
}
