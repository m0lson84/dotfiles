--[[
RULES
--]]

local utils = require('utils')

--- List of monitor names for each system
---@type table<string, string[]>
local machines = {
  ['deep-thought'] = {
    'desc:LG Electronics LG ULTRAGEAR 508TOSY03822',
    'desc:LG Electronics LG ULTRAGEAR 508TOZU02477',
  },
  ['dont-panic'] = {
    'eDP-1',
  },
  ['PF4CXK6S'] = {
    'eDP-1',
    'desc:Lenovo Group Limited E27q-20 V5MBZ804',
    'desc:Lenovo Group Limited E27q-20 V5MBZ801',
  },
}

local monitors = machines[utils.hostname()]
if monitors then
  for i = 1, 6 do
    hl.workspace_rule({
      workspace = tostring(i),
      monitor = monitors[(i - 1) % #monitors + 1],
      persistent = true,
      default = i == 1,
    })
  end
end

hl.layer_rule({
  name = 'noctalia',
  match = {
    namespace = '^noctalia-(bar-.+|notification|dock|panel|osd)$',
  },
  ignore_alpha = 0.5,
  blur = true,
  blur_popups = true,
})

-- Suppress maximize requests from apps (prevents Electron/Firefox from going fullscreen unexpectedly)
hl.window_rule({
  name = 'suppress-maximize-events',
  match = { class = '.*' },
  suppress_event = 'maximize',
})

-- Fix XWayland drag focus-stealing bug
hl.window_rule({
  name = 'fix-xwayland-drags',
  match = {
    class = '^$',
    title = '^$',
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  no_focus = true,
})

-- Float file dialogs, authentication prompts, etc.
hl.window_rule({
  name = 'float-dialogs',
  match = { title = '(Open|Save|File|Folder|Authentication|Authenticate)' },
  float = true,
  center = true,
})

-- 1Password popup (since you autostart it)
hl.window_rule({
  name = 'float-1password',
  match = { class = '1Password', title = '1Password' },
  float = true,
  center = true,
})
