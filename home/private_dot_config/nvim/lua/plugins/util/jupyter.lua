--[[
-- Plugins for interfacing with Jupyter Notebooks
--]]

return {
  {
    'GCBallesteros/jupytext.nvim',
    opts = { style = 'hydrogen' },
  },
  {
    'benlubas/molten-nvim',
    build = ':UpdateRemotePlugins',
    init = function() end,
  },
}
