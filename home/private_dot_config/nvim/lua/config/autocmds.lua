--[[
Core LazyVim auto commands
--]]

-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

--- Create a new autocmd group
---@param name string The name of the group to create
local function create_group(name) return vim.api.nvim_create_augroup('local_' .. name, { clear = true }) end

-- Quit Zellij when quitting Neovim
vim.api.nvim_create_autocmd({ 'VimLeave' }, {
  group = create_group('quit_zellij'),
  pattern = '*',
  callback = function() os.execute('zellij k "$ZELLIJ_SESSION_NAME"') end,
})

-- Configure language ruler
vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = create_group('language_ruler'),
  callback = function() vim.wo.colorcolumn = vim.bo.textwidth and '+1' or '' end,
})
