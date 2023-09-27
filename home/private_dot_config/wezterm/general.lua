--[[
General configuration of WezTerm.
--]]

local M = {}

--- Apply any general configuration for the terminal.
-- @param config The configuration table to modify.
-- @param os The operating system the terminal is running in.
M.apply = function(config, os)
  config.check_for_updates = false
  config.enable_kitty_keyboard = true
  config.term = 'wezterm'

  -- Window configuration
  config.window_close_confirmation = 'NeverPrompt'
  config.window_decorations = 'TITLE | RESIZE | MACOS_FORCE_DISABLE_SHADOW'

  -- Tab bar configuration
  config.enable_tab_bar = true
  config.use_fancy_tab_bar = false
  config.tab_bar_at_bottom = true

  -- Start in WSL if running on windows
  if os == 'windows' then config.default_prog = { 'ubuntu' } end
end

return M
