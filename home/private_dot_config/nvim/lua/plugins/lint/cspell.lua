--[[
CSpell (https://cspell.org/)
--]]

-- Import utility functions
local util = require('util')

--- Find a config file in the current directory or any parent directories.
---@param cwd string|nil The directory to start searching from. Defaults to the current working directory.
---@return string|nil
local find_config = function(cwd)
  local file_names = { '.cspell.json', 'cspell.json' }
  local vscode_config = util.file.find(file_names, util.vscode.config(cwd))
  local vim_config = util.file.find(file_names, util.vim.config(cwd))
  return vscode_config ~= nil and vscode_config or vim_config ~= nil and vim_config or nil
end

return {
  -- Configure linter
  {
    'mfussenegger/nvim-lint',
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'cspell' }) end,
      },
    },
    opts = {
      linters_by_ft = { ['*'] = { 'cspell' } },
    },
  },

  -- TODO: Look for alternatives to none-ls for configuring code actions
  {
    'nvimtools/none-ls.nvim',
    opts = function(_, opts)
      vim.list_extend(opts.sources, {
        require('null-ls').builtins.code_actions.cspell.with({
          config = {
            config_file_preferred_name = 'cspell.json',
            find_json = find_config,
          },
        }),
      })
    end,
  },
}
