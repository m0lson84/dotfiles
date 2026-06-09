--[[
INPUT
--]]

hl.config({
  input = {
    kb_layout = 'us',
    numlock_by_default = true,
    follow_mouse = 1,
    touchpad = {
      natural_scroll = true,
      clickfinger_behavior = true,
    },
  },
})

hl.gesture({
  fingers = 3,
  direction = 'horizontal',
  action = 'workspace',
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
-- hl.device({
--     name        = "epic-mouse-v1",
--     sensitivity = -0.5,
-- })
