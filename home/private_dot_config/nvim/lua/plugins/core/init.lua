local colorscheme = require('plugins.core.colorscheme')
local editor = require('plugins.core.editor')
local lsp = require('plugins.core.lsp')
local treesitter = require('plugins.core.treesitter')
local ui = require('plugins.core.ui')

local M = {}

return {
  M,
  colorscheme,
  editor,
  lsp,
  treesitter,
  ui,
}
