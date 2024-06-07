--[[
hadolint (https://github.com/hadolint/hadolint)
--]]

return {
  {
    'mfussenegger/nvim-lint',
    dependencies = {
      { 'williamboman/mason.nvim', opts = { ensure_installed = { 'hadolint' } } },
    },
    opts = {
      linters = {
        hadolint = {},
      },
    },
  },
}
