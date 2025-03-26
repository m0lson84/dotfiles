--[[
 _    _        _____
| |  | |      |_   _|
| |  | | ___ ___| | ___ _ __ _ __ ___
| |/\| |/ _ \_  / |/ _ \ '__| '_ ` _ \
\  /\  /  __// /| |  __/ |  | | | | | |
 \/  \/ \___/___\_/\___|_|  |_| |_| |_|


--]]

local util = require('util')
local wezterm = require('wezterm') --[[@as Wezterm]]

local config = {}
if wezterm.config_builder then config = wezterm.config_builder() end

-- Environment
local platform = util.get_target().platform

-- General
config.check_for_updates = false
config.enable_kitty_keyboard = true
config.term = 'wezterm'

-- Programs
config.default_prog = platform == 'windows' and { 'ubuntu' } or { 'fish' }
config.launch_menu = {
  { label = 'fish', args = { 'fish' } },
  { label = 'bash', args = { 'bash' } },
  { label = 'zsh', args = { 'zsh' } },
}

-- Rendering
config.enable_wayland = true
config.front_end = 'WebGpu'
config.max_fps = 240

-- Tab bar
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true

-- Window
config.window_close_confirmation = 'NeverPrompt'
config.window_decorations = platform == 'linux' and 'NONE' or 'TITLE | RESIZE | MACOS_FORCE_DISABLE_SHADOW'

require('appearance').apply(config)
require('font').apply(config)
require('hyperlink').apply(config)
require('keymaps').apply(config)
require('events')

return config
