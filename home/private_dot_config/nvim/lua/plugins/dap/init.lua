--[[
Additional debug adapter protocol (DAP) plugins
--]]

return {
  { import = 'lazyvim.plugins.extras.dap.core' },
  require('plugins.dap.js-debug-adapter'),
}
