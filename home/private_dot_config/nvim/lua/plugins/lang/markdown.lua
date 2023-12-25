--[[
Markdown language support
--]]

-- Import utility functions
local util = require('util')

return {

  -- Add languages to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts) vim.list_extend(opts.ensure_installed or {}, { 'markdown', 'markdown_inline', 'mermaid' }) end,
  },

  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        marksman = {},
      },
    },
  },

  -- Configure linters
  {
    'mfussenegger/nvim-lint',
    opts = function(_, opts)
      opts.linters_by_ft = util.table.extend_keys(opts.linters_by_ft, { 'markdown' }, { 'markdownlint' })
    end,
  },

  -- Configure formatters
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters_by_ft = util.table.extend_keys(
        opts.formatters_by_ft,
        { 'markdown', 'markdown_mdx' },
        { 'prettierd' }
      )
    end,
  },

  -- Markdown preview
  {
    'iamcco/markdown-preview.nvim',
    event = { 'BufRead' },
    build = function() vim.fn['mkdp#util#install']() end,
    keys = {
      { '<leader>cp', '<cmd>MarkdownPreviewToggle<cr>', ft = 'markdown', desc = 'Markdown Preview' },
    },
    config = function()
      vim.g.mkdp_theme = 'dark'
      vim.g.mkdp_page_title = 'Markdown Preview'
    end,
  },
}
