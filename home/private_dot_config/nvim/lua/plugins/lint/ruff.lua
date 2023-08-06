return {
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        ruff_lsp = {},
      },
    },
    setup = {
      ruff_lsp = function()
        require('lazyvim.util').on_attach(function(client, _)
          if client.name ~= 'ruff_lsp' then return end
          -- Disable hover in favor of Pyright
          client.server_capabilities.hoverProvider = false
        end)
      end,
    },
  },
}
