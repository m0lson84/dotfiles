--[[
  Path utility functions.
  @module Path
  @alias path
--]]

local M = {}

--- Join a list of paths.
---@param ... string | string[] The paths to join.
---@return string path The joined path.
M.join = function(...) return table.concat(vim.iter({ ... }):flatten():totable(), '/') end

return M
