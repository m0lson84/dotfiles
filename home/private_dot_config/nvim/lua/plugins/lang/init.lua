--[[
Additional language server protocol (LSP) plugins
--]]

return {
  { import = 'lazyvim.plugins.extras.lang.docker' },
  { import = 'lazyvim.plugins.extras.lang.json' },
  { import = 'lazyvim.plugins.extras.lang.yaml' },
  require('plugins.lang.bash'),
  require('plugins.lang.go'),
  require('plugins.lang.markdown'),
  require('plugins.lang.python'),
  require('plugins.lang.rust'),
  require('plugins.lang.typescript'),
}
