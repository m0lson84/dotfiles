return {

  -- Add docker specific modules to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { 'dockerfile' })
    end,
  },

  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        dockerls = {},
        docker_compose_language_service = {},
      },
    },
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        table.insert(opts.ensure_installed, 'hadolint')
      end,
    },
    opts = function(_, opts)
      local nls = require('null-ls')
      opts.sources = opts.sources or {}
      table.insert(opts.sources, nls.builtins.diagnostics.hadolint)
    end,
  },
}
