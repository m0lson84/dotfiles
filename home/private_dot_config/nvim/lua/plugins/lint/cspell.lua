--[[
CSpell (https://cspell.org/)
--]]

return {
  {
    'mfussenegger/nvim-lint',
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'cspell' }) end,
      },
    },
    opts = function(_, opts) opts.linters_by_ft = util.table.extend_keys(opts.linters_by_ft, { '*' }, { 'cspell' }) end,
  },
}
