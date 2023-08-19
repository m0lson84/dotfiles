--[[
codelldb (https://github.com/vadimcn/codelldb)
--]]

return {
  {
    'williamboman/mason.nvim',
    optional = true,
    opts = function(_, opts) table.insert(opts.ensure_installed, 'codelldb') end,
  },

  -- TODO: Integrate codelldb with nvim-dap
}
