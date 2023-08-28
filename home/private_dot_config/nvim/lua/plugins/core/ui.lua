--[[
Core UI configuration
--]]

return {
  {
    'akinsho/bufferline.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = function()
      local bufferline = require('bufferline')
      return {
        options = {
          groups = { items = { bufferline.groups.builtin.pinned:with({ icon = '' }) } },
          hover = { enabled = true, delay = 100, reveal = { 'close' } },
          always_show_bufferline = false,
          sort_by = 'relative_directory',
          buffer_close_icon = '󰖭',
        },
      }
    end,
  },
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
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    opts = function()
      local icons = require('lazyvim.config').icons
      local util = require('lazyvim.util')

      return {
        options = {
          theme = 'auto',
          globalstatus = true,
          disabled_filetypes = { statusline = { 'dashboard', 'alpha' } },
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch' },
          lualine_c = {
            {
              'diagnostics',
              symbols = {
                error = icons.diagnostics.Error,
                warn = icons.diagnostics.Warn,
                info = icons.diagnostics.Info,
                hint = icons.diagnostics.Hint,
              },
            },
          },
          lualine_x = {
            {
              function() return '  ' .. require('dap').status() end,
              cond = function() return package.loaded['dap'] and require('dap').status() ~= '' end,
              color = util.fg('Debug'),
            },
            { require('lazy.status').updates, cond = require('lazy.status').has_updates, color = util.fg('Special') },
            {
              'diff',
              symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
            },
          },
          lualine_y = {
            { 'progress', separator = ' ', padding = { left = 1, right = 0 } },
            { 'location', padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            function() return ' ' .. os.date('%R') end,
          },
        },
        extensions = { 'neo-tree', 'lazy' },
      }
    end,
  },
}
