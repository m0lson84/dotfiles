--[[
edgy.nvim (https://github.com/folke/edgy.nvim)
--]]

return {
  {
    'folke/edgy.nvim',
    opts = function()
      local opts = {
        bottom = {
          'Trouble',
          {
            title = 'Terminal',
            ft = 'lazyterm',
            size = { height = 0.2 },
            filter = function(buf) return not vim.b[buf].lazyterm_cmd end,
          },
          {
            title = 'Notifications',
            ft = 'noice',
            size = { height = 0.2 },
            filter = function(_, win) return vim.api.nvim_win_get_config(win).relative == '' end,
          },
          {
            title = 'Help',
            ft = 'help',
            size = { height = 0.2 },
            filter = function(buf) return vim.bo[buf].buftype == 'help' end,
          },
          {
            title = 'Test Output',
            ft = 'neotest-output-panel',
            size = { height = 15 },
          },
        },
        left = {
          {
            title = 'Explorer',
            ft = 'neo-tree',
            filter = function(buf) return vim.b[buf].neo_tree_source == 'filesystem' end,
            open = function() vim.api.nvim_input('<esc><space>e') end,
            pinned = true,
            size = { height = 0.5, width = 0.2 },
          },
          {
            title = 'Git',
            ft = 'neo-tree',
            filter = function(buf) return vim.b[buf].neo_tree_source == 'git_status' end,
            open = 'Neotree position=right git_status',
            pinned = true,
          },
          {
            title = 'Buffers',
            ft = 'neo-tree',
            filter = function(buf) return vim.b[buf].neo_tree_source == 'buffers' end,
            open = 'Neotree position=top buffers',
            pinned = true,
          },
          {
            title = 'Test Summary',
            ft = 'neotest-summary',
          },
          'neo-tree',
        },
        keys = {
          ['<c-Right>'] = function(win) win:resize('width', 2) end,
          ['<c-Left>'] = function(win) win:resize('width', -2) end,
          ['<c-Up>'] = function(win) win:resize('height', 2) end,
          ['<c-Down>'] = function(win) win:resize('height', -2) end,
        },
      }
      local util = require('lazyvim.util')
      if util.has('symbols-outline.nvim') then
        table.insert(opts.left, {
          title = 'Outline',
          ft = 'Outline',
          pinned = true,
          open = 'SymbolsOutline',
        })
      end
      return opts
    end,
  },
}
