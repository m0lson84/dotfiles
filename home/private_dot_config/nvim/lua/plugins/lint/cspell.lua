local config = {
  -- The name of the configuration file to find.
  config_file_preferred_name = 'cspell.json',
  --- A way to define your own logic to find the CSpell configuration file.
  ---@param cwd string: The same current working directory defined in the source, defaulting to vim.loop.cwd()
  ---@return string|nil: The path of the json file
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
