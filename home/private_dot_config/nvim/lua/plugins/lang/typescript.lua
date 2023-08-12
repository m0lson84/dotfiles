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
    'neovim/nvim-lspconfig',
    dependencies = { 'jose-elias-alvarez/typescript.nvim' },
    opts = {
      servers = {
        tsserver = {
          keys = {
            { '<leader>co', '<cmd>TypescriptOrganizeImports<CR>', desc = 'Organize Imports' },
            { '<leader>cR', '<cmd>TypescriptRenameFile<CR>', desc = 'Rename File' },
          },
          settings = function()
            local language = {
              format = {
                indentSize = vim.o.shiftwidth,
                convertTabsToSpaces = vim.o.expandtab,
                tabSize = vim.o.tabstop,
              },
            }
            return {
              completions = { completeFunctionCalls = true },
              javascript = language,
              typescript = language,
            }
          end,
        },
      },
      setup = {
        tsserver = function(_, opts)
          require('typescript').setup({ server = opts })
          return true
        end,
      },
    },
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, require('typescript.extensions.null-ls.code-actions'))
    end,
  },

  -- Configure test runner
  {
    'nvim-neotest/neotest',
    optional = true,
    dependencies = { 'nvim-neotest/neotest-jest' },
    opts = {
      adapters = {
        ['neotest-jest'] = {
          jestCommand = 'yarn test -- --detectOpenHandles --forceExit --silent=false',
          cwd = function() return vim.fn.getcwd() end,
        },
      },
    },
  },
}
