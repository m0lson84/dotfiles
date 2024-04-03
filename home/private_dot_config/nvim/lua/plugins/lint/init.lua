--[[
Additional linter plugins
--]]

return {
  require('plugins.lint.cspell'),
  require('plugins.lint.eslint'),
  require('plugins.lint.hadolint'),
  require('plugins.lint.markdownlint'),
  require('plugins.lint.ruff'),
}
