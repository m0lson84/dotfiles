-- keybinds.lua — Hyprland keybindings

-- Modifiers
local mod = 'SUPER'
local meh = 'CTRL + SHIFT + ALT'

-- Default applications
local browser = 'firefox'
local files = 'nautilus'
local terminal = 'ghostty'

-- Noctalia
local function noctalia(cmd) return 'noctalia msg ' .. cmd end
local cmd = {
  launcher = 'panel-toggle launcher',
  lock_screen = 'session lock',
  session_menu = 'panel-toggle session',
  brightness = {
    up = 'brightness-up',
    down = 'brightness-down',
  },
  volume = {
    up = 'volume-up',
    down = 'volume-down',
  },
  mute = {
    output = 'volume-mute',
    input = 'mic-mute',
  },
  media = {
    play = 'media toggle',
    next = 'media next',
    previous = 'media previous',
  },
}

-- ─── Applications ───
hl.bind(mod .. ' + Space', hl.dsp.exec_cmd(noctalia(cmd.launcher)))
hl.bind('CTRL + Space', hl.dsp.exec_cmd(noctalia(cmd.launcher)))
hl.bind(mod .. ' + ALT + L', hl.dsp.exec_cmd(noctalia(cmd.lock_screen)))
hl.bind(mod .. ' + SHIFT + Q', hl.dsp.exec_cmd(noctalia(cmd.session_menu)))

hl.bind(mod .. ' + B', hl.dsp.exec_cmd(browser))
hl.bind(mod .. ' + E', hl.dsp.exec_cmd(files))
hl.bind(mod .. ' + Return', hl.dsp.exec_cmd(terminal))

-- ─── Window Management ───
hl.bind(mod .. ' + Q', hl.dsp.window.close())
hl.bind(mod .. ' + F', hl.dsp.window.fullscreen())
hl.bind(mod .. ' + T', hl.dsp.window.float({ action = 'toggle' }))

-- ─── Vim-style Focus ───
hl.bind(mod .. ' + H', hl.dsp.focus({ direction = 'left' }))
hl.bind(mod .. ' + J', hl.dsp.focus({ direction = 'down' }))
hl.bind(mod .. ' + K', hl.dsp.focus({ direction = 'up' }))
hl.bind(mod .. ' + L', hl.dsp.focus({ direction = 'right' }))

-- ─── Vim-style Move ───
hl.bind(mod .. ' + SHIFT + H', hl.dsp.window.move({ direction = 'left' }))
hl.bind(mod .. ' + SHIFT + J', hl.dsp.window.move({ direction = 'down' }))
hl.bind(mod .. ' + SHIFT + K', hl.dsp.window.move({ direction = 'up' }))
hl.bind(mod .. ' + SHIFT + L', hl.dsp.window.move({ direction = 'right' }))

-- ─── Workspaces ───
for i = 1, 9 do
  hl.bind(mod .. ' + ' .. i, hl.dsp.focus({ workspace = i }))
  hl.bind(mod .. ' + SHIFT + ' .. i, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. ' + TAB', hl.dsp.focus({ workspace = 'previous' }))

-- ─── Scroll Workspaces ───
hl.bind(mod .. ' + mouse_down', hl.dsp.focus({ workspace = 'e+1' }))
hl.bind(mod .. ' + mouse_up', hl.dsp.focus({ workspace = 'e-1' }))

-- ─── Resize ───
hl.bind(mod .. ' + Minus', hl.dsp.window.resize({ x = '-10', y = 0 }))
hl.bind(mod .. ' + Equal', hl.dsp.window.resize({ x = '10', y = 0 }))
hl.bind(mod .. ' + SHIFT + Minus', hl.dsp.window.resize({ x = 0, y = '-10' }))
hl.bind(mod .. ' + SHIFT + Equal', hl.dsp.window.resize({ x = 0, y = '10' }))

-- ─── Screenshots (grim + satty) ───
local satty = '--copy-command wl-copy --output-filename ~/Pictures/Screenshots/satty-%Y%m%d_%H%M%S.png'
local active_window = [[$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')]]
hl.bind(meh .. ' + 1', hl.dsp.exec_cmd('grim -g "$(slurp)" - | satty -f - ' .. satty))
hl.bind(meh .. ' + 2', hl.dsp.exec_cmd('grim -g "' .. active_window .. '" - | satty -f - ' .. satty))
hl.bind(meh .. ' + 3', hl.dsp.exec_cmd('grim - | satty -f - ' .. satty))

-- ─── Media Keys (locked — work on lockscreen) ───
hl.bind('XF86AudioRaiseVolume', hl.dsp.exec_cmd(noctalia(cmd.volume.up)), { locked = true })
hl.bind('XF86AudioLowerVolume', hl.dsp.exec_cmd(noctalia(cmd.volume.down)), { locked = true })
hl.bind('XF86AudioMute', hl.dsp.exec_cmd(noctalia(cmd.mute.output)), { locked = true })
hl.bind('XF86AudioMicMute', hl.dsp.exec_cmd(noctalia(cmd.mute.input)), { locked = true })
hl.bind('XF86AudioNext', hl.dsp.exec_cmd(noctalia(cmd.media.next)), { locked = true })
hl.bind('XF86AudioPrev', hl.dsp.exec_cmd(noctalia(cmd.media.previous)), { locked = true })
hl.bind('XF86AudioPlay', hl.dsp.exec_cmd(noctalia(cmd.media.play)), { locked = true })
hl.bind('XF86AudioPause', hl.dsp.exec_cmd(noctalia(cmd.media.play)), { locked = true })

-- ─── Brightness ───
hl.bind('XF86MonBrightnessUp', hl.dsp.exec_cmd(noctalia(cmd.brightness.up)), { locked = true })
hl.bind('XF86MonBrightnessDown', hl.dsp.exec_cmd(noctalia(cmd.brightness.down)), { locked = true })

-- ─── Power/Exit ───
hl.bind('CTRL + ALT + Delete', hl.dsp.exit())
hl.bind(mod .. ' + SHIFT + P', hl.dsp.dpms('off'))

-- ─── Mouse Binds ───
hl.bind(mod .. ' + mouse:272', hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. ' + mouse:273', hl.dsp.window.resize(), { mouse = true })
