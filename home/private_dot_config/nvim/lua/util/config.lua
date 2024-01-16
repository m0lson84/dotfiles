--[[
  Configuration utility functions.
  @module Configuration
  @alias config
--]]

local directory = require('util.directory')

local M = {}

--- Get the path to the IDE configuration directory for the given path.
---@param path string|nil Path to the directory to start searching in. Defaults to the current working directory.
---@return string|nil
M.dir = function(path) return M.vim(path) or M.vscode(path) end

--- Get the path to the Neovim (Vim) configuration directory (if exists).
---@param path string|nil Path to the directory to start searching in. Defaults to the current working directory.
---@return string|nil
M.vim = function(path) return directory.find('.vim', path or vim.loop.cwd()) end

--- Get the path to the VS Code configuration directory (if exists).
---@param path string|nil Path to the directory to start searching in. Defaults to the current working directory.
---@return string|nil
M.vscode = function(path) return directory.find('.vscode', path or vim.loop.cwd()) end

return M
