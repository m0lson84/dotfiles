--[[
Rust language support
--]]

--- Configure keymap for rust debuggables
---@param bufnr boolean|integer The current buffer
local debuggables = function(bufnr)
  vim.keymap.set(
    'n',
    '<leader>dr',
    function() vim.cmd.RustLsp('debuggables') end,
    { desc = 'Rust Debuggables', buffer = bufnr }
  )
end

local hover_action = function()
  if vim.fn.expand('%:t') == 'Cargo.toml' and require('crates').popup_available() then
    require('crates').show_popup()
  else
    vim.lsp.buf.hover()
  end
end

return {

  -- Add languages to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'ron', 'rust' } },
  },

  -- Configure language plugin
  {
    'mrcjkb/rustaceanvim',
    version = '^5',
    lazy = false,
    opts = {
      server = {
        on_attach = function(_, bufnr) debuggables(bufnr) end,
        load_vscode_settings = true,
        default_settings = {
          ['rust-analyzer'] = {
            checkOnSave = true,
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = { enable = true },
            },
            procMacro = {
              enable = true,
              ignored = {
                ['async-trait'] = { 'async_trait' },
                ['napi-derive'] = { 'napi' },
                ['async-recursion'] = { 'async_recursion' },
              },
            },
          },
        },
      },
    },
    config = function(_, opts) vim.g.rustaceanvim = vim.tbl_deep_extend('keep', vim.g.rustaceanvim or {}, opts) end,
  },

  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        taplo = {
          keys = {
            { 'K', hover_action, desc = 'Show Crate Docs' },
          },
        },
      },
    },
  },

  -- Configure formatters
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        rust = { 'rustfmt' },
      },
    },
  },

  -- Configure debug adapter
  {
    'williamboman/mason.nvim',
    opts = { ensure_installed = { 'codelldb' } },
  },

  -- Configure test runner
  {
    'nvim-neotest/neotest',
    optional = true,
    opts = function(_, opts) vim.list_extend(opts.adapters or {}, { require('rustaceanvim.neotest') }) end,
  },

  -- Code annotations and documentation
  {
    'danymat/neogen',
    opts = {
      languages = {
        rust = { template = { annotation_convention = 'rustdoc' } },
      },
    },
  },

  -- Additional auto completion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      {
        'Saecki/crates.nvim',
        event = { 'BufRead Cargo.toml' },
        opts = {
          completion = { cmp = { enabled = true } },
        },
      },
    },
    opts = function(_, opts) table.insert(opts.sources or {}, { name = 'crates' }) end,
  },
}
