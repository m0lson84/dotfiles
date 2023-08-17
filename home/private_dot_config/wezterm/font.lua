--[[
Helper functions for configuring the font used in wezterm.
--]]

local terminal = require("wezterm")

local M = {}

--- Configure the font used in the terminal.
-- @param config The configuration table to modify.
-- @param os The operating system the terminal is running in.
M.apply = function(config, os)
  config.font = terminal.font({ family = "JetBrains Mono" })
  config.font_size = os == "windows" and 10.0 or 13.0
end

return M
