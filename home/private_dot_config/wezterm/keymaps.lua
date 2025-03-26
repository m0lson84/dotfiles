--[[
Configure the keybinds used in WezTerm.
--]]

local wezterm = require('wezterm') --[[@as Wezterm]]

local M = {}

--- Configure the keybinds used in the terminal.
---@param config table The terminal configuration to modify.
M.apply = function(config)
  config.disable_default_key_bindings = false
  config.keys = {
    { mods = 'SUPER|SHIFT', key = 'p', action = wezterm.action.ShowLauncher },
    { mods = 'CTRL|SHIFT', key = 'p', action = wezterm.action.ShowLauncher },
    { mods = 'SUPER', key = 'w', action = wezterm.action.CloseCurrentTab({ confirm = false }) },
    { mods = 'CTRL|SHIFT', key = 'w', action = wezterm.action.CloseCurrentTab({ confirm = false }) },
  }
end

return M
