local eslint = require('plugins.lint.eslint')
local markdownlint = require('plugins.lint.markdownlint')
local ruff = require('plugins.lint.ruff')

local M = {}

return {
  M,
  eslint,
  markdownlint,
  ruff,
}
