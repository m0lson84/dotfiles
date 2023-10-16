--[[
Ruff (https://beta.ruff.rs/docs/)
--]]

return {
  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'ruff-lsp' }) end,
      },
    },
    opts = {
      servers = {
        ruff_lsp = {
          init_options = {
            settings = { args = { '--select', 'ALL' } },
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
            { '<leader>cf', '<cmd>RuffAutoFix<CR>', desc = 'Fix All' },
            { '<leader>co', '<cmd>RuffOrganizeImports<CR>', desc = 'Organize Imports' },
          },
        },
      },
      setup = {
        ruff_lsp = function()
          require('lazyvim.util').lsp.on_attach(function(client, _)
            if client.name ~= 'ruff_lsp' then return end
            client.server_capabilities.hoverProvider = false
          end)
        end,
      },
    },
  },

  -- Configure formatter
  {
    'stevearc/conform.nvim',
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'ruff' }) end,
      },
    },
    opts = {
      formatters = {
        ruff_fix = { prepend_args = { '--select', 'ALL' } },
      },
    },
  },
}
