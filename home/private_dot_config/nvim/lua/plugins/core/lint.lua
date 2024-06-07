--[[
Core linting configuration
--]]

return {
  {
    'mfussenegger/nvim-lint',
    dependencies = {
      { 'williamboman/mason.nvim', opts = { ensure_installed = { 'editorconfig-checker' } } },
    },
    opts = function(_, opts)
      opts.linters_by_ft = { editorconfig = { 'editorconfig-checker' } }
      opts.linters = {}
    end,
  },
}
