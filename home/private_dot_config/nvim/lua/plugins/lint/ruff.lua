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
        opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'ruff' }) end,
      },
    },
    opts = {
      servers = {
        ruff = {
          settings = {
            lint = {
              select = { 'ALL' },
            },
          },
          keys = {
            {
              '<leader>co',
              function()
                vim.lsp.buf.code_action({
                  context = { only = { 'source.organizeImports' }, diagnostics = {} },
                  apply = true,
                })
              end,
              desc = 'Organize Imports',
            },
          },
        },
      },
      setup = {
        ruff = function()
          require('lazyvim.util').lsp.on_attach(function(client, _)
            if client.name ~= 'ruff' then return end
            client.server_capabilities.hoverProvider = false
          end)
        end,
      },
    },
  },
}
