local docker = require('plugins.lang.docker')
local go = require('plugins.lang.go')
local json = require('plugins.lang.json')
local python = require('plugins.lang.python')
local rust = require('plugins.lang.rust')
local typescript = require('plugins.lang.typescript')
local yaml = require('plugins.lang.yaml')

local M = {
  {
    'folke/neoconf.nvim',
    config = {
      local_settings = '.vim/neoconf.json',
    },
  },
}

return { M, docker, go, json, python, rust, typescript, yaml }
