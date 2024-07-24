--[[
markdownlint (https://github.com/DavidAnson/markdownlint)
--]]

return {
  {
    'mfussenegger/nvim-lint',
    dependencies = {
      { 'williamboman/mason.nvim', opts = { ensure_installed = { 'markdownlint-cli2' } } },
    },
    opts = {
      linters = {
        ['markdownlint-cli2'] = {
          args = { '--config', '~/.config/nvim/markdownlint.json' },
        },
      },
    },
  },
}
