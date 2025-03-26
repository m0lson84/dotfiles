--[[
Configure the font used in WezTerm.
--]]

local util = require('util')
local wezterm = require('wezterm') --[[@as Wezterm]]

local M = {}

--- Configure the font used in the terminal.
---@param config table The terminal configuration to modify.
M.apply = function(config)
  config.font_size = util.get_target().platform == 'darwin' and 12.0 or 9.0
  config.font = wezterm.font_with_fallback({
    { family = 'JetBrains Mono' },
    { family = 'Symbols Nerd Font Mono', scale = 0.8 },
  })
end

return M
