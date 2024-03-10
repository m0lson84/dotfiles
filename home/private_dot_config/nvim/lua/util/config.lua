--[[
  Configuration utility functions.
  @module Configuration
  @alias config
--]]

-- Import utility functions
local util = { dir = require('util.directory') }

local M = {}

--- Get the path to the IDE configuration directory for the given path.
---@param path string|nil Path to the directory to start searching in. Defaults to the current working directory.
---@return string|nil
M.dir = function(path) return M.vim(path) or M.vscode(path) end

--- Get the path to the Neovim (Vim) configuration directory (if exists).
---@param path string|nil Path to the directory to start searching in. Defaults to the current working directory.
---@return string|nil
M.vim = function(path) return util.dir.find('.vim', path or vim.fn.getcwd()) end

--- Get the path to the VS Code configuration directory (if exists).
---@param path string|nil Path to the directory to start searching in. Defaults to the current working directory.
---@return string|nil
M.vscode = function(path) return util.dir.find('.vscode', path or vim.fn.getcwd()) end

return M
