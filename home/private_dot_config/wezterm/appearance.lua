--[[
Configure the appearance of WezTerm.
--]]

local M = {}

--- Configure the terminal appearance.
-- @param config The configuration table to modify.
M.apply = function(config)
  config.color_scheme = 'Dark+'
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
