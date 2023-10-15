--[[
Additional language server protocol (LSP) plugins
--]]

return {
  require('plugins.lang.bash'),
  require('plugins.lang.go'),
  require('plugins.lang.json'),
  require('plugins.lang.lua'),
  require('plugins.lang.markdown'),
  require('plugins.lang.python'),
  require('plugins.lang.rust'),
  require('plugins.lang.typescript'),
  require('plugins.lang.yaml'),
}
