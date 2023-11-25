--[[
Configure the appearance of WezTerm.
--]]

local terminal = require('wezterm')

-- Customize built-in color schemes.
local color_schemes = terminal.get_builtin_color_schemes()
color_schemes['Tokyo Night'].background = '#16161E'

local M = {}

--- Configure the appearance of the terminal.
---@param config table The terminal configuration to modify.
M.apply = function(config)
  config.color_scheme = 'Tokyo Night'
  config.color_schemes = color_schemes
  config.initial_rows = 40
  config.initial_cols = 120
  config.window_padding = {
    left = '0.5cell',
    right = '0.5cell',
    top = '0.25cell',
    bottom = '0.25cell',
  }
end

return M
