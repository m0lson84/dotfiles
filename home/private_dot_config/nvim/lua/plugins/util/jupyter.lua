--[[
-- Plugins for interfacing with Jupyter Notebooks
--]]

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
}
