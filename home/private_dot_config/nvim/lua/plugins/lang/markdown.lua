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
        markdown = { 'markdownlint-cli2' },
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

  -- Markdown rendering
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'echasnovski/mini.icons' },
    opts = {
      file_types = { 'markdown', 'norg', 'rmd', 'org' },
      heading = { enabled = false },
      code = {
        sign = false,
        width = 'block',
        right_pad = 1,
      },
    },
    config = function(_, opts)
      require('render-markdown').setup(opts)
      LazyVim.toggle.map('<leader>um', {
        name = 'Render Markdown',
        get = function() return require('render-markdown.state').enabled end,
        set = function(_) require('render-markdown').toggle() end,
      })
    end,
  },
}
