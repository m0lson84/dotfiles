--[[
nvim-ufo (https://github.com/kevinhwang91/nvim-ufo)
--]]

return {
  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    opts = {
      close_fold_kinds_for_ft = { default = { 'imports', 'comment' } },
      provider_selector = function(_, _, _) return { 'treesitter', 'indent' } end,
    },
  },
}
