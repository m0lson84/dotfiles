--[[
CSpell (https://cspell.org/)
--]]

return {
  {
    'mfussenegger/nvim-lint',
    dependencies = {
      { 'williamboman/mason.nvim', opts = { ensure_installed = { 'cspell' } } },
    },
    opts = function(_, opts) opts.linters_by_ft = util.table.extend_keys(opts.linters_by_ft, { '*' }, { 'cspell' }) end,
  },
}
