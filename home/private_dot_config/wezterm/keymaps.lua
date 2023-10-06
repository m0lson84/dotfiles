--[[
Configure the keybinds used in WezTerm.
--]]

local terminal = require('wezterm')

local M = {}

--- Configure the keybinds used in the terminal.
-- @param config The configuration table to modify.
-- @param os The operating system the terminal is running in.
M.apply = function(config, os)
  config.disable_default_key_bindings = false
  config.keys = {
    { mods = 'SUPER|SHIFT', key = 'p', action = terminal.action.ShowLauncher },
    { mods = 'CTRL|SHIFT', key = 'p', action = terminal.action.ShowLauncher },
    { mods = 'SUPER', key = 'w', action = terminal.action.CloseCurrentTab({ confirm = false }) },
    { mods = 'CTRL|SHIFT', key = 'w', action = terminal.action.CloseCurrentTab({ confirm = false }) },
  }
end

return M
