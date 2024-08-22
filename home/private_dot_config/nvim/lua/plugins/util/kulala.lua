--[[
-- kulala.nvim (https://github.com/mistweaverco/kulala.nvim)
--]]

---Execute current request
local execute_request = function() require('kulala').run() end

---Jump to next request
local jump_next = function() require('kulala').jump_next() end

---Jump to previous request
local jump_previous = function() require('kulala').jump_prev() end

---Open a buffer with a temporary file for writing requests
local open_scratchpad = function() require('kulala').scratchpad() end

--- Select environment
local select_env = function() require('kulala').set_selected_env() end

---Toggle response view
local toggle_view = function() require('kulala').toggle_view() end

return {
  'mistweaverco/kulala.nvim',
  opts = {},
  keys = {
    { '<leader>hr', execute_request, ft = 'http', desc = 'Execute request' },
    { '<leader>hn', jump_next, ft = 'http', desc = 'Jump to next request' },
    { '<leader>hp', jump_previous, ft = 'http', desc = 'Jump to previousrequest' },
    { '<leader>hv', toggle_view, ft = 'http', desc = 'Toggle response view' },
    { '<leader>he', select_env, ft = 'http', desc = 'Set selected environment' },
    { '<leader>hs', open_scratchpad, desc = 'Open scratchpad' },
  },
}
