return {
  {
    'williamboman/mason.nvim',
    optional = true,
    opts = function(_, opts) table.insert(opts.ensure_installed, 'codelldb') end,
  },
}
