--[[
-- Core LazyVim options
--]]

-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

--[[
-- Environment
--]]

-- vim.env.PATH = vim.env.HOME .. '/.local/share/mise/shims:' .. vim.env.PATH

--[[
-- Global variables
--]]

-- Set leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- System clipboard provider
if vim.env.WSLENV then
  vim.g.clipboard = {
    name = 'WSL Clipboard',
    copy = {
      ['+'] = 'win32yank.exe -i --crlf',
      ['*'] = 'win32yank.exe -i --crlf',
    },
    paste = {
      ['+'] = 'win32yank.exe -o --lf',
      ['*'] = 'win32yank.exe -o --lf',
    },
    cache_enabled = false,
  }
end

-- LazyVim
vim.g.deprecation_warnings = true
vim.g.lazyvim_picker = 'fzf'

-- Providers
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.node_host_prog = vim.fn.expand('~/.local/share/mise/installs/node/lts/bin/neovim-node-host')
vim.g.python3_host_prog = vim.fn.expand('~/.local/share/mise/installs/python/3.12/bin/python')

-- UI
vim.g.window_border = 'rounded'

--[[
-- Local options
--]]

local opt = vim.opt

-- Code folding options
opt.foldcolumn = '1'
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

-- Formatter options
opt.formatexpr = 'v:lua.require\'conform\'.formatexpr()'

--[[
-- File types
--]]

vim.filetype.add({
  extension = {
    ['code-workspace'] = 'jsonc',
    conf = 'conf',
    env = 'dotenv',
    http = 'http',
    rest = 'http',
    tmpl = 'gotmpl',
  },
  filename = {
    ['.env'] = 'dotenv',
    ['devcontainer.json'] = 'jsonc',
    ['docker-compose.yml'] = 'yaml.docker-compose',
    ['docker-compose.yaml'] = 'yaml.docker-compose',
  },
  pattern = {
    ['%.env%.[%w_.-]+'] = 'dotenv',
  },
})

--[[
-- Zellij
--]]

if vim.env.ZELLIJ ~= nil then vim.fn.system({ 'zellij', 'action', 'switch-mode', 'locked' }) end
