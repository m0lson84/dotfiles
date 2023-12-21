--[[
Core LazyVim keymaps
--]]

local util = require('lazyvim.util')

--- Open LazyGit in a terminal window.
---@param cwd string|nil The current working directory.
local lazygit = function(cwd)
  util.terminal({ 'lazygit' }, { cwd = cwd, border = 'none', esc_esc = false, ctrl_hjkl = false })
end

--- Switch to terminal tab if running in Zellij else open lazyterm.
local terminal = function()
  if vim.env.ZELLIJ ~= nil then
    vim.fn.system({ 'zellij', 'action', 'go-to-tab-name', 'terminal', '--create' })
    vim.fn.system({ 'zellij', 'action', 'switch-mode', 'normal' })
    return
  end
  util.terminal()
end

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- yank/put
vim.keymap.set('x', '<leader>p', '"_dP', { desc = 'Paste over selection' })

-- LazyGit
vim.keymap.set('n', '<leader>gg', function() lazygit(util.root()) end, { desc = 'Lazygit (root dir)' })
vim.keymap.set('n', '<leader>gG', function() lazygit(nil) end, { desc = 'Lazygit (cwd)' })

-- Terminal
vim.keymap.set('n', '<c-/>', function() terminal() end, { desc = 'Open terminal' })
vim.keymap.set('n', '<c-_>', function() terminal() end, { desc = 'which_key_ignore' })
