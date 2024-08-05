--[[
Biome (https://biomejs.dev/)
--]]

return {
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        biome = {},
      },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters = {
        ['biome-check'] = {},
      },
    },
  },
}
