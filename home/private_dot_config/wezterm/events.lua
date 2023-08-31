--[[
Handling of events in WezTerm.
--]]

local terminal = require('wezterm')

-- Set window title
terminal.on('format-window-title', function(tab, pane, tabs, panes, config) return 'Terminal' end)
