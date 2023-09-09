--[[
Configure the font used in WezTerm.
--]]

local terminal = require('wezterm')

local M = {}

--- Configure the font used in the terminal.
-- @param config The configuration table to modify.
-- @param os The operating system the terminal is running in.
M.apply = function(config, os)
  config.font_size = os == 'windows' and 9.0 or 13.0
  config.font = terminal.font_with_fallback({
    { family = 'JetBrains Mono' },
    { family = 'Symbols Nerd Font Mono', scale = 0.8 },
  })
end

return M
