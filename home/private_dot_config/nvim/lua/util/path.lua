--[[
  Path utility functions.
  @module Path
  @alias path
--]]

local M = {}

--- Join a list of paths.
---@param ... string: The paths to join.
M.join = function(...) return table.concat(vim.tbl_flatten({ ... }), '/') end

return M
