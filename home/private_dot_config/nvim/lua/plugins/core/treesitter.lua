return {
  'nvim-treesitter/nvim-treesitter',
  opts = {
    highlight = { enable = true },
    indent = { enable = true },
    ensure_installed = { 'bash', 'json', 'regex', 'yaml' },
  },
}
