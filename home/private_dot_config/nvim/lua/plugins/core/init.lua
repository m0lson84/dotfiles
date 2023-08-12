local coding = require('plugins.core.coding')
local colorscheme = require('plugins.core.colorscheme')
local editor = require('plugins.core.editor')
local lsp = require('plugins.core.lsp')
local treesitter = require('plugins.core.treesitter')
local ui = require('plugins.core.ui')

local M = {}

return {
  M,
  coding,
  colorscheme,
  editor,
  lsp,
  treesitter,
  ui,
}
