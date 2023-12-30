--[[
  Jupyter notebook utility functions.
  @module Jupiter
  @alias jupyter
--]]

local CELL_MARKER = '^# %%%%'

local M = {}

--- Select a cell in a Jupyter notebook.
---@return number, number, number, number - The row, column, start line, and end line of the cell.
M.select_cell = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local column = vim.api.nvim_win_get_cursor(0)[2]
  local start_line = nil
  local end_line = nil

  for line = row, 1, -1 do
    local content = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
    if content:find(CELL_MARKER) then
      start_line = line
      break
    end
  end

  local count = vim.api.nvim_buf_line_count(bufnr)
  for line = row + 1, count do
    local content = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
    if content:find(CELL_MARKER) then
      end_line = line
      break
    end
  end

  if not start_line then start_line = 1 end
  if not end_line then end_line = count end

  return row, column, start_line, end_line
end

--- Execute the code in a given Jupyter notebook cell.
M.execute_cell = function()
  local row, column, start_line, end_line = M.select_cell()
  vim.fn.setpos('\'<', { 0, start_line + 1, 0, 0 })
  vim.fn.setpos('\'>', { 0, end_line - 1, 0, 0 })
  require('iron.core').visual_send()
  vim.api.nvim_win_set_cursor(0, { row, column })
end

--- Insert a new cell into a Jupyter notebook.
M.insert_cell = function(content)
  local _, _, _, end_line = M.select_cell()
  local bufnr = vim.api.nvim_get_current_buf()
  local line = (end_line ~= 1) and (end_line - 1) or end_line
  vim.api.nvim_win_set_cursor(0, { line - 1, 0 })
  vim.cmd('normal!2o')
  vim.api.nvim_buf_set_lines(bufnr, line, line + 1, false, { content })
  vim.cmd('normal!2o')
  vim.cmd('normal!k')
end

return M
