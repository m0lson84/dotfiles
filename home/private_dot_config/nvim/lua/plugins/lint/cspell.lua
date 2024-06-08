--[[
CSpell (https://cspell.org/)
--]]

return {
  {
    'mfussenegger/nvim-lint',
    dependencies = {
      { 'williamboman/mason.nvim', opts = { ensure_installed = { 'cspell' } } },
    },
    opts = {
      linters = {
        cspell = {},
      },
      linters_by_ft = {
        ['*'] = { 'cspell' },
      },
    },
  },
}
