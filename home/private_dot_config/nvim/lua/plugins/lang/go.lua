--[[
Go language support
--]]

return {

  -- Add languages to treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts) vim.treesitter.language.register('gotmpl', 'tmpl') end,
  },

  -- Code annotations and documentation
  {
    'danymat/neogen',
    opts = {
      languages = {
        go = { template = { annotation_convention = 'godoc' } },
      },
    },
  },
}
