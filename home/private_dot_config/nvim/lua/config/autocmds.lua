-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

--- Create a new autocmd group
---@param name string The name of the group to create
local function create_group(name) return vim.api.nvim_create_augroup('local_' .. name, { clear = true }) end

-- Set textwidth & colorcolumn based on filetype
vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = create_group('language_ruler'),
  callback = function()
    local filetype = vim.bo[vim.api.nvim_get_current_buf()].filetype

    --- Set the ruler for a range of filetypes
    ---@param include table<string> The filetypes the ruler should apply to
    ---@param ruler string The width of the ruler
    local function set_ruler(include, ruler)
      if vim.tbl_contains(include, filetype) then vim.wo.colorcolumn = ruler end
      return vim.tbl_contains(include, filetype)
    end

    -- Set for supported languages
    local languages = { 'go', 'json', 'lua', 'python', 'rust', 'toml', 'typescript', 'yaml' }
    if set_ruler(languages, '120') then return end

    -- Set for supported shells
    local shells = { 'bash', 'sh', 'zsh' }
    if set_ruler(shells, '100') then return end

    -- Disable colorcolumn for all other filetypes
    vim.wo.colorcolumn = ''
  end,
})
