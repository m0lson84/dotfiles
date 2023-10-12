--[[
Core treesitter configuration
--]]

return {
  'nvim-treesitter/nvim-treesitter',
  opts = {
    highlight = { enable = true, additional_vim_regex_highlighting = true },
    indent = { enable = true },
    ensure_installed = { 'git_config', 'gitignore', 'html', 'query', 'regex', 'vim', 'vimdoc' },
  },
}
