--[[
Core LazyVim keymaps
--]]

local util = require('lazyvim.util')

--- Open LazyGit in a terminal window.
---@param cwd string|nil The current working directory.
local lazygit = function(cwd)
  util.terminal({ 'lazygit' }, { cwd = cwd, border = 'none', esc_esc = false, ctrl_hjkl = false })
end

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- LazyGit
vim.keymap.set('n', '<leader>gg', function() lazygit(util.root()) end, { desc = 'Lazygit (root dir)' })
vim.keymap.set('n', '<leader>gG', function() lazygit(nil) end, { desc = 'Lazygit (cwd)' })
