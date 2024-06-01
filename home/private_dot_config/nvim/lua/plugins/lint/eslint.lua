--[[
ESLint (https://eslint.org/)
--]]

return {
  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        eslint = {
          settings = {
            format = true,
            run = 'onSave',
            codeActionsOnSave = { enable = true, mode = 'all' },
            workingDirectories = { mode = 'auto' },
          },
        },
      },
      setup = {
        eslint = function()
          local config = { name = 'eslint: lsp', primary = false, priority = 200, filter = 'eslint' }
          local formatter = require('lazyvim.util').lsp.formatter(config)
          require('lazyvim.util').format.register(formatter)
        end,
      },
    },
  },
}
