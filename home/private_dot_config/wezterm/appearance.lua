--[[
Helper functions for configuring the appearance of wezterm.
--]]

local M = {}

--- Configure the terminal appearance.
-- @param config The configuration table to modify.
M.apply = function(config)
  config.color_scheme = 'Dark+'
  config.initial_rows = 40
  config.initial_cols = 120
  config.window_frame = {
    inactive_titlebar_bg = '#353535',
    active_titlebar_bg = '#2b2042',
    inactive_titlebar_fg = '#cccccc',
    active_titlebar_fg = '#ffffff',
    inactive_titlebar_border_bottom = '#2b2042',
    active_titlebar_border_bottom = '#2b2042',
    button_fg = '#cccccc',
    button_bg = '#2b2042',
    button_hover_fg = '#ffffff',
    button_hover_bg = '#3b3052',
  }
  config.window_padding = {
    left = '0.5cell',
    right = '0.5cell',
    top = '0.25cell',
    bottom = '0.25cell',
  }
end

return M
