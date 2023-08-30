--[[
Helper functions for general configuration of wezterm.
--]]

local M = {}

--- Apply any general configuration for the terminal.
-- @param config The configuration table to modify.
-- @param os The operating system the terminal is running in.
M.apply = function(config, os)
  config.check_for_updates = false
  config.enable_kitty_keyboard = true
  config.enable_tab_bar = false
  config.window_close_confirmation = 'NeverPrompt'
  config.window_decorations = 'TITLE | RESIZE | MACOS_FORCE_DISABLE_SHADOW'

  -- Start in WSL if running on windows
  if os == 'windows' then config.default_prog = { 'ubuntu' } end
end

return M
