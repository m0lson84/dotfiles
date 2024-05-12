--[[
Ruff (https://beta.ruff.rs/docs/)
--]]

local config = {
  args = { '--select', 'ALL' },
}

return {

  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'ruff' }) end,
      },
    },
    opts = {
      servers = {
        ruff = {
          init_options = {
            settings = { args = config.args },
          },
          commands = {
            RuffAutoFix = {
              function()
                vim.lsp.buf.code_action({
                  context = { only = { 'source.fixAll' }, diagnostics = {} },
                  apply = true,
                })
              end,
              description = 'Fix All',
            },
            RuffOrganizeImports = {
              function()
                vim.lsp.buf.code_action({
                  context = { only = { 'source.organizeImports' }, diagnostics = {} },
                  apply = true,
                })
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
            if client.name ~= 'ruff' then return end
            client.server_capabilities.hoverProvider = false
          end)
        end,
      },
    },
  },

  -- Configure formatter
  {
    'stevearc/conform.nvim',
    opts = {
      formatters = {
        ruff_fix = { prepend_args = config.args },
        ruff_format = {},
      },
    },
  },
}
