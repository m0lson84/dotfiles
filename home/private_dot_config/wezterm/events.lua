--[[
Handling of events in WezTerm.
--]]

local terminal = require('wezterm')

-- Set window title
terminal.on('format-window-title', function(_, _, _, _, _) return 'Terminal' end)
