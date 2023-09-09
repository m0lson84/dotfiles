--[[
Markdown language support
--]]

return {

  -- Add markdown to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      if type(opts.ensure_installed) == 'table' then
        vim.list_extend(opts.ensure_installed, { 'markdown', 'markdown_inline', 'mermaid' })
      end
    end,
  },

  -- Configure language server
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        marksman = {
          keys = {
            { '<leader>cp', '<cmd>MarkdownPreviewToggle<cr>', desc = 'Markdown Preview', mode = { 'n' } },
          },
        },
      },
    },
  },

  -- Markdown preview
  {
    'iamcco/markdown-preview.nvim',
    event = { 'BufRead' },
    build = function() vim.fn['mkdp#util#install']() end,
    config = function()
      vim.g.mkdp_theme = 'light'
      vim.g.mkdp_markdown_css = '~/.config/markdown/github.css'
      vim.g.mkdp_page_title = 'Markdown Preview'
    end,
  },
}
