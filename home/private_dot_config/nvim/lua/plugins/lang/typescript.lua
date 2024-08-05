--[[
Javascript / Typescript language support
--]]

return {

  -- Add languages to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'javascript', 'typescript', 'tsx' } },
  },

  -- Configure language server
  {
    'yioneko/nvim-vtsls',
    lazy = true,
    opts = {},
    config = function(_, opts) require('vtsls').config(opts) end,
  },
  {
    'neovim/nvim-lspconfig',
    opts = function(_, opts)
      local vtsls = require('vtsls')
      local lang = {
        updateImportsOnFileMove = {
          enabled = 'always',
        },
        suggest = {
          completeFunctionCalls = true,
          includeCompletionsForImportStatements = true,
        },
      }
      opts.servers.vtsls = {
        settings = {
          complete_function_calls = true,
          vtsls = {
            autoUseWorkspaceTsdk = true,
            enableMoveToFileCodeAction = true,
            experimental = {
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
          javascript = lang,
          typescript = lang,
        },
        keys = {
          { 'gD', function() vtsls.commands.goto_source_definition(0) end, desc = 'Goto Source Definition' },
          { 'gR', function() vtsls.commands.file_references(0) end, desc = 'File References' },
          { '<leader>cD', function() vtsls.commands.fix_all(0) end, desc = 'Fix all diagnostics' },
          { '<leader>cM', function() vtsls.commands.add_missing_imports(0) end, desc = 'Add missing imports' },
          { '<leader>co', function() vtsls.commands.organize_imports(0) end, desc = 'Organize Imports' },
        },
      }
      return opts
    end,
  },

  -- Configure formatters
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        javascript = { 'biome-check', 'prettierd', stop_after_first = true },
        javascriptreact = { 'biome-check', 'prettierd', stop_after_first = true },
        typescript = { 'biome-check', 'prettierd', stop_after_first = true },
        typescriptreact = { 'biome-check', 'prettierd', stop_after_first = true },
      },
    },
  },

  -- Configure debug adapter
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      { 'williamboman/mason.nvim', opts = { ensure_installed = { 'js-debug-adapter' } } },
    },
    opts = function(_, opts)
      local dap = require('dap')

      -- Configure node.js adapter
      if not dap.adapters['pwa-node'] then
        require('dap').adapters['pwa-node'] = {
          type = 'server',
          host = 'localhost',
          port = '${port}',
          executable = {
            command = 'node',
            args = {
              LazyVim.get_pkg_path('js-debug-adapter', '/js-debug/src/dapDebugServer.js'),
              '${port}',
            },
          },
        }
      end

      if not dap.adapters['node'] then
        dap.adapters['node'] = function(cb, config)
          if config.type == 'node' then config.type = 'pwa-node' end
          local nativeAdapter = dap.adapters['pwa-node']
          if type(nativeAdapter) == 'function' then
            nativeAdapter(cb, config)
          else
            cb(nativeAdapter)
          end
        end
      end

      -- Define default configurations
      local filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }
      for _, lang in ipairs(filetypes) do
        dap.configurations[lang] = {
          {
            name = 'Launch File',
            type = 'pwa-node',
            request = 'launch',
            program = '${file}',
            cwd = '${workspaceFolder}',
            console = 'integratedTerminal',
          },
          {
            name = 'Attach to Process',
            type = 'pwa-node',
            request = 'attach',
            processId = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
            console = 'integratedTerminal',
          },
        }
      end

      return opts
    end,
  },

  -- Configure test runner
  {
    'nvim-neotest/neotest',
    dependencies = { 'nvim-neotest/neotest-jest' },
    opts = {
      adapters = {
        ['neotest-jest'] = {
          jestCommand = 'npm test --',
          jestConfigFile = function()
            local file = vim.fn.expand('%:p')
            if string.find(file, '/packages/') then return string.match(file, '(.-/[^/]+/)src') .. 'jest.config.ts' end
            return vim.fn.getcwd() .. '/jest.config.ts'
          end,
          cwd = function()
            local file = vim.fn.expand('%:p')
            if string.find(file, '/packages/') then return string.match(file, '(.-/[^/]+/)src') end
            return vim.fn.getcwd()
          end,
        },
      },
    },
  },

  -- Code annotations and documentation
  {
    'danymat/neogen',
    opts = function(_, opts)
      opts.languages = util.table.extend_keys(
        opts.languages or {},
        { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
        { template = { annotation_convention = 'jsdoc' } }
      )
    end,
  },

  -- Filetype icons
  {
    'echasnovski/mini.icons',
    opts = {
      file = {
        ['.eslintrc.js'] = { glyph = '󰱺', hl = 'MiniIconsPurple' },
        ['.node-version'] = { glyph = '', hl = 'MiniIconsGreen' },
        ['.prettierrc'] = { glyph = '', hl = 'MiniIconsPurple' },
        ['.yarnrc.yml'] = { glyph = '', hl = 'MiniIconsBlue' },
        ['eslint.config.js'] = { glyph = '󰱺', hl = 'MiniIconsPurple' },
        ['package.json'] = { glyph = '', hl = 'MiniIconsGreen' },
        ['tsconfig.json'] = { glyph = '', hl = 'MiniIconsAzure' },
        ['tsconfig.build.json'] = { glyph = '', hl = 'MiniIconsAzure' },
        ['yarn.lock'] = { glyph = '', hl = 'MiniIconsBlue' },
      },
    },
  },
}
