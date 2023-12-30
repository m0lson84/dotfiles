--[[
  Configuration utility functions.
  @module Configuration
  @alias config
--]]

local directory = require('util.directory')

local M = {}

--- Get the path to the Neovim (Vim) configuration directory (if exists).
---@param cwd string|nil The current working directory. Defaults to the current working directory
---@return string|nil
M.vim_dir = function(cwd) return directory.find('.vim', cwd or vim.loop.cwd()) end

--- Get the path to the VS Code configuration directory (if exists).
---@param cwd string|nil The current working directory. Defaults to the current working directory
---@return string|nil
M.vscode_dir = function(cwd) return directory.find('.vscode', cwd or vim.loop.cwd()) end

return M
