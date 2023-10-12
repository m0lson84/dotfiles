--[[
Additional linter plugins
--]]

return {
  require('plugins.lint.cspell'),
  require('plugins.lint.editorconfig'),
  require('plugins.lint.eslint'),
  require('plugins.lint.markdownlint'),
  require('plugins.lint.ruff'),
  require('plugins.lint.shellcheck'),
}
