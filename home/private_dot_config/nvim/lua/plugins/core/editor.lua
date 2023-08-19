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
    'L3MON4D3/LuaSnip',
    keys = function() return {} end,
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = { 'hrsh7th/cmp-emoji' },
    opts = function(_, opts)
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      local util = require('util')

      opts.preselect = cmp.PreselectMode.None
      opts.completion = { completeopt = 'noselect' }
      opts.mapping = vim.tbl_extend('force', opts.mapping, {
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          elseif util.has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }),
      })
    end,
  },
}
