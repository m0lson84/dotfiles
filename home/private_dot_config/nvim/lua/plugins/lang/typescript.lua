return {

  -- Add Typescript & related to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(opts.ensure_installed, { 'javascript', 'typescript' })
      end
    end,
  },

  -- Configure language server
  {
    'pmizio/typescript-tools.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'neovim/nvim-lspconfig',
    },
    opts = {},
  },

  -- Configure test runner
  {
    'nvim-neotest/neotest',
    optional = true,
    dependencies = { 'nvim-neotest/neotest-jest' },
    opts = {
      adapters = {
        ['neotest-jest'] = {
          -- TODO: Fill in the adapter settings
          -- Here you can specify the settings for the adapter, i.e.
          -- See: https://github.com/nvim-neotest/neotest-jest#usage
        },
      },
    },
  },
}
