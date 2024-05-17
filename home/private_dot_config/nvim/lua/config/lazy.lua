--[[
Core LazyVim config
--]]

-- Import utility functions
local util = require('util')

-- Path to lazy.nvim installation
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

-- Check if lazy.nvim is installed
if not util.dir.exists(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end

-- Add lazy.nvim to runtime path
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

-- Setup lazy.nvim
require('lazy').setup({
  spec = {
    { 'LazyVim/LazyVim', import = 'lazyvim.plugins' },
    { import = 'lazyvim.plugins.extras.coding.copilot' },
    { import = 'lazyvim.plugins.extras.coding.mini-surround' },
    { import = 'lazyvim.plugins.extras.coding.yanky' },
    { import = 'lazyvim.plugins.extras.dap.core' },
    { import = 'lazyvim.plugins.extras.editor.trouble-v3' },
    { import = 'lazyvim.plugins.extras.lazyrc' },
    { import = 'lazyvim.plugins.extras.test.core' },
    { import = 'lazyvim.plugins.extras.ui.edgy' },
    { import = 'lazyvim.plugins.extras.ui.mini-indentscope' },
    { import = 'lazyvim.plugins.extras.ui.treesitter-context' },
    { import = 'lazyvim.plugins.extras.util.mini-hipatterns' },
    { import = 'plugins' },
  },
  defaults = { lazy = false, version = false },
  install = { colorscheme = { 'tokyonight', 'habamax' } },
  checker = { enabled = true },
  ui = { title = ' lazy.nvim ', border = 'rounded' },
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
})
