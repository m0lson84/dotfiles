--[[
Markdown language support
--]]

return {

  -- Add languages to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = { ensure_installed = { 'markdown', 'markdown_inline', 'mermaid' } },
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
    opts = {
      linters_by_ft = {
        markdown = { 'markdownlint' },
      },
    },
  },

  -- Configure formatters
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        markdown = { 'prettierd' },
        markdown_mdx = { 'prettierd' },
      },
    },
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
