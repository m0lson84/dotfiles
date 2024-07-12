--[[
-- Plugins for interfacing with Jupyter Notebooks
--]]

return {
  {
    'goerz/jupytext.vim',
    build = 'pip install -U jupytext',
    event = 'VeryLazy',
    dependencies = { 'neovim/nvim-lspconfig', 'Vigemus/iron.nvim' },
    opts = { output_format = 'py:percent' },
    keys = {
      { '<leader>je', function() util.notebook.execute_cell() end, desc = 'Execute cell' },
      { '<leader>jc', function() util.notebook.insert_cell('# %%') end, desc = 'Insert code cell' },
      { '<leader>jm', function() util.notebook.insert_cell('# %% [markdown]') end, desc = 'Insert markdown cell' },
    },
    config = function(_, opts) vim.g.jupytext_fmt = opts.output_format end,
  },
  {
    'folke/which-key.nvim',
    opts = {
      spec = {
        { '<leader>j', group = 'jupyter', icon = { icon = '', color = 'orange' } },
      },
    },
  },
}
