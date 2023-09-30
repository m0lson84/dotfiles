--[[
Bash language support
--]]

-- Import utility functions
local util = require('util')

return {

  -- Add languages to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, { 'bash' })
      vim.treesitter.language.register('bash', 'dotenv')
    end,
  },

  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        bashls = {
          keys = {
            { '<leader>cD', '<cmd>Neogen<cr>', desc = 'Generate Docs', mode = { 'n' } },
          },
        },
      },
    },
  },

  -- Configure linting
  {
    'mfussenegger/nvim-lint',
    opts = function(_, opts)
      opts.linters_by_ft = util.linter.set(opts.linters_by_ft, { 'bash', 'dotenv', 'sh', 'zsh' }, { 'shellcheck' })
    end,
  },

  -- Configure formatting
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters_by_ft = util.formatter.set(opts.formatters_by_ft, { 'bash', 'dotenv', 'sh', 'zsh' }, { 'shfmt' })
    end,
  },
}
