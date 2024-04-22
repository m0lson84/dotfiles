--[[
Additional formatter plugins
--]]

return {
  require('plugins.format.black'),
  require('plugins.format.gofumpt'),
  require('plugins.format.goimports'),
  require('plugins.format.prettier'),
  require('plugins.format.shfmt'),
  require('plugins.format.stylua'),
  require('plugins.format.taplo'),
}
