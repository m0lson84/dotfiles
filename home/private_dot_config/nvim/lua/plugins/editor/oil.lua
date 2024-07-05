--[[
oil.nvim (https://github.com/stevearc/oil.nvim)
--]]

--- Toggle oil.nvim floating window with the current working directory.
local open_cwd = function() require('oil').toggle_float() end

--- Toggle oil.nvim floating window with the project root.
local open_root = function() require('oil').toggle_float(LazyVim.root()) end

return {
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      float = {
        preview_split = 'right',
      },
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name, _)
          local hidden = { '__pycache__', '.DS_Store', 'thumbs.db' }
          for _, item in ipairs(hidden) do
            if name == item then return true end
          end
          return false
        end,
      },
    },
    keys = {
      { '<leader>fo', open_cwd, desc = 'Explorer oil.nvim (root)' },
      { '<leader>fO', open_root, desc = 'Explorer oil.nvim (cwd)' },
    },
  },
}
