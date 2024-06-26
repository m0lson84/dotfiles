--[[
Ruff (https://beta.ruff.rs/docs/)
--]]

return {

  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', opts = { ensure_installed = { 'ruff' } } },
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
          LazyVim.lsp.on_attach(function(client, _) client.server_capabilities.hoverProvider = false end, 'ruff')
        end,
      },
    },
  },
}
