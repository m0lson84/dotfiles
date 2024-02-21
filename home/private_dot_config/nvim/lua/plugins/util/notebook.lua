--[[
-- Plugins for interfacing with Jupyter Notebooks
--]]

local util = require('util')

return {
  {
    'goerz/jupytext.vim',
    build = 'pip install -U jupytext',
    event = 'VeryLazy',
    dependencies = { 'neovim/nvim-lspconfig' },
    opts = {
      output_format = 'py:percent',
    },
    config = function(_, opts) vim.g.jupytext_fmt = opts.output_format end,
  },
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
        keymaps = {
          interrupt = '<space>jk',
          exit = '<space>jq',
        },
      }
    end,
    keys = {
      { '<leader>jo', '<cmd>IronReplHere<cr>', desc = 'Open REPL' },
      { '<leader>jr', '<cmd>IronRestart<cr>', desc = 'Restart REPL' },
      { '<leader>je', function() util.notebook.execute_cell() end, desc = 'Execute cell' },
      { '<leader>jc', function() util.notebook.insert_cell('# %%') end, desc = 'Insert code cell' },
      { '<leader>jm', function() util.notebook.insert_cell('# %% [markdown]') end, desc = 'Insert markdown cell' },
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
    opts = function(_, opts) opts.defaults['<leader>j'] = { name = '+jupyter' } end,
  },
}
