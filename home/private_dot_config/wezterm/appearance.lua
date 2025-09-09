--[[
Configure the appearance of WezTerm.
--]]

local wezterm = require('wezterm') --[[@as Wezterm]]

-- Customize built-in color schemes.
local color_schemes = wezterm.get_builtin_color_schemes()
color_schemes['Tokyo Night'].background = '#16161E'

local M = {}

--- Configure the appearance of the terminal.
---@param config table The terminal configuration to modify.
M.apply = function(config)
  config.color_scheme = 'Tokyo Night'
  config.color_schemes = color_schemes
  config.window_padding = {
    left = '6px',
    right = '6px',
    top = '6px',
    bottom = '6px',
  }
end

return M
