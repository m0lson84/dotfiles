return {
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) table.insert(opts.ensure_installed, 'prettier') end,
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    opts = function(_, opts)
      local nls = require('null-ls')
      table.insert(
        opts.sources,
        nls.builtins.formatting.prettier.with({
          filetypes = { 'css', 'html', 'json', 'markdown', 'vue', 'yaml' },
        })
      )
    end,
  },
}
