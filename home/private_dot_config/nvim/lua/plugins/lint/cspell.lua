--[[
CSpell (https://cspell.org/)
--]]

-- List of possible config file names.
local CONFIG_FILES = {
  '.cspell.json',
  'cspell.json',
}

--- Find a config file in the current directory or any parent directories.
---@param cwd string|nil The directory to start searching from. Defaults to the current working directory.
---@return string|nil
local find_config = function(cwd)
  local util = require('util')
  for _, file in ipairs(CONFIG_FILES) do
    local config_path = util.path.join(cwd or vim.loop.cwd(), file)
    if util.file.exists(config_path) then return config_path end
  end
  return nil
end

-- The configuration to use for cspell.
local config = {
  config_file_preferred_name = 'cspell.json',
  find_json = function(cwd)
    local util = require('util')
    local vscode_config = find_config(util.vscode.config(cwd))
    local vim_config = find_config(util.vim.config(cwd))
    return vscode_config ~= nil and vscode_config or vim_config ~= nil and vim_config or nil
  end,
}

return {

  -- Install dependencies
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'cspell' }) end,
  },

  -- Configure code actions
  {
    'nvimtools/none-ls.nvim',
    opts = function(_, opts)
      vim.list_extend(opts.sources, {
        require('null-ls').builtins.code_actions.cspell.with({ config = config }),
      })
    end,
  },

  -- Configure linter
  -- TODO: Migrate to nvim-lint once I figure out how to pass config to cspell.
  {
    'nvimtools/none-ls.nvim',
    opts = function(_, opts)
      vim.list_extend(opts.sources, {
        require('null-ls').builtins.diagnostics.cspell.with({ config = config }),
      })
    end,
  },
}
