--[[
Neovim plugin configuration
--]]

---Local utility functions
_G.util = require('util')

return {
  require('plugins.core'),
  require('plugins.coding'),
  require('plugins.editor'),
  require('plugins.format'),
  require('plugins.lang'),
  require('plugins.lint'),
  require('plugins.ui'),
  require('plugins.util'),
}
