--[[
Ruff (https://beta.ruff.rs/docs/)
--]]

local config = {
  args = { '--fix', '-e', '-n', '--stdin-filename', '$FILENAME', '-' },
  extra_args = { '--select', 'ALL' },
}

return {
  -- Configure language server
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
            { '<leader>cf', '<cmd>RuffAutoFix<CR>', desc = 'Fix All' },
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

  -- Configure formatter
  {
    'stevearc/conform.nvim',
    dependencies = {
      {
        'williamboman/mason.nvim',
        opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'ruff-lsp', 'ruff' }) end,
      },
    },
    opts = {
      formatters = {
        ruff_fix = { args = vim.tbl_flatten({ config.args, config.extra_args }) },
      },
    },
  },
}
