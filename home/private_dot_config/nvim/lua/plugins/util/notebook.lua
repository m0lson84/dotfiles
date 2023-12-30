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
    config = function(_, opts) require('iron.core').setup(opts) end,
    opts = function()
      local iron = require('iron')
      return {
        highlight = { italic = true },
        ignore_blank_lines = true,
        config = {
          scratch_repl = true,
          repl_definition = {
            javascript = iron.fts.javascript.node,
            lua = iron.fts.lua.lua,
            python = iron.fts.python.ipython,
            typescript = iron.fts.typescript.ts,
            sh = iron.fts.sh.zsh,
          },
          repl_open_cmd = iron.view.right('40%'),
        },
        keymaps = {
          interupt = '<space>jk',
          exit = '<space>jq',
        },
      }
    end,
    keys = {
      { '<leader>jo', ':IronReplHere', desc = 'Open REPL' },
      { '<leader>jr', ':IronRestart', desc = 'Restart REPL' },
      { '<leader>je', function() util.notebook.execute_cell() end, desc = 'Execute cell' },
      { '<leader>jc', function() util.notebook.insert_cell('# %%') end, desc = 'Insert code cell' },
      { '<leader>jm', function() util.notebook.insert_cell('# %% [markdown]') end, desc = 'Insert markdown cell' },
    },
  },
  {
    'folke/which-key.nvim',
    opts = function(_, opts) opts.defaults['<leader>j'] = { name = '+jupyter' } end,
  },
}
