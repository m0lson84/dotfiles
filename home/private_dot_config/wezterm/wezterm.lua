--[[
 _    _        _____
| |  | |      |_   _|
| |  | | ___ ___| | ___ _ __ _ __ ___
| |/\| |/ _ \_  / |/ _ \ '__| '_ ` _ \
\  /\  /  __// /| |  __/ |  | | | | | |
 \/  \/ \___/___\_/\___|_|  |_| |_| |_|


--]]

local terminal = require('wezterm')
local util = require('util')

local config = {}
if terminal.config_builder then config = terminal.config_builder() end

-- General
config.check_for_updates = false
config.enable_kitty_keyboard = true
config.term = 'wezterm'

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
config.window_decorations = 'TITLE | RESIZE | MACOS_FORCE_DISABLE_SHADOW'

-- Start in WSL if running on windows
if util.get_target().platform == 'windows' then config.default_prog = { 'ubuntu' } end

require('appearance').apply(config)
require('font').apply(config)
require('hyperlink').apply(config)
require('keymaps').apply(config)
require('events')

return config
