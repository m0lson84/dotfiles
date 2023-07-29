-- Global utility functions
local M = {}

function M.has_words_before()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

function M.table_merge(...)
  local result = {}
  for _, t in ipairs { ... } do
    for k, v in pairs(t) do result[k] = v end
    local mt = getmetatable(t)
    if mt then setmetatable(result, mt) end
  end
  return result
end

return M
