--[[
MONITORS
--]]

local utils = require('utils')

--- Machine specific configurations
---@type table<string, HL.MonitorSpec[]>
local machines = {
  ['deep-thought'] = {
    {
      output = 'desc:LG Electronics LG ULTRAGEAR 508TOSY03822',
      mode = '3440x1440@100',
      position = '0x0',
      scale = 'auto',
    },
    {
      output = 'desc:LG Electronics LG ULTRAGEAR 508TOZU02477',
      mode = '3440x1440@100',
      position = '3440x0',
      scale = 'auto',
    },
  },
  ['dont-panic'] = {
    {
      output = 'eDP-1',
      mode = '2880x1920@120',
      position = 'auto',
      scale = 2,
    },
  },
  ['PF4CXK6S'] = {
    {
      output = 'eDP-1',
      mode = '1920x1200@60',
      position = '0x0',
      scale = 1.25,
    },
    {
      output = 'desc:Lenovo Group Limited E27q-20 V5MBZ804',
      mode = '2560x1440@60',
      position = '1536x0',
      scale = 1,
    },
    {
      output = 'desc:Lenovo Group Limited E27q-20 V5MBZ801',
      mode = '2560x1440@60',
      position = '4096x0',
      scale = 1,
    },
  },
}

-- Fallback for any unmatched monitor
hl.monitor({
  output = '',
  mode = 'preferred',
  position = 'auto',
  scale = 'auto',
})

-- Apply host-specific monitor configuration
local monitors = machines[utils.hostname()]
if monitors then
  for _, spec in pairs(monitors) do
    hl.monitor(spec)
  end
end
