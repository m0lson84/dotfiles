--[[
  Formatter utility functions.
  @module Format
  @alias format
--]]

local M = {}

--- Select the first available formatter for the given buffer.
---@param bufnr integer The buffer to format.
---@param ... string[] The list of formatters to try.
---@return string formatter The selected formatter.
M.first = function(bufnr, ...)
  local conform = require('conform')
  for i = 1, select('#', ...) do
    local formatter = select(i, ...)
    if conform.get_formatter_info(formatter, bufnr).available then return formatter end
  end
  return select(1, ...)
end

return M
