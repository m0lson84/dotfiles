--[[
CSpell (https://cspell.org/)
--]]

local config = {
  config_file_preferred_name = 'cspell.json',
  find_json = function(cwd)
    local config_path = require('util').path.join(cwd, '.vim', 'cspell.json')
    return require('util').file.exists(config_path) and config_path or nil
  end,
}

return {
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) table.insert(opts.ensure_installed, 'cspell') end,
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    dependencies = { 'davidmh/cspell.nvim' },
    opts = function(_, opts)
      local cspell = require('cspell')
      table.insert(opts.sources, cspell.code_actions.with({ config = config }))
      table.insert(opts.sources, cspell.diagnostics.with({ config = config }))
    end,
  },
}
