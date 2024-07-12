--[[
-- iron.nvim (https://github.com/Vigemus/iron.nvim)
--]]

---Clear output of the current REPL.
local clear = function() require('iron.core').send(nil, string.char(12)) end

---Exit the current REPL.
local exit = function() require('iron.core').close_repl() end

---Interrupt execution of the current REPL.
local interrupt = function() require('iron.core').send(nil, string.char(03)) end

---Send enter to the current REPL.
local send_enter = function() require('iron.core').send(nil, string.char(13)) end

return {
  {
    'Vigemus/iron.nvim',
    main = 'iron.core',
    opts = function()
      return {
        highlight = { italic = true },
        ignore_blank_lines = true,
        config = {
          scratch_repl = true,
          repl_definition = {
            javascript = require('iron.fts.javascript').node,
            python = require('iron.fts.python').ipython,
            sh = require('iron.fts.sh').zsh,
            typescript = require('iron.fts.typescript').ts,
          },
          repl_open_cmd = require('iron.view').split.right('40%'),
        },
      }
    end,
    keys = {
      { '<leader>io', '<cmd>IronReplHere<cr>', desc = 'Open new REPL' },
      { '<leader>i<cr>', send_enter, desc = 'Send enter' },
      { '<leader>i<space>', interrupt, desc = 'Interrupt execution' },
      { '<leader>ir', '<cmd>IronRestart<cr>', desc = 'Restart REPL' },
      { '<leader>ic', clear, desc = 'Clear REPL' },
      { '<leader>iq', exit, desc = 'Quit REPL' },
    },
  },
  {
    'folke/edgy.nvim',
    opts = function(_, opts)
      opts.right = vim.list_extend(opts.right or {}, {
        { title = 'REPL', ft = 'iron.nvim', size = { width = 0.4 } },
      })
    end,
  },
  {
    'folke/which-key.nvim',
    opts = {
      spec = {
        { '<leader>i', group = 'repl', icon = { icon = '', color = 'green' } },
      },
    },
  },
}
