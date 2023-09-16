--[[
Ruff (https://beta.ruff.rs/docs/)
--]]

-- Additional configuration.
local config = {
  extra_args = { '--select', 'ALL' },
}

return {
  {
    'williamboman/mason.nvim',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'ruff-lsp', 'ruff' }) end,
  },
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        ruff_lsp = {
          init_options = {
            settings = { args = config.extra_args },
          },
          commands = {
            RuffAutoFix = {
              function() vim.lsp.buf.code_action({ context = { only = { 'source.fixAll.ruff' } }, apply = true }) end,
              description = 'Fix All',
            },
            RuffOrganizeImports = {
              function()
                vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports.ruff' } }, apply = true })
              end,
              description = 'Organize Imports',
            },
          },
          keys = {
            { '<leader>cf', '<cmd>RuffAutoFix<CR>',         desc = 'Fix All' },
            { '<leader>co', '<cmd>RuffOrganizeImports<CR>', desc = 'Organize Imports' },
          },
        },
      },
      setup = {
        ruff_lsp = function()
          require('lazyvim.util').on_attach(function(client, _)
            if client.name ~= 'ruff_lsp' then return end
            client.server_capabilities.hoverProvider = false
          end)
        end,
      },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      local ruff = require('conform.formatters.ruff')
      opts.formatters_by_ft = require('util').table.extend_keys(opts.formatters_by_ft, { 'python' }, { 'ruff' })
      require('conform').formatters.ruff = vim.tbl_deep_extend('force', ruff, {
        args = require('conform.util').extend_args(ruff.args, config.extra_args, { append = true }),
      })
    end,
  },
}
