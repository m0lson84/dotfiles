--[[
Handling of events in WezTerm.
--]]

local wezterm = require('wezterm') --[[@as Wezterm]]

-- Set window title
wezterm.on('format-window-title', function(_, _, _, _, _) return 'Terminal' end)
