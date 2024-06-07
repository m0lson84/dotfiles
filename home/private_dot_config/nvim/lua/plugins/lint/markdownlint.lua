--[[
markdownlint (https://github.com/DavidAnson/markdownlint)
--]]

return {
  {
    'mfussenegger/nvim-lint',
    dependencies = {
      { 'williamboman/mason.nvim', opts = { ensure_installed = { 'markdownlint' } } },
    },
    opts = {
      linters = {
        markdownlint = {
          args = { '--config', '~/.config/nvim/markdownlint.json' },
        },
      },
    },
  },
}
