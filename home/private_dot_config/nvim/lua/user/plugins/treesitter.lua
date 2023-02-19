return {
  'nvim-treesitter/nvim-treesitter',
  opts = {
    auto_install = true,
    sync_install = true,
    ensure_installed = {
      'bash',
      'dockerfile',
      'gitignore',
      'json',
      'lua',
      'python',
      'toml',
      'typescript',
      'yaml',
    }
  },
}
