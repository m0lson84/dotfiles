return {
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        ruff_lsp = {
          init_options = {
            settings = {
              args = { '--select', 'ALL' },
            },
          },
        },
      },
    },
    setup = {
      ruff_lsp = function()
        require('lazyvim.util').on_attach(function(client)
          if client.name ~= 'ruff_lsp' then return end
          client.server_capabilities.hoverProvider = false
        end)
      end,
    },
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        table.insert(opts.ensure_installed, 'ruff')
      end,
    },
    opts = function(_, opts)
      local nls = require('null-ls')
      table.insert(
        opts.sources,
        nls.builtins.formatting.ruff.with({
          args = {
            '--fix',
            '--select',
            'ALL',
            '--exit-zero',
            '--no-cache',
            '--stdin-filename',
            '$FILENAME',
          },
        })
      )
    end,
  },
}
