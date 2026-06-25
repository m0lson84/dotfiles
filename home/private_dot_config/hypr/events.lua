--[[
EVENTS
--]]

local utils = require('utils')

local common = {
  { cmd = 'noctalia', opts = {} },
  { cmd = 'password --silent', opts = {} },
}

local machines = {
  ['deep-thought'] = {},
  ['dont-panic'] = {
    { cmd = 'ghostty', opts = { workspace = '1' } },
    { cmd = 'zen-browser', opts = { workspace = '2' } },
  },
  ['PF4CXK6S'] = {
    { cmd = 'teams-for-linux-electron', opts = { workspace = '1' } },
    { cmd = 'ghostty', opts = { workspace = '2' } },
    { cmd = 'zen-browser', opts = { workspace = '3' } },
  },
}

-- Startup applications
hl.on('hyprland.start', function()
  local machine = machines[utils.hostname()] or {}
  local apps = utils.list_concat(common, machine)
  for _, app in ipairs(apps) do
    hl.exec_cmd(app.cmd, app.opts)
  end
end)
