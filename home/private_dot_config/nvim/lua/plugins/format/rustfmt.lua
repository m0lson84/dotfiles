--[[
rustfmt (https://github.com/patrickvane/shfmt)
--]]

return {
  {
    'stevearc/conform.nvim',
    opts = {
      formatters = {
        rustfmt = {},
      },
    },
  },
}
