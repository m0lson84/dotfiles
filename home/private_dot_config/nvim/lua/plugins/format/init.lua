local black = require('plugins.format.black')
local isort = require('plugins.format.isort')
local prettier = require('plugins.format.prettier')

local M = {}

return {
  M,
  black,
  isort,
  prettier,
}
